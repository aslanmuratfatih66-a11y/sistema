package aicfg

import (
	"errors"
	"fmt"
	"io/fs"
	"math/rand/v2"
	"os"
	"path"
	"path/filepath"
	"strings"

	"gopkg.in/yaml.v3"

	defaults "github.com/aslanmuratfatih66-a11y/sistema/server/config"
)

// Ситуации примеров реплик в карточке (SPEC §9.1).
const (
	SitMorning  = "morning"  // утро, брифинг
	SitCheer    = "cheer"    // подбадривание среди дня
	SitPraise   = "praise"   // похвала за выполненное
	SitFail     = "fail"     // провал квеста / пропуск
	SitRelapse  = "relapse"  // срыв (вредная привычка, переел, сорвал режим)
	SitRefuse   = "refuse"   // отказ от квеста
	SitTired    = "tired"    // усталость
	SitEvening  = "evening"  // вечерние итоги
	SitOffTopic = "offtopic" // вопрос не по теме
)

// Situations — все ситуации (порядок — для aibench и проверок).
var Situations = []string{SitMorning, SitCheer, SitPraise, SitFail, SitRelapse, SitRefuse, SitTired, SitEvening, SitOffTopic}

// FormBase — базовая форма персонажа.
const FormBase = "base"

// Form — характер одной формы. Пустые поля усиленной формы берутся из base.
type Form struct {
	// Unlock — условие формы (как в character.json клиента, SPEC §9.2); сервер его не проверяет —
	// форму присылает клиент.
	Unlock      map[string]any      `yaml:"unlock,omitempty"`
	Personality string              `yaml:"personality"`
	Speech      string              `yaml:"speech"`
	Words       map[string][]string `yaml:"words"` // язык → словечки
	Do          []string            `yaml:"do"`
	Dont        []string            `yaml:"dont"`
	Attitude    string              `yaml:"attitude"`
	// Lines — язык → ситуация → примеры реплик.
	Lines map[string]map[string][]string `yaml:"lines"`
}

// Card — карточка персонажа characters/<id>.yaml.
type Card struct {
	ID    string            `yaml:"id"`
	Name  map[string]string `yaml:"name"` // язык → имя архетипа
	Forms map[string]*Form  `yaml:"forms"`
}

// Characters — карточки по id архетипа клиента (CharacterArchetype: animeGirl, animeGuy, stoicStrongman, grimSwordsman).
type Characters map[string]*Card

// LoadCharacters — вшитые карточки, поверх — <dir>/characters/<id>.yaml (файл заменяет карточку целиком).
func LoadCharacters(dir string) (Characters, error) {
	out := Characters{}
	entries, err := fs.ReadDir(defaults.FS, "characters")
	if err != nil {
		return nil, err
	}
	for _, e := range entries {
		if e.IsDir() || !strings.HasSuffix(e.Name(), ".yaml") {
			continue
		}
		data, err := defaults.FS.ReadFile(path.Join("characters", e.Name()))
		if err != nil {
			return nil, err
		}
		c, err := parseCard(data, strings.TrimSuffix(e.Name(), ".yaml"))
		if err != nil {
			return nil, fmt.Errorf("aicfg: embedded %s: %w", e.Name(), err)
		}
		out[c.ID] = c
	}
	if dir == "" {
		return out, nil
	}
	cdir := filepath.Join(dir, "characters")
	files, err := os.ReadDir(cdir)
	if errors.Is(err, fs.ErrNotExist) {
		return out, nil
	}
	if err != nil {
		return out, fmt.Errorf("aicfg: %s: %w", cdir, err)
	}
	for _, e := range files {
		if e.IsDir() || !strings.HasSuffix(e.Name(), ".yaml") {
			continue
		}
		p := filepath.Join(cdir, e.Name())
		data, err := os.ReadFile(p)
		if err != nil {
			return out, fmt.Errorf("aicfg: %s: %w", p, err)
		}
		c, err := parseCard(data, strings.TrimSuffix(e.Name(), ".yaml"))
		if err != nil {
			return out, fmt.Errorf("aicfg: %s: %w", p, err)
		}
		out[c.ID] = c
	}
	return out, nil
}

func parseCard(data []byte, id string) (*Card, error) {
	var c Card
	if err := yaml.Unmarshal(data, &c); err != nil {
		return nil, err
	}
	if c.ID == "" {
		c.ID = id
	}
	if c.Forms[FormBase] == nil {
		return nil, errors.New("no base form")
	}
	return &c, nil
}

// Get — карточка архетипа; неизвестный — первая по алфавиту из animeGirl/… (никогда nil, если есть хоть одна).
func (cs Characters) Get(id string) *Card {
	if c := cs[id]; c != nil {
		return c
	}
	if c := cs["animeGirl"]; c != nil {
		return c
	}
	for _, c := range cs {
		return c
	}
	return nil
}

// Form — форма с наследованием пустых полей из base. Неизвестная форма — base. Возвращает и имя формы.
func (c *Card) Form(name string) (Form, string) {
	base := *c.Forms[FormBase]
	if name == "" || name == FormBase || c.Forms[name] == nil {
		return base, FormBase
	}
	f := *c.Forms[name]
	if f.Personality == "" {
		f.Personality = base.Personality
	}
	if f.Speech == "" {
		f.Speech = base.Speech
	}
	if len(f.Words) == 0 {
		f.Words = base.Words
	}
	if len(f.Do) == 0 {
		f.Do = base.Do
	}
	if len(f.Dont) == 0 {
		f.Dont = base.Dont
	} else {
		// Запреты базовой формы действуют всегда.
		f.Dont = append(append([]string{}, base.Dont...), f.Dont...)
	}
	if f.Attitude == "" {
		f.Attitude = base.Attitude
	}
	return f, name
}

// Lines — примеры реплик формы для языка и ситуации; нет у формы — у base; нет на языке — ru.
func (c *Card) Lines(form, lang, situation string) []string {
	try := func(f *Form, l string) []string {
		if f == nil || f.Lines == nil {
			return nil
		}
		return f.Lines[l][situation]
	}
	forms := []*Form{c.Forms[form], c.Forms[FormBase]}
	for _, l := range []string{lang, "ru"} {
		for _, f := range forms {
			if ls := try(f, l); len(ls) > 0 {
				return ls
			}
		}
	}
	return nil
}

// Line — случайная реплика (пусто, если примеров нет).
func (c *Card) Line(form, lang, situation string) string {
	ls := c.Lines(form, lang, situation)
	if len(ls) == 0 {
		return ""
	}
	return ls[rand.IntN(len(ls))]
}

// DisplayName — имя архетипа на языке.
func (c *Card) DisplayName(lang string) string {
	if n := c.Name[lang]; n != "" {
		return n
	}
	return c.Name["ru"]
}
