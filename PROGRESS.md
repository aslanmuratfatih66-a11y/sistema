# PROGRESS

## Сейчас
Этап: 0 — Репозиторий, каркас, дизайн-система, сборка
Статус: в работе
Следующий шаг: дождаться отчётов сабагентов A–E, интеграция (main.dart, баннер в AppShell, ARB), локально analyze/test, пуш

## Этап 0 — чек-лист
- [x] 1. Репозиторий https://github.com/aslanmuratfatih66-a11y/sistema (публичный)
- [x] 2. Монорепо (каркас: контракты ui/, CapabilityService, Drift AppSettings, роутер 5 вкладок, go.mod): app/ (Flutter, Riverpod, go_router, Drift, l10n ru/tr), server/ (Go, /healthz, go test), deploy/, docs/
- [ ] 3. Дизайн-система (SPEC §4)
- [ ] 4. Главный экран-эталон (10 блоков) + пустые экраны разделов
- [ ] 5. CapabilityService + баннер «сертификат истекает через N дн.»
- [ ] 6. CI: ipa без подписи, apk, сервер — до зелёного
- [ ] 7. Отчёт и ссылки на .ipa/.apk

## Сабагенты (текущий этап)
- A Дизайн-система: в работе — app/lib/ui/theme, app/lib/ui/components
- B Главный экран: в работе — app/lib/features/home
- C CI: в работе — .github/workflows
- D Сервер-заготовка: в работе — server/, deploy/
- E Платформа: в работе — app/lib/core/capabilities, баннер, нативное чтение профиля

## Решения и договорённости
- Репозиторий `sistema` публичный — бесплатные минуты macOS в Actions
- Локально установлены: gh (winget), Go 1.27 (winget), Flutter stable в C:\src\flutter (PATH пользователя)
- git author для репо: murat <pomidorka87nn@gmail.com>
- Шрифты Oswald/Inter/JetBrains Mono вшиты в app/assets/fonts (OFL), не google_fonts — офлайн
- Сгенерированные файлы (l10n, drift .g.dart) коммитятся
- Android keystore: PKCS12, сгенерирован openssl, копия в %USERPROFILE%\sistema-keys, секреты ANDROID_KEYSTORE_BASE64/…PASSWORD/KEY_PASSWORD/KEY_ALIAS в GitHub; без key.properties релиз подписывается debug-ключом
- Компоненты дизайн-системы — публичное API в app/lib/ui/ui.dart, фичи импортируют только его

## Известные проблемы
- нет

## CI
Последний run: —
Артефакты: —

## Что нужно от пользователя
- Сохранить в надёжном месте %USERPROFILE%\sistema-keys (ключ подписи Android)

## История
- 2026-10-21 — этап 0 — начат: установлены инструменты, git init
