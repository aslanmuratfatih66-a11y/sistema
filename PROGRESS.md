# PROGRESS

## Сейчас
Этап: 3 — Питание, тело, тренировки
Статус: каркас готов, сабагенты A–D в работе
Следующий шаг: дождаться отчётов A–D → интеграция (SectionQuestHooks над QuestService, stepCounterProvider в main, «Статус» на реальных данных питания/шагов/сна) → CI

## Этап 3 — чек-лист
- [x] Каркас: БД v4 (FoodItems, MealEntries, Recipes, WaterLogs, ShoppingItems, StepLogs, SleepLogs, CareChecks, WorkoutPrograms, WorkoutSessions), enums, core/models/daily.dart, core/activity/activity_api.dart, domain/quests/section_hooks.dart; mobile_scanner/http/fl_chart/image_picker/wakelock_plus; Health Connect (minSdk 26, FlutterFragmentActivity, манифест), канал sistema/steps (StepCounterChannel.swift/.kt — заготовки, в pbxproj); маршруты /body /workouts, заглушки
- [ ] 1. Питание §8.2 (A)
- [ ] 2. Шаги и расход (B)
- [ ] 3. Тело: сон, замеры, графики, фото-дневник, уход за кожей (C)
- [ ] 4. Тренировки (D)
- [ ] 5. Интеграция с движком квестов, «Статус» на реальных данных
- [ ] 6. Тесты, CI зелёный, отчёт

## Сабагенты (этап 3)
- A Питание: в работе — app/lib/features/nutrition (l10n_parts/nut_*)
- B Шаги и калории: в работе — app/lib/core/activity, StepCounterChannel.swift/.kt (l10n_parts/act_*)
- C Тело: в работе — app/lib/features/body (l10n_parts/body_*)
- D Тренировки: в работе — app/lib/features/workouts (l10n_parts/wrk_*)

## Этап 2 — итог
Готов: движок квестов, напоминания, экраны квестов и окна, магазин, дисциплина; 317 тестов. CI run 39647992929.

## Этап 1 — итог
Завершён (проверка на телефоне — вместе после этапа 4–5). Анкета 12 шагов, камера/фото-сессия под голос ассистента,
расписание с чередованием недель, черновой план и нормы, настройки, экспорт/импорт JSON; доработки 1.1–1.3 по замечаниям.
Персонажей (рисовку) не трогаем — владелец заменит целиком позже.

## Решения и договорённости
- Этап 2: ◆/опыт/характеристики — только сумма журнала QuestEvents; покупка в магазине — событие purchase (отдельной таблицы Purchase нет); награда/штраф копируются в экземпляр
- StatKind/PlayerRank переехали в core/models/enums.dart (home_view_data их реэкспортирует)
- Виджет-тесты с drift-потоками: БД закрывать через `tester.runAsync(db.close)` после снятия экрана — иначе tearDown под fake async зависает
- Сервисы этапа 2 — через провайдеры-контракты (questServiceProvider, reminderSchedulerProvider), реализация подключается в main
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
Последний run: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39620362058 (app) и …/39620362118 (server) — зелёные
Артефакты:
- ipa: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39620362058/artifacts/12355166165
- apk: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39620362058/artifacts/12354827359

## Что нужно от пользователя
- Сохранить в надёжном месте %USERPROFILE%\sistema-keys (ключ подписи Android)
- После этапа 4–5 — общая проверка на телефоне. Копим список:
  - этап 1: анкета (прервать/продолжить), разрешения, План → Принять, «Ещё»: правка разделов, язык, экспорт/импорт
  - фото-сессия: отсчёт без лагов (1.3), совпадение с контуром тела на ~2 м, овал лица, голос ассистента

## История
- 2026-10-21 — этап 2 — интеграция A–D, 317 тестов зелёные; начат этап 3 (каркас)
- 2026-10-21 — этап 1 — 1.3: лаг отсчёта (лишние вызовы TTS) исправлен; этап 1 завершён, начат этап 2
- 2026-10-21 — этап 1 — доработка 1.2 (фото-сессия: овал, 2 м, голос ассистента; персонаж 2-м шагом)
- 2026-10-21 — этап 1 — доработка 1.1 (сабагенты F/G/H) интегрирована, CI зелёный, ждёт проверки на телефоне
- 2026-10-21 — этап 1 — собран, CI зелёный, ждёт проверки на телефоне
- 2026-10-21 — этап 0 — проверен на телефоне; добавлен веб-предпросмотр (main_preview.dart)
- 2026-10-21 — этап 0 — каркас, дизайн-система, главный экран, CapabilityService, сервер-заготовка, CI зелёный
