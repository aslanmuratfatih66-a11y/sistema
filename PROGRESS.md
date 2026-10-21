# PROGRESS

## Сейчас
Этап: 0 — Репозиторий, каркас, дизайн-система, сборка
Статус: завершён (проверен на телефоне 2026-10-21)
Следующий шаг: этап 1 — новая сессия с промптом этапа 1 из STAGES.md

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
- ARB (app/lib/l10n/*.arb) правит один агент за раз (на этапе 0 — сабагент B); после правки `flutter gen-l10n`
- Коммиты только с PROGRESS/docs — с `[skip ci]`, чтобы не тратить сборку iOS
- Предпросмотр в браузере: `flutter run -d chrome -t lib/main_preview.dart` (app/). device_preview 3.0 (тулбар теперь в DevTools, вкладка device_preview); своя рамка iPhone 15 Pro = геометрия iPhone 16; Alt+L — ru/tr; нативное — PreviewCapabilityService (`--dart-define=PREVIEW_PLATFORM=android`, `PREVIEW_CERT_DAYS=N`). lib/main.dart не тронут
- Язык: жёсткий `locale: ru` убран — язык системы (tr → турецкий, иначе русский), `SistemaApp(locale:)` для языка из профиля на этапе 1

## Для новой сессии (окружение)
- В bash PATH сессии может не быть инструментов: `export PATH="/c/src/flutter/bin:/c/Program Files/Go/bin:/c/Program Files/GitHub CLI:$PATH"`
- gh залогинен (аккаунт aslanmuratfatih66-a11y), в git-конфиге репо задан автор
- Скачать сборки локально: `gh run download <run-id> -n sistema-ipa -D dist` (и `-n sistema-apk`); dist/ в .gitignore. Сейчас там лежат sistema-7c77019.ipa/.apk
- Проверка до пуша: в app/ — `flutter analyze` и `flutter test`, в server/ — `go vet ./...` и `go test ./...`

## Известные проблемы
- Drift в вебе не настроен (нужны sqlite3.wasm + drift_worker.js в app/web/) — пока БД в UI не используется; понадобится, когда экраны начнут читать БД
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
- Сохранить в надёжном месте %USERPROFILE%\sistema-keys (ключ подписи Android)

## История
- 2026-10-21 — этап 0 — проверен на телефоне; добавлен веб-предпросмотр (main_preview.dart)
- 2026-10-21 — этап 0 — каркас, дизайн-система, главный экран, CapabilityService, сервер-заготовка, CI зелёный
