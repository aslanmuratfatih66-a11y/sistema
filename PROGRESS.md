# PROGRESS

## Сейчас
Этап: 0 — Репозиторий, каркас, дизайн-система, сборка
Статус: в работе
Следующий шаг: пользователь выполняет `gh auth login`; затем `gh repo create sistema --public --source=. --push`

## Этап 0 — чек-лист
- [ ] 1. gh auth + репозиторий `sistema` (публичный) — git init и первые коммиты сделаны, ждём `gh auth login`
- [ ] 2. Монорепо: app/ (Flutter, Riverpod, go_router, Drift, l10n ru/tr), server/ (Go, /healthz, go test), deploy/, docs/
- [ ] 3. Дизайн-система (SPEC §4)
- [ ] 4. Главный экран-эталон (10 блоков) + пустые экраны разделов
- [ ] 5. CapabilityService + баннер «сертификат истекает через N дн.»
- [ ] 6. CI: ipa без подписи, apk, сервер — до зелёного
- [ ] 7. Отчёт и ссылки на .ipa/.apk

## Сабагенты (текущий этап)
- A Дизайн-система: не начат — app/lib/ui/theme, app/lib/ui/components
- B Главный экран: не начат — app/lib/features/home
- C CI: не начат — .github/workflows
- D Сервер-заготовка: не начат — server/, deploy/
- E Платформа: не начат — app/lib/core/capabilities, баннер, нативное чтение профиля

## Решения и договорённости
- Репозиторий `sistema` публичный — бесплатные минуты macOS в Actions
- Локально установлены: gh (winget), Go 1.27 (winget), Flutter stable в C:\src\flutter (PATH пользователя)
- git author для репо: murat <pomidorka87nn@gmail.com>

## Известные проблемы
- нет

## CI
Последний run: —
Артефакты: —

## Что нужно от пользователя
- Выполнить `! gh auth login` (GitHub.com, HTTPS, браузер)

## История
- 2026-10-21 — этап 0 — начат: установлены инструменты, git init
