# PROGRESS

## Сейчас
Этап: 1 — Онбординг, профиль, расписание, план
Статус: в работе
Следующий шаг: дождаться отчётов сабагентов A–E (запущены параллельно), затем интеграция

## Этап 1 — чек-лист
- [x] Каркас: схема БД v2 (Profiles, BodyMeasurements, Photos, Goals, ScheduleSettings/Items, Plans, QuestionnaireSections), enums, QuestionnaireRepository, хост анкеты (OnboardingScreen/StepFrame/StepScope/StepEditScreen), роутер с redirect на /onboarding, поля ввода ui/form_fields.dart, зависимости (camera, permission_handler, file_picker, share_plus, uuid, path), Info.plist/манифест, Drift в вебе
- [ ] 1. Онбординг 12 этапов (A: 1–6, B: 7–12), камера с контуром, фото локально
- [ ] 2. Расписание с чередованием недель, выход из дома (C)
- [ ] 3. Черновой план без ИИ + экран «План» с «Принять» (D)
- [ ] 4. Редактирование анкеты в настройках (E)
- [ ] 5. Экспорт/импорт JSON (E)
- [ ] 6. Юнит-тесты норм и расписания
- [ ] 7. CI зелёный, отчёт

## Сабагенты (текущий этап)
- A Анкета 1–6: готово (8 тестов) — lib/features/onboarding/questionnaire_a/
- B Анкета 7–12: готово (8 тестов) — lib/features/onboarding/questionnaire_b/
- C Расписание: готово (34 теста) — lib/features/schedule/
- D План и нормы: в работе — lib/features/plan/
- E Настройки, экспорт/импорт: готово (19 тестов) — lib/features/settings/

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
- ARB: строки во фрагментах app/l10n_parts/<часть>_{ru,tr}.arb; общий lib/l10n/app_*.arb собирается `dart run tool/merge_l10n.dart` + `flutter gen-l10n` (не править руками)
- Строки таблиц Drift — классы *Row (ProfileRow, PlanRow…), доменные имена свободны
- Разделы анкеты без своих таблиц (кожа, здоровье, питание, тренировки, финансы, персонаж, разрешения) — JSON в QuestionnaireSections; переедут в таблицы на этапах 3/6/7
- Язык интерфейса — Profiles.locale (appLocaleProvider), null — язык системы
- Коммиты только с PROGRESS/docs — с `[skip ci]`, чтобы не тратить сборку iOS
- Предпросмотр в браузере: `flutter run -d chrome -t lib/main_preview.dart` (app/). device_preview 3.0 (тулбар теперь в DevTools, вкладка device_preview); своя рамка iPhone 15 Pro = геометрия iPhone 16; Alt+L — ru/tr; нативное — PreviewCapabilityService (`--dart-define=PREVIEW_PLATFORM=android`, `PREVIEW_CERT_DAYS=N`). lib/main.dart не тронут
- Язык: жёсткий `locale: ru` убран — язык системы (tr → турецкий, иначе русский), `SistemaApp(locale:)` для языка из профиля на этапе 1

## Для новой сессии (окружение)
- В bash PATH сессии может не быть инструментов: `export PATH="/c/src/flutter/bin:/c/Program Files/Go/bin:/c/Program Files/GitHub CLI:$PATH"`
- gh залогинен (аккаунт aslanmuratfatih66-a11y), в git-конфиге репо задан автор
- Скачать сборки локально: `gh run download <run-id> -n sistema-ipa -D dist` (и `-n sistema-apk`); dist/ в .gitignore. Сейчас там лежат sistema-7c77019.ipa/.apk
- Проверка до пуша: в app/ — `flutter analyze` и `flutter test`, в server/ — `go vet ./...` и `go test ./...`

## Известные проблемы
- permission_handler на iOS: при SPM разрешения включаются по ключам Info.plist (Podfile не нужен). Если в CI появится CocoaPods (плагин без SPM) — нужны макросы PERMISSION_* в Podfile post_install
- Drift в вебе не настроен (нужны sqlite3.wasm + drift_worker.js в app/web/) — пока БД в UI не используется; понадобится, когда экраны начнут читать БД
- iOS Swift (AppDelegate: FlutterImplicitEngineBridge.applicationRegistrar) проверяется только в CI; фолбэк — pluginRegistry.registrar(forPlugin:)?.messenger()
- Визуал не проверен на устройстве (тесты на шрифте Ahem)
- deploy/sistema.service: жёсткий hardening, MemoryMax=256M — проверить на Debian на этапе 5

## CI
Последний run: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39598086785 (app) и …/39598087000 (server) — зелёные
Артефакты:
- ipa: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39598086785/artifacts/12345640839
- apk: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39598086785/artifacts/12345236473

## Что нужно от пользователя
- Сохранить в надёжном месте %USERPROFILE%\sistema-keys (ключ подписи Android)

## История
- 2026-10-21 — этап 1 — начат, каркас
- 2026-10-21 — этап 0 — проверен на телефоне; добавлен веб-предпросмотр (main_preview.dart)
- 2026-10-21 — этап 0 — каркас, дизайн-система, главный экран, CapabilityService, сервер-заготовка, CI зелёный
