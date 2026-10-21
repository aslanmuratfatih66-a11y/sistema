# PROGRESS

## Сейчас
Этап: 5 — Сервер: вход, синхронизация, фото, бэкапы
Статус: собирается в CI
Следующий шаг: проверить CI (app+server); затем этап 6 — ИИ, персонаж, голос

## Этап 5 — чек-лист
- [x] Каркас: server/internal/store (SQLite modernc, миграции user_version: users, sessions, access_tokens, records, sync_cursors, photos, fx_rates, job_runs), authctx, контракты auth/syncapi/media/jobs + проводка в main.go, httpapi.Options.Mount, config (MAX_PHOTO_BYTES, BACKUP_DIR, BACKUP_KEEP_DAYS, TRUST_PROXY, FX_URL); клиент: core/sync/sync_api.dart, /account, flutter_secure_storage, qr_flutter
- [x] A Auth (server/internal/auth) — готово
- [x] B Sync API (server/internal/syncapi) — готово
- [x] C Фото и задачи (server/internal/media, jobs) — готово
- [x] D Deploy (deploy/) — готово
- [x] E Клиент (core/sync, features/auth) — готово
- [x] Интеграция: go.mod (x/crypto), фото ≤24 Мп и 1 поток (память 256М), openapi 0.5.0; main: syncOverrides(readPhoto), запуск syncServiceProvider; «Ещё» → панель «Аккаунт» + SyncIndicator
- [ ] CI зелёный (этап 4: iOS-джоба не получила раннер macOS — перезапуск этим пушем)

## Этап 4 — чек-лист
- [x] Каркас: БД v5 (WalkRoutes, Walks), WalkMode; geolocator, flutter_map+latlong2, audio_session, home_widget; контракты domain/walks/walk_api.dart, core/audio/audio_api.dart, core/live/live_api.dart; iOS: таргет SistemaWidgets (ruby ios/scripts/setup_extensions.rb, гем xcodeproj, Ruby в C:\Ruby33-x64), ios/Shared/SistemaShared.swift (App Group, SistemaActivityAttributes, AddWaterIntent), каналы MapKit/NowPlaying/LiveActivity (заготовки), entitlements App Group, Info.plist (фон location+audio, Live Activities, схема sistema://, queries spotify); Android: FOREGROUND_SERVICE_LOCATION, queries Spotify; маршрут /walks, заглушка
- [x] 1. Маршруты и карта, поиск магазина (A)
- [x] 2. Аудио: голос поверх музыки, Apple Music, Spotify (B)
- [x] 3. Фоновая геолокация и трекинг (C)
- [x] 4. Live Activity, виджеты, App Intent (D)
- [x] 5a. Интеграция: overrides в main (route/location/walkTracker/voice/music/live/widgets), app/live_bridge.dart (виджеты из «Статуса», вода из виджета при старте/resumed, Live Activity прогулки ≤1 раз в 5 с), «Нет воды» → /walks?shop=water; 533 теста
- [ ] 5b. CI зелёный, отчёт

## Сабагенты (этап 4)
- A Маршруты и карта: готово (21 тест) — features/walks, MapKitChannel.swift, wlk_*.arb; «Магазин рядом»: /walks?shop=water|1 или showNearbyShopSheet
- B Аудио: готово (19 тестов) — core/audio, NowPlayingChannel.swift, AudioChannel.kt; MainActivity подключён; main: override voicePrompterProvider (buildVoicePrompter) и musicControllerProvider — при интеграции
- C Геолокация и трекинг: готово (20 тестов) — core/location (GeolocatorLocationService, GeolocatorWalkTracker, createWalkTracker(db)), loc_*.arb; main: override locationServiceProvider/walkTrackerProvider — при интеграции
- D Live Activity и виджеты: готово (14 тестов) — core/live, ios/SistemaWidgets, LiveActivityChannel.swift, SistemaWidgetProvider.kt + res; манифест подключён; main: override liveActivityServiceProvider/widgetSyncProvider (create*), takePendingWater при старте и resumed — при интеграции

## Этап 3 — чек-лист (завершён)
- [x] Каркас: БД v4 (FoodItems, MealEntries, Recipes, WaterLogs, ShoppingItems, StepLogs, SleepLogs, CareChecks, WorkoutPrograms, WorkoutSessions), enums, core/models/daily.dart, core/activity/activity_api.dart, domain/quests/section_hooks.dart; mobile_scanner/http/fl_chart/image_picker/wakelock_plus; Health Connect (minSdk 26, FlutterFragmentActivity, манифест), канал sistema/steps (StepCounterChannel.swift/.kt — заготовки, в pbxproj); маршруты /body /workouts, заглушки
- [x] 1. Питание §8.2 (A)
- [x] 2. Шаги и расход (B)
- [x] 3. Тело: сон, замеры, графики, фото-дневник, уход за кожей (C)
- [x] 4. Тренировки (D)
- [x] 5. Интеграция с движком квестов, «Статус» на реальных данных
- [x] 6. Тесты (459), CI зелёный, отчёт

## Сабагенты (этап 3)
- A Питание: готово (37 тестов) — features/nutrition (nut_*); интеграция: nutritionBurnedKcalProvider ← dailyEnergyProvider, foodLookupLangProvider ← язык, «Статус»: nutritionDayProvider, waterGoalProvider
- B Шаги и калории: готово (34 теста) — core/activity, features/activity (StepsPanel), StepCounterChannel.swift/.kt (act_*); main: override stepCounterProvider ChannelStepCounter(), container.read(stepSyncProvider).start()
- C Тело: готово (33 теста) — features/body (bdy_*); интеграция: StepsPanel в слот BodyScreen (между _SleepPanel и _MeasurementsPanel), «Статус»: energyPercentProvider, sleepDayProvider
- D Тренировки: готово (34 теста) — features/workouts (wrk_*); workoutsDayProvider

## Этап 2 — итог
Готов: движок квестов, напоминания, экраны квестов и окна, магазин, дисциплина; 317 тестов. CI run 39647992929.

## Этап 1 — итог
Завершён (проверка на телефоне — вместе после этапа 4–5). Анкета 12 шагов, камера/фото-сессия под голос ассистента,
расписание с чередованием недель, черновой план и нормы, настройки, экспорт/импорт JSON; доработки 1.1–1.3 по замечаниям.
Персонажей (рисовку) не трогаем — владелец заменит целиком позже.

## Решения и договорённости
- Этап 2: ◆/опыт/характеристики — только сумма журнала QuestEvents; покупка в магазине — событие purchase (отдельной таблицы Purchase нет); награда/штраф копируются в экземпляр
- StatKind/PlayerRank переехали в core/models/enums.dart (home_view_data их реэкспортирует)
- Питание: «приёмы пищи» = число разных типов за день; поиск продуктов фильтруется в Dart (lower() SQLite не знает кириллицу/турецкий); день тренировки — по распорядку принятого плана → норма waterTrainingDayMl; список «от плана» перегенерирует только некупленные пункты source plan; цена — в копейках/курушах, RUB/TRY
- Xcode-проект правится скриптом ios/scripts/setup_extensions.rb (xcodeproj), не руками; новые Swift-файлы в Runner/расширение — через него
- Расход энергии учитывает и прерванные тренировки (kcal пишется за сделанное)
- Хуки разделов → квесты: QuestSectionHooks (вода по порядку квестов, еда по count, тренировка от 80% минут, уход, отбой ±15 мин, шаги — квесты с confirm=steps)
- Android: добавлен INTERNET (Open Food Facts)
- Riverpod 3: StreamProvider без слушателей на паузе — в тестах `container.listen(...)` перед `read(.future)`
- Виджет-тесты с drift-потоками: БД закрывать через `tester.runAsync(db.close)` после снятия экрана — иначе tearDown под fake async зависает
- Сервисы этапа 2 — через провайдеры-контракты (questServiceProvider, reminderSchedulerProvider), реализация подключается в main
- С этапа 5 по просьбе владельца: тесты не пишем, CI не ждём блокирующе (только analyze/vet), сразу следующий этап
- Проверка на телефоне — не после каждого этапа, а вместе после этапа 4–5 (решение владельца); после зелёного CI сразу следующий этап
- Порядок анкеты: Профиль → Персонаж → Тело → … (ассистент озвучивает фото-сессии)
- TTS: сеттеры движка (язык/голос/тон/скорость) применяются только при изменении, stop — только если фраза звучит (иначе лаг отсчёта на Android/iOS)
- Android compileSdk = 37 (требует permission_handler_android 14), предупреждение AGP 9.1 заглушено в gradle.properties
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
- Этап 5: фото не скачиваются с сервера на второе устройство (remotePath не заполняется); TOTP нельзя отключить/перевыпустить; защита от повтора TOTP-кода — в памяти; сервер/деплой не проверены вживую — инструкция deploy/README.md
- Этап 4: Spotify — заглушка (нужна регистрация в Spotify Dashboard, Redirect URI); прогулка после перезапуска восстанавливается на паузе; норма шагов виджета — 8000 по умолчанию; Swift/Kotlin этапа 4 проверены только сборкой
- Тело: «сегодня» (bodyClockProvider) не пересчитывается в полночь; дневной сон не записать; удаление фото без подтверждения
- Шаги: Health Connect без приложения-писателя (Google Fit/Samsung Health) даёт 0, фолбэка на датчик нет; датчик не видит шаги до первого опроса за день; CMPedometer — история 7 дней
- Перенос шага «Персонаж» сдвинул индексы шагов анкеты (прогресс хранится индексом) — у незавершённой анкеты шаг может сместиться на 1
- Размер контура тела (75%) подобран расчётом под FOV фронталки ~65° на 2 м — уточнить по телефону
- Камера (экран съёмки с контуром), permission_handler, share_plus/file_picker — не проверены на устройствах
- Кнопка смены камеры — Material-иконка; добавить SysGlyph.camera/cameraSwitch в дизайн-систему
- Даты (рождение, срок цели, якорь недели) хранятся как локальная полночь — при смене пояса на западный могут съехать на день
- Главный экран всё ещё на демо-данных (этап 2 подключит план/расписание: acceptedPlanProvider, ScheduleLogic.dayTimeline)
- permission_handler на iOS: при SPM разрешения включаются по ключам Info.plist (Podfile не нужен). Если в CI появится CocoaPods (плагин без SPM) — нужны макросы PERMISSION_* в Podfile post_install
- Drift в вебе не настроен (нужны sqlite3.wasm + drift_worker.js в app/web/) — пока БД в UI не используется; понадобится, когда экраны начнут читать БД
- iOS Swift (AppDelegate: FlutterImplicitEngineBridge.applicationRegistrar) проверяется только в CI; фолбэк — pluginRegistry.registrar(forPlugin:)?.messenger()
- Визуал не проверен на устройстве (тесты на шрифте Ahem)
- deploy/sistema.service: жёсткий hardening, MemoryMax=256M — проверить на Debian на этапе 5

## CI
Этап 3: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39652915537 — зелёный
- ipa: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39652915537/artifacts/12369508087
- apk: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39652915537/artifacts/12371475811
Этап 2: run 39647992929 — зелёный

## Что нужно от пользователя
- Деплой сервера по deploy/README.md; если порт 443 занят — прислать вывод `sudo ss -ltnp 'sport = :443'`, ничего не трогать
- Сохранить в надёжном месте %USERPROFILE%\sistema-keys (ключ подписи Android)
- После этапа 4–5 — общая проверка на телефоне. Копим список:
  - этап 1: анкета (прервать/продолжить), разрешения, План → Принять, «Ещё»: правка разделов, язык, экспорт/импорт
  - этап 2: квесты (выполнить/+10 мин/отказ удержанием), уведомления с кнопками, тихие часы, окна провала/уровня/штрафа, магазин, дисциплина
  - этап 3: штрихкод (Open Food Facts), фото еды, вода, шаги (разрешение Motion / Health Connect), сон и «Энергия», замеры, фото-дневник, уход за кожей, тренировка с голосом и без гашения экрана
  - фото-сессия: отсчёт без лагов (1.3), совпадение с контуром тела на ~2 м, овал лица, голос ассистента

## История
- 2026-10-21 — этап 3 — питание, шаги/расход, тело, тренировки; 459 тестов, CI зелёный
- 2026-10-21 — этап 2 — интеграция A–D, 317 тестов зелёные; начат этап 3 (каркас)
- 2026-10-21 — этап 1 — 1.3: лаг отсчёта (лишние вызовы TTS) исправлен; этап 1 завершён, начат этап 2
- 2026-10-21 — этап 1 — доработка 1.2 (фото-сессия: овал, 2 м, голос ассистента; персонаж 2-м шагом)
- 2026-10-21 — этап 1 — доработка 1.1 (сабагенты F/G/H) интегрирована, CI зелёный, ждёт проверки на телефоне
- 2026-10-21 — этап 1 — собран, CI зелёный, ждёт проверки на телефоне
- 2026-10-21 — этап 0 — проверен на телефоне; добавлен веб-предпросмотр (main_preview.dart)
- 2026-10-21 — этап 0 — каркас, дизайн-система, главный экран, CapabilityService, сервер-заготовка, CI зелёный
