package ai

import (
	"context"
	"encoding/binary"
	"encoding/json"
	"io"
	"net/http"
	"net/url"
	"regexp"
	"strings"
	"sync"
	"time"
)

// TTS: ElevenLabs, только готовые голоса библиотеки (premade), без клонирования (SPEC §9.3).
// TODO: модель eleven_flash_v2_5 и формат pcm_22050 — сверить с актуальной документацией ElevenLabs при подключении ключа.
const (
	elevenBase     = "https://api.elevenlabs.io"
	elevenModel    = "eleven_flash_v2_5"
	elevenPCMRate  = 22050
	maxTTSChars    = 1000
	maxTTSWavChars = 400 // звук уведомления ≤ 30 с
)

var voiceIDRe = regexp.MustCompile(`^[A-Za-z0-9]{1,64}$`)

type voice struct {
	ID     string `json:"id"`
	Name   string `json:"name"`
	Lang   string `json:"lang"`
	Gender string `json:"gender,omitempty"`
}

type elevenLabs struct {
	key string

	mu       sync.Mutex
	voices   []voice
	voicesAt time.Time
}

func newElevenLabs(key string) *elevenLabs { return &elevenLabs{key: key} }

func (e *elevenLabs) listVoices(ctx context.Context) ([]voice, error) {
	e.mu.Lock()
	defer e.mu.Unlock()
	if e.voices != nil && time.Since(e.voicesAt) < time.Hour {
		return e.voices, nil
	}
	cctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()
	req, _ := http.NewRequestWithContext(cctx, http.MethodGet, elevenBase+"/v1/voices", nil)
	req.Header.Set("xi-api-key", e.key)
	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	data, _ := io.ReadAll(io.LimitReader(resp.Body, 8<<20))
	if resp.StatusCode != http.StatusOK {
		return nil, &APIError{Provider: "elevenlabs", Status: resp.StatusCode, Body: truncate(string(data), 300)}
	}
	var r struct {
		Voices []struct {
			VoiceID  string            `json:"voice_id"`
			Name     string            `json:"name"`
			Category string            `json:"category"`
			Labels   map[string]string `json:"labels"`
		} `json:"voices"`
	}
	if err := json.Unmarshal(data, &r); err != nil {
		return nil, err
	}
	out := []voice{}
	for _, v := range r.Voices {
		if v.Category != "premade" { // только готовые голоса: без клонов
			continue
		}
		lang := v.Labels["language"]
		if lang == "" {
			lang = "multi" // мультиязычная модель: ru/tr
		}
		out = append(out, voice{ID: v.VoiceID, Name: v.Name, Lang: lang, Gender: v.Labels["gender"]})
	}
	e.voices, e.voicesAt = out, time.Now()
	return out, nil
}

func (e *elevenLabs) synth(ctx context.Context, text, voiceID, lang string, wav bool) ([]byte, error) {
	format := "mp3_44100_128"
	if wav {
		format = "pcm_22050"
	}
	body := map[string]any{"text": text, "model_id": elevenModel}
	if lang == "ru" || lang == "tr" {
		body["language_code"] = lang
	}
	u := elevenBase + "/v1/text-to-speech/" + url.PathEscape(voiceID) + "?output_format=" + format
	data, _, err := postJSON(ctx, "elevenlabs", u, map[string]string{"xi-api-key": e.key, "Accept": "*/*"}, body, 60*time.Second)
	if err != nil {
		return nil, err
	}
	if wav {
		return wavFromPCM16(data, elevenPCMRate), nil
	}
	return data, nil
}

// wavFromPCM16 — PCM 16-бит LE моно в контейнер WAV.
func wavFromPCM16(pcm []byte, rate int) []byte {
	out := make([]byte, 44+len(pcm))
	copy(out[0:], "RIFF")
	binary.LittleEndian.PutUint32(out[4:], uint32(36+len(pcm)))
	copy(out[8:], "WAVEfmt ")
	binary.LittleEndian.PutUint32(out[16:], 16)
	binary.LittleEndian.PutUint16(out[20:], 1) // PCM
	binary.LittleEndian.PutUint16(out[22:], 1) // моно
	binary.LittleEndian.PutUint32(out[24:], uint32(rate))
	binary.LittleEndian.PutUint32(out[28:], uint32(rate*2))
	binary.LittleEndian.PutUint16(out[32:], 2)
	binary.LittleEndian.PutUint16(out[34:], 16)
	copy(out[36:], "data")
	binary.LittleEndian.PutUint32(out[40:], uint32(len(pcm)))
	copy(out[44:], pcm)
	return out
}

func (s *Service) handleVoices(w http.ResponseWriter, r *http.Request) {
	if s.tts == nil {
		writeError(w, http.StatusServiceUnavailable, "ai_unavailable")
		return
	}
	vs, err := s.tts.listVoices(r.Context())
	if err != nil {
		s.opts.Logger.Error("tts voices", "err", err)
		writeError(w, http.StatusBadGateway, "ai_error")
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"voices": vs})
}

func (s *Service) handleTTS(w http.ResponseWriter, r *http.Request) {
	if s.tts == nil {
		writeError(w, http.StatusServiceUnavailable, "ai_unavailable")
		return
	}
	var req struct {
		Text   string `json:"text"`
		Voice  string `json:"voice"`
		Lang   string `json:"lang"`
		Format string `json:"format"`
	}
	if !decodeBody(w, r, &req) {
		return
	}
	req.Text = strings.TrimSpace(req.Text)
	wav := req.Format == "wav"
	limit := maxTTSChars
	if wav {
		limit = maxTTSWavChars
	}
	if req.Text == "" || len([]rune(req.Text)) > limit {
		writeError(w, http.StatusBadRequest, "bad text")
		return
	}
	if !voiceIDRe.MatchString(req.Voice) {
		writeError(w, http.StatusBadRequest, "bad voice")
		return
	}
	audio, err := s.tts.synth(r.Context(), req.Text, req.Voice, normLang(req.Lang), wav)
	if err != nil {
		s.opts.Logger.Error("tts", "err", err)
		writeError(w, http.StatusBadGateway, "ai_error")
		return
	}
	ct := "audio/mpeg"
	if wav {
		ct = "audio/wav"
	}
	w.Header().Set("Content-Type", ct)
	w.Header().Set("Cache-Control", "no-store")
	_, _ = w.Write(audio)
}
