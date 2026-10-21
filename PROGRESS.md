# PROGRESS

## Сейчас
Этап: 0 — Репозиторий, каркас, дизайн-система, сборка
Статус: ждёт проверки на телефоне
Следующий шаг: пользователь ставит .ipa через Sideloadly и .apk, проверяет главный экран и баннер сертификата; затем этап 1

## Этап 0 — чек-лист
- [x] 1. Репозиторий https://github.com/aslanmuratfatih66-a11y/sistema (публичный)
- [x] 2. Монорепо (каркас: контракты ui/, CapabilityService, Drift AppSettings, роутер 5 вкладок, go.mod): app/ (Flutter, Riverpod, go_router, Drift, l10n ru/tr), server/ (Go, /healthz, go test), deploy/, docs/
- [x] 3. Дизайн-система (SPEC §4)
- [x] 4. Главный экран-эталон (10 блоков) + пустые экраны разделов
- [x] 5. CapabilityService + баннер «сертификат истекает через N дн.»
- [x] 6. CI: ipa без подписи, apk, сервер — до зелёного
- [x] 7. Отчёт и ссылки на .ipa/.apk

## Сабагенты (текущий этап)
- A Дизайн-система: готово — app/lib/ui/theme, app/lib/ui/components
- B Главный экран: готово — app/lib/features/home
- C CI: готово — .github/workflows
- D Сервер-заготовка: готово — server/, deploy/
- E Платформа: готово — app/lib/core/capabilities, баннер, нативное чтение профиля

## Решения и договорённости
- Репозиторий `sistema` публичный — бесплатные минуты macOS в Actions
- Локально установлены: gh (winget), Go 1.27 (winget), Flutter stable в C:\src\flutter (PATH пользователя)
- git author для репо: murat <pomidorka87nn@gmail.com>
- Шрифты Oswald/Inter/JetBrains Mono вшиты в app/assets/fonts (OFL), не google_fonts — офлайн
- Сгенерированные файлы (l10n, drift .g.dart) коммитятся
- Android keystore: PKCS12, сгенерирован openssl, копия в %USERPROFILE%\sistema-keys, секреты ANDROID_KEYSTORE_BASE64/…PASSWORD/KEY_PASSWORD/KEY_ALIAS в GitHub; без key.properties релиз подписывается debug-ключом
- Верхний safe area забирает AppShell (баннер сертификата + MediaQuery.removePadding для вкладок)
- Тексты демо-данных главного экрана — через l10n (HomeText.l10n), homeDataProvider заменим реальными данными на этапе 2
- Компоненты дизайн-системы — публичное API в app/lib/ui/ui.dart, фичи импортируют только его

## Известные проблемы
- iOS Swift (AppDelegate: FlutterImplicitEngineBridge.applicationRegistrar) проверяется только в CI; фолбэк — pluginRegistry.registrar(forPlugin:)?.messenger()
- Визуал не проверен на устройстве (тесты на шрифте Ahem)
- deploy/sistema.service: жёсткий hardening, MemoryMax=256M — проверить на Debian на этапе 5

## CI
Последний run: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39594631298 (app) и …/39594631309 (server) — зелёные
Артефакты:
- ipa: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39594631298/artifacts/12342993056
- apk: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39594631298/artifacts/12344341398
- server: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39594631309/artifacts/12344330517

## Что нужно от пользователя
- Установить .ipa (Sideloadly) и .apk, проверить главный экран, навигацию, баннер «Сертификат истекает через N дн.»
- Сохранить в надёжном месте %USERPROFILE%\sistema-keys (ключ подписи Android)

## История
- 2026-10-21 — этап 0 — каркас, дизайн-система, главный экран, CapabilityService, сервер-заготовка, CI зелёный
