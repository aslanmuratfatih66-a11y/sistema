// Package media — загрузка фото (WebP ~1600px + миниатюра), отдача только владельцу (SPEC §10).
// Маршруты — под httpapi.UploadPathPrefix (/api/v1/photos). Оригинал не хранится.
package media

import (
	"bytes"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"image"
	_ "image/jpeg" // регистрация декодера
	_ "image/png"  // регистрация декодера
	"io"
	"log/slog"
	"mime"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"time"

	"github.com/gen2brain/webp"
	"golang.org/x/image/draw"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/authctx"
)

const (
	maxSide     = 1600
	thumbSide   = 320
	quality     = 80
	thumbQ      = 75
	maxPixels   = 24_000_000 // защита от «бомб» распаковки и MemoryMax=256M (~24 Мп)
	parallelism = 1          // одновременных обработок (память ≤256 МБ)
)

var idRe = regexp.MustCompile(`^[A-Za-z0-9-]{1,64}$`)

type Options struct {
	PhotosDir string // <data>/photos
	MaxBytes  int64
	Logger    *slog.Logger
}

type Handler struct {
	db   *sql.DB
	opts Options
	sem  chan struct{}
}

func New(db *sql.DB, opts Options) *Handler {
	if opts.Logger == nil {
		opts.Logger = slog.Default()
	}
	if opts.MaxBytes <= 0 {
		opts.MaxBytes = 20 << 20
	}
	return &Handler{db: db, opts: opts, sem: make(chan struct{}, parallelism)}
}

// Register — маршруты /api/v1/photos/{id}[/thumb].
func (h *Handler) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {
	mux.Handle("PUT /api/v1/photos/{id}", require(http.HandlerFunc(h.put)))
	mux.Handle("GET /api/v1/photos/{id}", require(http.HandlerFunc(h.get(false))))
	mux.Handle("GET /api/v1/photos/{id}/thumb", require(http.HandlerFunc(h.get(true))))
	mux.Handle("DELETE /api/v1/photos/{id}", require(http.HandlerFunc(h.del)))
}

func writeErr(w http.ResponseWriter, code int, msg string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(map[string]string{"error": msg})
}

// ids проверяет пользователя и id фото (оба идут в путь на диске).
func ids(w http.ResponseWriter, r *http.Request) (user, id string, ok bool) {
	user = authctx.UserID(r.Context())
	if user == "" {
		writeErr(w, http.StatusUnauthorized, "unauthorized")
		return "", "", false
	}
	if !idRe.MatchString(user) {
		writeErr(w, http.StatusInternalServerError, "bad user id")
		return "", "", false
	}
	id = r.PathValue("id")
	if !idRe.MatchString(id) {
		writeErr(w, http.StatusBadRequest, "bad photo id")
		return "", "", false
	}
	return user, id, true
}

func (h *Handler) put(w http.ResponseWriter, r *http.Request) {
	user, id, ok := ids(w, r)
	if !ok {
		return
	}
	select {
	case h.sem <- struct{}{}:
		defer func() { <-h.sem }()
	case <-r.Context().Done():
		return
	}

	r.Body = http.MaxBytesReader(w, r.Body, h.opts.MaxBytes)
	data, err := readUpload(r)
	if err != nil {
		var mbe *http.MaxBytesError
		if errors.As(err, &mbe) {
			writeErr(w, http.StatusRequestEntityTooLarge, "photo too large")
			return
		}
		writeErr(w, http.StatusBadRequest, "bad upload: "+err.Error())
		return
	}

	switch sniff(data) {
	case "jpeg", "png", "webp":
	case "heic":
		writeErr(w, http.StatusUnsupportedMediaType, "HEIC not supported, send JPEG")
		return
	default:
		writeErr(w, http.StatusUnsupportedMediaType, "JPEG or PNG expected")
		return
	}

	full, thumb, wd, ht, err := process(data)
	data = nil
	if err != nil {
		writeErr(w, http.StatusUnprocessableEntity, err.Error())
		return
	}

	ctx := r.Context()
	now := time.Now().UTC()
	created := now.UnixMilli()
	var oldPath, oldThumb string
	err = h.db.QueryRowContext(ctx, `SELECT path, thumb_path, created_at FROM photos WHERE user_id=? AND id=?`, user, id).
		Scan(&oldPath, &oldThumb, &created)
	if err != nil && !errors.Is(err, sql.ErrNoRows) {
		h.opts.Logger.Error("photo lookup", "err", err)
		writeErr(w, http.StatusInternalServerError, "db error")
		return
	}
	ct := time.UnixMilli(created).UTC()
	dir := filepath.Join(user, fmt.Sprintf("%04d", ct.Year()), fmt.Sprintf("%02d", int(ct.Month())))
	rel := filepath.ToSlash(filepath.Join(dir, id+".webp"))
	relT := filepath.ToSlash(filepath.Join(dir, id+"_t.webp"))

	if err := os.MkdirAll(filepath.Join(h.opts.PhotosDir, dir), 0o750); err != nil {
		h.opts.Logger.Error("photo mkdir", "err", err)
		writeErr(w, http.StatusInternalServerError, "storage error")
		return
	}
	err = writeAtomic(h.abs(rel), full)
	if err == nil {
		err = writeAtomic(h.abs(relT), thumb)
	}
	if err != nil {
		h.opts.Logger.Error("photo write", "err", err)
		writeErr(w, http.StatusInternalServerError, "storage error")
		return
	}

	_, err = h.db.ExecContext(ctx, `INSERT INTO photos(user_id,id,path,thumb_path,width,height,bytes,created_at,deleted_at)
		VALUES(?,?,?,?,?,?,?,?,NULL)
		ON CONFLICT(user_id,id) DO UPDATE SET path=excluded.path, thumb_path=excluded.thumb_path,
		width=excluded.width, height=excluded.height, bytes=excluded.bytes, deleted_at=NULL`,
		user, id, rel, relT, wd, ht, len(full), created)
	if err != nil {
		h.opts.Logger.Error("photo upsert", "err", err)
		writeErr(w, http.StatusInternalServerError, "db error")
		return
	}
	// Старые файлы в другом месте (на случай смены схемы путей).
	for _, p := range []string{oldPath, oldThumb} {
		if p != "" && p != rel && p != relT {
			_ = os.Remove(h.abs(p))
		}
	}
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]any{"id": id, "width": wd, "height": ht, "bytes": len(full)})
}

func (h *Handler) abs(rel string) string {
	return filepath.Join(h.opts.PhotosDir, filepath.FromSlash(rel))
}

func (h *Handler) get(thumb bool) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user, id, ok := ids(w, r)
		if !ok {
			return
		}
		col := "path"
		if thumb {
			col = "thumb_path"
		}
		var rel string
		err := h.db.QueryRowContext(r.Context(),
			`SELECT `+col+` FROM photos WHERE user_id=? AND id=? AND deleted_at IS NULL`, user, id).Scan(&rel)
		if err != nil {
			if !errors.Is(err, sql.ErrNoRows) {
				h.opts.Logger.Error("photo get", "err", err)
			}
			writeErr(w, http.StatusNotFound, "not found")
			return
		}
		f, err := os.Open(h.abs(rel))
		if err != nil {
			writeErr(w, http.StatusNotFound, "not found")
			return
		}
		defer f.Close()
		st, err := f.Stat()
		if err != nil {
			writeErr(w, http.StatusNotFound, "not found")
			return
		}
		w.Header().Set("Content-Type", "image/webp")
		w.Header().Set("Cache-Control", "private, max-age=86400")
		http.ServeContent(w, r, "", st.ModTime(), f)
	}
}

func (h *Handler) del(w http.ResponseWriter, r *http.Request) {
	user, id, ok := ids(w, r)
	if !ok {
		return
	}
	var rel, relT string
	err := h.db.QueryRowContext(r.Context(), `SELECT path, thumb_path FROM photos WHERE user_id=? AND id=?`, user, id).Scan(&rel, &relT)
	if errors.Is(err, sql.ErrNoRows) {
		writeErr(w, http.StatusNotFound, "not found")
		return
	}
	if err == nil {
		_, err = h.db.ExecContext(r.Context(),
			`UPDATE photos SET deleted_at=? WHERE user_id=? AND id=? AND deleted_at IS NULL`,
			time.Now().UnixMilli(), user, id)
	}
	if err != nil {
		h.opts.Logger.Error("photo delete", "err", err)
		writeErr(w, http.StatusInternalServerError, "db error")
		return
	}
	_ = os.Remove(h.abs(rel))
	_ = os.Remove(h.abs(relT))
	w.WriteHeader(http.StatusNoContent)
}

// readUpload — файл из multipart (первая часть с файлом) или сырое тело.
func readUpload(r *http.Request) ([]byte, error) {
	mt, _, _ := mime.ParseMediaType(r.Header.Get("Content-Type"))
	if mt != "multipart/form-data" {
		return io.ReadAll(r.Body)
	}
	mr, err := r.MultipartReader()
	if err != nil {
		return nil, err
	}
	for {
		p, err := mr.NextPart()
		if err != nil {
			if err == io.EOF {
				return nil, errors.New("no file part")
			}
			return nil, err
		}
		if p.FileName() != "" || p.FormName() == "file" || p.FormName() == "photo" {
			b, err := io.ReadAll(p)
			p.Close()
			return b, err
		}
		p.Close()
	}
}

func sniff(b []byte) string {
	switch {
	case len(b) >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF:
		return "jpeg"
	case len(b) >= 8 && bytes.Equal(b[:8], []byte("\x89PNG\r\n\x1a\n")):
		return "png"
	case len(b) >= 12 && string(b[:4]) == "RIFF" && string(b[8:12]) == "WEBP":
		return "webp"
	case len(b) >= 12 && string(b[4:8]) == "ftyp":
		return "heic" // HEIC/HEIF/AVIF — не декодируем
	}
	return ""
}

// process декодирует, уменьшает, поворачивает по EXIF и кодирует в WebP (полное + миниатюра).
func process(data []byte) (full, thumb []byte, w, h int, err error) {
	var src image.Image
	orient := 1
	if sniff(data) == "webp" {
		cfg, e := webp.DecodeConfig(bytes.NewReader(data))
		if e != nil {
			return nil, nil, 0, 0, fmt.Errorf("decode: %w", e)
		}
		if cfg.Width*cfg.Height > maxPixels {
			return nil, nil, 0, 0, errors.New("image too large")
		}
		src, err = webp.Decode(bytes.NewReader(data))
	} else {
		cfg, _, e := image.DecodeConfig(bytes.NewReader(data))
		if e != nil {
			return nil, nil, 0, 0, fmt.Errorf("decode: %w", e)
		}
		if cfg.Width <= 0 || cfg.Height <= 0 || cfg.Width*cfg.Height > maxPixels {
			return nil, nil, 0, 0, errors.New("image too large")
		}
		if sniff(data) == "jpeg" {
			orient = jpegOrientation(data)
		}
		src, _, err = image.Decode(bytes.NewReader(data))
	}
	if err != nil {
		return nil, nil, 0, 0, fmt.Errorf("decode: %w", err)
	}

	big := orientImg(scale(src, maxSide, draw.CatmullRom), orient)
	src = nil
	small := scale(big, thumbSide, draw.CatmullRom)

	var bf, bt bytes.Buffer
	if err := webp.Encode(&bf, big, webp.Options{Quality: quality}); err != nil {
		return nil, nil, 0, 0, fmt.Errorf("encode: %w", err)
	}
	if err := webp.Encode(&bt, small, webp.Options{Quality: thumbQ}); err != nil {
		return nil, nil, 0, 0, fmt.Errorf("encode: %w", err)
	}
	b := big.Bounds()
	return bf.Bytes(), bt.Bytes(), b.Dx(), b.Dy(), nil
}

// scale уменьшает до side по длинной стороне (не увеличивает); результат — *image.RGBA.
func scale(src image.Image, side int, k draw.Interpolator) *image.RGBA {
	sb := src.Bounds()
	w, h := sb.Dx(), sb.Dy()
	if w >= h && w > side {
		h = max(1, h*side/w)
		w = side
	} else if h > w && h > side {
		w = max(1, w*side/h)
		h = side
	}
	dst := image.NewRGBA(image.Rect(0, 0, w, h))
	if w == sb.Dx() && h == sb.Dy() {
		draw.Draw(dst, dst.Bounds(), src, sb.Min, draw.Src)
	} else {
		k.Scale(dst, dst.Bounds(), src, sb, draw.Src, nil)
	}
	return dst
}

// orientImg применяет EXIF Orientation (1..8).
func orientImg(src *image.RGBA, o int) *image.RGBA {
	if o < 2 || o > 8 {
		return src
	}
	w, h := src.Rect.Dx(), src.Rect.Dy()
	dw, dh := w, h
	if o >= 5 {
		dw, dh = h, w
	}
	dst := image.NewRGBA(image.Rect(0, 0, dw, dh))
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			var nx, ny int
			switch o {
			case 2:
				nx, ny = w-1-x, y
			case 3:
				nx, ny = w-1-x, h-1-y
			case 4:
				nx, ny = x, h-1-y
			case 5:
				nx, ny = y, x
			case 6:
				nx, ny = h-1-y, x
			case 7:
				nx, ny = h-1-y, w-1-x
			case 8:
				nx, ny = y, w-1-x
			}
			si := src.PixOffset(x, y)
			di := dst.PixOffset(nx, ny)
			copy(dst.Pix[di:di+4], src.Pix[si:si+4])
		}
	}
	return dst
}

// jpegOrientation — тег 0x0112 из APP1/EXIF; 1 при отсутствии или ошибке.
func jpegOrientation(b []byte) int {
	i := 2
	for i+4 <= len(b) {
		if b[i] != 0xFF {
			return 1
		}
		m := b[i+1]
		if m == 0xD8 || (m >= 0xD0 && m <= 0xD7) || m == 0x01 {
			i += 2
			continue
		}
		if m == 0xDA || m == 0xD9 {
			return 1
		}
		n := int(b[i+2])<<8 | int(b[i+3])
		if n < 2 || i+2+n > len(b) {
			return 1
		}
		seg := b[i+4 : i+2+n]
		if m == 0xE1 && len(seg) > 14 && string(seg[:6]) == "Exif\x00\x00" {
			return tiffOrientation(seg[6:])
		}
		i += 2 + n
	}
	return 1
}

func tiffOrientation(t []byte) int {
	if len(t) < 8 {
		return 1
	}
	var u16 func([]byte) int
	var u32 func([]byte) int
	switch string(t[:2]) {
	case "II":
		u16 = func(p []byte) int { return int(p[0]) | int(p[1])<<8 }
		u32 = func(p []byte) int { return int(p[0]) | int(p[1])<<8 | int(p[2])<<16 | int(p[3])<<24 }
	case "MM":
		u16 = func(p []byte) int { return int(p[1]) | int(p[0])<<8 }
		u32 = func(p []byte) int { return int(p[3]) | int(p[2])<<8 | int(p[1])<<16 | int(p[0])<<24 }
	default:
		return 1
	}
	off := u32(t[4:8])
	if off < 8 || off+2 > len(t) {
		return 1
	}
	cnt := u16(t[off : off+2])
	for k := 0; k < cnt; k++ {
		e := off + 2 + k*12
		if e+12 > len(t) {
			return 1
		}
		if u16(t[e:e+2]) == 0x0112 {
			v := u16(t[e+8 : e+10])
			if v >= 1 && v <= 8 {
				return v
			}
			return 1
		}
	}
	return 1
}

// writeAtomic — запись во временный файл и rename.
func writeAtomic(path string, data []byte) error {
	f, err := os.CreateTemp(filepath.Dir(path), ".tmp-*")
	if err != nil {
		return err
	}
	tmp := f.Name()
	_, err = f.Write(data)
	if err == nil {
		err = f.Sync()
	}
	if cerr := f.Close(); err == nil {
		err = cerr
	}
	if err == nil {
		err = os.Chmod(tmp, 0o640)
	}
	if err == nil {
		err = os.Rename(tmp, path)
	}
	if err != nil {
		_ = os.Remove(tmp)
	}
	return err
}
