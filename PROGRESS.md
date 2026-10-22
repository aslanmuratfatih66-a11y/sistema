# PROGRESS

## Сейчас
Этап: 0.5 — Предпросмотр с hot reload (доработки по обновлённому SPEC/STAGES, 2026-10-22)
Статус: доработки этапа 2 (§8.13, §8.17) готовы, CI зелёный (коммит eb2ea10) — ждёт проверки на телефоне
Следующий шаг: зелёный CI доработок этапа 2 (починить, если красный) → проверка на телефоне; дальше — этап 6 без ключей (свободная ходьба, формы персонажа, загрузка GLB/VRM) или ИИ после данных о прокси
Этап 0.5 итог: main_preview.dart (ProviderContainer с веб-заглушками lib/preview/preview_fakes.dart), демо-данные lib/preview/demo_data.dart (флаг preview.demoSeeded), устройства iPhone 15 Pro / Pixel 9 / Galaxy S25 (Alt+1/2/3, платформа по устройству), Alt+L ru/tr, Alt+T шрифт 1.0/1.3/1.5, Alt+R сброс демо; README.md «Предпросмотр»; все маршруты открываются в headless Chrome без исключений
Порядок (решение владельца): 0.5 → доработки этапа 2 (§8.13 режимы дня, §8.17 привычки) → этапа 5 (swap/проверка памяти в install.sh, MemoryMax=300M, очередь фото) → этапа 6 (ai.yaml, две роли, карточки, aibench, $27, свободная ходьба, GLB/VRM, формы, characters_private) → этап 9. После КАЖДОГО шага: зелёный CI, короткий отчёт, пауза на проверку на телефоне. Ключей ИИ нет — всё ИИ на шаблонах. МИРЭА — в самом конце.

## Этап 8 — чек-лист
- [x] B Оверлей персонажа Android: OverlayService (specialUse) + OverlayBubble (аватар 64dp, перетаскивание, облачко 7 с), SystemOverlayController (показ при сворачивании, реплики/сообщения ИИ), переключатель в «Ещё» (SystemOverlaySettingsTile)
- [x] C Полировка: ui/components/states.dart (SysLoader, SysSkeleton*, SysEmptyState, SysErrorState, SysIconButton, SysBackButton, SysPressable, sysReduceMotion), features/common/ai_error_view.dart (AiErrorView), новые SysGlyph (camera, cameraSwitch, …), доступность (подсказки, зоны 44+, шрифт ×1.5), select вместо watch
- [x] D Турецкий: 216 правок, глоссарий (siz в интерфейсе, sen — голос персонажа; puan, görev, rütbe, disiplin modu…); iOS: tr.lproj/ru.lproj InfoPlist.strings (описания разрешений, «Sistem»)
- [x] Интеграция B/C/D
- [x] CI зелёный (analyze-test 533 теста, ios, android, server)
- [ ] A МИРЭА (в самом конце, вариант не выбран)
- [ ] Финальный прогон тестов, сборка, отчёт

## Этап 7 — чек-лист
- [x] Каркас: БД v7 (FinAccounts, FinCategories, FinTransactions, FinBudgets, FinGoals, FinSubscriptions, FinDebts, CryptoHoldings, BankInbox, MarketItems, BlockedApps, BlockAttempts, Alarms, AlarmRuns), enums (FinAccountKind, FinTxKind, FinTxSource, MarketBudget, AlarmTask); QuestService.award (◆ вне квестов, идемпотентно по ref); контракты domain/finance/finance_api.dart (FinanceLedger, FxRatesSource, BudgetAdvisor), core/security/app_lock.dart, core/alarm/alarm_api.dart; маршруты /finance /finance/receipt /finance/banks /finance/statement /market /blocker /blocked /alarms /alarm/ring (заглушки); local_auth, sensors_plus; Info.plist: NSFaceIDUsageDescription, NSAlarmKitUsageDescription; AlarmKitChannel.swift (заготовка, в pbxproj); сервер: ai.Document (PDF), пакеты finance/market (контракт эндпоинтов в doc-комментарии), проводка в main.go
- [x] A Финансы — ядро: счета/крипта/операции/категории/лимиты (ИИ-предложение ≥14 дней)/цели/подписки/долги/отчёты fl_chart + комментарий ИИ, LocalFinanceLedger (дедуп uuid v5 от ref, налог на фастфуд, лимиты → award), CachedFxRatesSource, LocalBudgetAdvisor, AppLockGate (биометрия/PIN)
- [x] B Финансы — ввод: QR ФНС (сумма/дата из QR, позиции — TODO ФНС), фото чека, уведомления/SMS банков (шаблоны RU/TR + ИИ), выписка CSV/PDF; сервер finance: rates (+CoinGecko), bank/parse, statement, receipt/qr, budget/suggest, report/comment
- [x] C Маркет: подборка ИИ с веб-поиском цен (кэш 3 дня), ссылки на поиск магазинов, пометка бюджета, «купил» → операция
- [x] D Блокировка: Android UsageStats + оверлей (BlockerService specialUse), iOS мастер «Команд» + sistema://app/blocked?app=…, штраф с 3-й попытки за ночь, DisciplineBlockerSync
- [x] E Будильник: AlarmManager.setAlarmClock + full-screen + AlarmRingService; AlarmKit (iOS 26) + страховочная серия уведомлений; приседания (акселерометр) или QR; награда за подъём; будильник дисциплины
- [x] Интеграция: манифест (SMS, usage stats, overlay, FGS specialUse/mediaPlayback, exact alarm, full-screen; сервисы/ресиверы Bank*/Blocker*/Alarm*), MainActivity (каналы, onNewIntent), main (overrides финансов/AppLock/блокировки/будильника, запуск BankInbox/BlockerSync/AlarmSync), AppLockGate в builder (SistemaApp(appLock:true)), reminder_filters.dart (упрёки ИИ + напоминания подписок/долгов 'fin:'), «Ещё»: Финансы/Маркет/Будильник/Блокировка + сводка финансов, url_launcher, photoId в ReceiptResult
- [x] CI зелёный (analyze-test, ios, android, server)

## Этап 6 — итог
A–F + интеграция, CI зелёный (run 39704046010 app, 39704046012 server).

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
- 2026-10-22 (владелец): награды за уровни (◆, титулы, формы/скины, функции, монстры-боссы) — таблица в конфиге; тап по LVL на главном → экран «Путь уровней» (вертикальная дорога, пройденные/текущий/будущие, награды, прогресс опыта) — SPEC §6
- 2026-10-22 (владелец): персонаж — тап = короткая реплика (облачко + голос), НЕ чат; удержание 3 с с индикатором → живой голосовой разговор с ИИ без кнопок + текстовая лента, выход кнопкой/жестом, текстовый чат доступен оттуда — SPEC §9.2
- 2026-10-22 (владелец): «Магазин» — вкладка с переключателем «За баллы» / «Покупки» (маркет ИИ, бюджет, ссылки, список покупок); маркет убрать из настроек, там только параметры (магазины, бюджет) — SPEC §6, §8.8
- 2026-10-22 (владелец): аудит навигации — схему показать ДО реализации; п.1–3 делать после «ок» владельца — SPEC §4
- 2026-10-22 (владелец): схема навигации docs/navigation.md принята «как предложено»: Статус · Квесты · Здоровье [Питание|Тренировки|Тело|Прогулки] · Магазин [За баллы|Покупки] · Ещё (хаб); настройки — отдельный экран /settings; быстрые действия на главном; финансы — в «Ещё»
- Путь уровней: таблица наград GameConfig.levelRewards (◆, форма/скин, функция, монстр-босс) + levelTitles (добавлены титулы 5/20/35/75/100); ◆ за уровень начисляются один раз (событие bonus id levelReward:N). Формы/функции/боссы пока только подписи (TODO: блокировка функций и модели — с их разделами). Экран /levels — по нажатию на LVL
- Персонаж: тап — tapLine (облачко + голос, по режиму мотивации); удержание 3 с (кольцо вокруг, вибро) → /talk (LiveTalkScreen: слушает → ответ ИИ голосом → слушает; лента = история чата; 3 пустых прослушивания → пауза; «Текст» → /chat; выход — крестик/смахивание вниз). Меню по удержанию убрано, «в карман» — свайп вниз. Для экранного диктора удержание = семантическое долгое нажатие
- Режимы дня (§8.13): domain/day_modes — настройки/занятость/адаптивность в UserSettings (dayModes, dayBusy, dayAdaptive). Занятость (пары/работа/дорога из расписания + «занят N ч») сдвигает pending-квесты дня на конец занятости до tick (ReminderCoordinator.beforeTick), напоминания в занятость — тихие (reminder_filters). Автоплан — с 8 уровня (награда пути) или сам в дисциплине; вкладка «Квесты» показывает одно текущее задание. Адаптивная сложность: раз в 7 дней по выполнению за 14 дней (≥10 закрытых): ≥85% → +1 шаг, ≤55% → −1, шаг −2…+2 = ±10%/шаг минут учёбы/тренировок плана (тренировки ≤+10%), база в params.baseMinutes/baseTarget. Количество квестов не меняется (TODO). Итоги дня — /day-summary, уведомление за 30 мин до отбоя (instanceId 'summary:…'), озвучка шаблоном
- Привычки (§8.17): UserSettings 'habits' (JSON), «Квесты» → «Привычки»; серии 1/3/7/14/30/60/90/180/365 дн. → ◆ через QuestService.award (ref с началом серии), срыв −3 ◆ с триггером, экономия ₽/день, ссылка на помощь (8-800-200-0-200 / ALO 171 — номера по памяти, проверить)
- Владелец 2026-10-22: CI после каждого шага не обязателен — шаги подряд, CI пачкой в фоне
- Реализация: встроенные во вкладку страницы (EmbeddedTab) не рисуют свою шапку; разделы вкладки держат состояние (IndexedStack). Параметры покупок (магазины, бюджет ₽/мес) — AppSettings market.stores / market.monthBudgetRub, уходят в контекст подбора (stores, budget_month_rub); товар дороже бюджета — «не по бюджету». Список покупок — в «Покупках»
- 2026-10-22: порядок изменён владельцем — сначала ИИ (доработки этапа 6), потом этапы 2 и 5; ключи Anthropic и Google у владельца есть (кладёт сам в /opt/sistema/.env)
- Деплой (2026-10-22, сделан агентом по просьбе владельца): сервер 2.27.127.53 (Debian 13, root по ключу ~/.ssh/id_ed25519), /opt/sistema, 127.0.0.1:8087, юнит sistema.service. HTTPS: https://sistema.2.27.127.53.sslip.io — по образцу других сайтов владельца: nginx stream SNI-маршрутизатор (/etc/nginx/stream.d/sistema-domain.map → 127.0.0.1:8449, proxy_protocol), сайт /etc/nginx/sites-available/sistema (+ sistema-http для acme и редиректа), сертификат acme.sh (webroot /var/www/acme) → /etc/nginx/certs/sistema.{pem,key}, автопродление cron acme.sh. Чужие конфиги не менялись. На сервере ещё: rtu, nika, ots, forum, mafia, multiki, docker — не трогать
- Адрес сервера в сборке: GitHub variable SISTEMA_SERVER_URL → --dart-define в .github/workflows/app.yml (в код не зашит — репо публичный)
- МИРЭА: на сервере владельца уже есть rtu.service «RTU: дедлайны и БРС — Telegram-бот и сайт» (вход в «Пульс») — при работе над МИРЭА спросить владельца, можно ли переиспользовать
- Предпросмотр: `flutter run -d chrome -t lib/main_preview.dart` (app/); шрифт — Alt+T (Alt+F занят Chrome); Alt+R очищает таблицы и перезагружает страницу; lib/preview/ и device_preview не импортируются из main.dart
- 2026-10-22: SPEC.md слит с новой версией владельца: добавлены §8.13–8.20, свободная ходьба и формы персонажа (§9.2), приватные модели (characters_private в .gitignore), таблица моделей ИИ (ai.yaml) и лимит $27, роли аналитик/персонаж, карточки персонажей, слепой тест aibench, очередь фото и проверка памяти/swap (§10). Сохранены прежние решения: короткая вкладка «Статус»; персонаж — 2-й шаг анкеты; голосовая фото-сессия без нажатий на ~2 м; обхваты необязательны; векторные персонажи в коде (до присланных моделей) + системный TTS как запасной
- 2026-10-22: порядок доработок — по шагам с паузой на проверку на телефоне после каждого (см. «Сейчас»); все принятые решения дублировать здесь
- 2026-10-22: ключей ИИ нет — новые ИИ-функции работают на шаблонах без ошибок
- МИРЭА (исследование этапа 8): расписание — официальный schedule-of.mirea.ru: GET /schedule/api/search?match=<группа>&limit=N → data[{id, targetTitle, scheduleTarget (1 — группа), iCalLink}], nextPageToken; iCal без входа /schedule/api/ical/1/<id>. Оценки/посещаемость — официального API нет (lk.mirea.ru только логином; варианты: ручной ввод (рекомендация) / не делать / парсинг ЛК). Владелец: «в самом конце»
- Состояния экранов — SysLoader / SysSkeleton* / SysEmptyState / SysErrorState (ui/components/states.dart), ошибки ИИ — features/common/ai_error_view.dart
- Турецкий: интерфейс на «siz», голос персонажа/квесты на «sen»; ◆ = puan
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
- Этап 8: оверлей персонажа может показаться поверх наших же внешних экранов (камера, выбор фото) при уходе >0,9 с; Kotlin Overlay* проверен только сборкой; ru: непоследовательное «ты/вы» (wrk «вы», голос wlk «ты») и мужской род в отметках («Купил», «Лёг»)
- Этап 7: AlarmKit API писался по памяти (риск сборки iOS); FNS — только сумма/дата из QR; SMS-отправители банков TR не подтверждены; тексты банковских уведомлений синхронизируются на сервер; цели — прогресс только по счёту-копилке; погашение долга не привязывает операцию (debtId); забытый PIN (режим «только PIN») не восстановить; Kotlin этапа 7 проверен только сборкой
- Этап 6: FCM-токен — заглушка NoPushTokenSource (нужен google-services.json и firebase_messaging); id моделей Gemini и формат ElevenLabs — сверить при подключении ключей; пояс пользователя для сообщений по умолчанию UTC+3
- Этап 5: фото не скачиваются с сервера на второе устройство (remotePath не заполняется); TOTP нельзя отключить/перевыпустить; защита от повтора TOTP-кода — в памяти; сервер/деплой не проверены вживую — инструкция deploy/README.md
- Этап 4: Spotify — заглушка (нужна регистрация в Spotify Dashboard, Redirect URI); прогулка после перезапуска восстанавливается на паузе; норма шагов виджета — 8000 по умолчанию; Swift/Kotlin этапа 4 проверены только сборкой
- Тело: «сегодня» (bodyClockProvider) не пересчитывается в полночь; дневной сон не записать; удаление фото без подтверждения
- Шаги: Health Connect без приложения-писателя (Google Fit/Samsung Health) даёт 0, фолбэка на датчик нет; датчик не видит шаги до первого опроса за день; CMPedometer — история 7 дней
- Перенос шага «Персонаж» сдвинул индексы шагов анкеты (прогресс хранится индексом) — у незавершённой анкеты шаг может сместиться на 1
- Размер контура тела (75%) подобран расчётом под FOV фронталки ~65° на 2 м — уточнить по телефону
- Камера (экран съёмки с контуром), permission_handler, share_plus/file_picker — не проверены на устройствах
- Даты (рождение, срок цели, якорь недели) хранятся как локальная полночь — при смене пояса на западный могут съехать на день
- Главный экран всё ещё на демо-данных (этап 2 подключит план/расписание: acceptedPlanProvider, ScheduleLogic.dayTimeline)
- permission_handler на iOS: при SPM разрешения включаются по ключам Info.plist (Podfile не нужен). Если в CI появится CocoaPods (плагин без SPM) — нужны макросы PERMISSION_* в Podfile post_install
- Drift в вебе не настроен (нужны sqlite3.wasm + drift_worker.js в app/web/) — пока БД в UI не используется; понадобится, когда экраны начнут читать БД
- iOS Swift (AppDelegate: FlutterImplicitEngineBridge.applicationRegistrar) проверяется только в CI; фолбэк — pluginRegistry.registrar(forPlugin:)?.messenger()
- Визуал не проверен на устройстве (тесты на шрифте Ahem)
- deploy/sistema.service: жёсткий hardening, MemoryMax=256M — проверить на Debian на этапе 5

## CI
Этап 0.5: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39764610352 — зелёный; ipa https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39764610352/artifacts/12420166508 , apk https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39764610352/artifacts/12419394196
Этап 8: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39752642156 — зелёный
- ipa: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39752642156/artifacts/12414104260
- apk: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39752642156/artifacts/12415176326
Этап 7: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39709022096 — зелёный (analyze-test, ios, android); server 39709022039 — зелёный
Этапы 4–5: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39676717162 — зелёный (analyze-test, ios, android, server)
Этап 3: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39652915537 — зелёный
- ipa: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39652915537/artifacts/12369508087
- apk: https://github.com/aslanmuratfatih66-a11y/sistema/actions/runs/39652915537/artifacts/12371475811
Этап 2: run 39647992929 — зелёный

## Что нужно от пользователя
- Ключи ИИ (отложено владельцем 2026-10-22): в sop.txt (в .gitignore) ключи прокси-сервиса `pza_…` (argon/opus), не официальные Anthropic/Google. Нужны от владельца: название сервиса, base URL, формат API → добавить SISTEMA_ANTHROPIC_BASE_URL / SISTEMA_GEMINI_BASE_URL (или OpenAI-совместимый клиент). Фрагмент одного ключа попал в лог — рекомендовано перевыпустить
- Этап 6: ключи в /opt/sistema/.env (SISTEMA_ANTHROPIC_API_KEY, по желанию GEMINI/TTS/NTFY/FCM) — см. deploy/.env.example
- Деплой сервера по deploy/README.md; если порт 443 занят — прислать вывод `sudo ss -ltnp 'sport = :443'`, ничего не трогать
- Сохранить в надёжном месте %USERPROFILE%\sistema-keys (ключ подписи Android)
- После этапа 4–5 — общая проверка на телефоне. Копим список:
  - этап 1: анкета (прервать/продолжить), разрешения, План → Принять, «Ещё»: правка разделов, язык, экспорт/импорт
  - этап 2: квесты (выполнить/+10 мин/отказ удержанием), уведомления с кнопками, тихие часы, окна провала/уровня/штрафа, магазин, дисциплина
  - этап 3: штрихкод (Open Food Facts), фото еды, вода, шаги (разрешение Motion / Health Connect), сон и «Энергия», замеры, фото-дневник, уход за кожей, тренировка с голосом и без гашения экрана
  - фото-сессия: отсчёт без лагов (1.3), совпадение с контуром тела на ~2 м, овал лица, голос ассистента

## История
- 2026-10-22 — этап 8 — оверлей персонажа, полировка, турецкий; CI зелёный; МИРЭА отложена
- 2026-10-22 — этап 7 — финансы, ввод, маркет, блокировка, будильник; интеграция
- 2026-10-22 — этап 6 — ИИ-слой, фото-анализ, персонаж, голос/чат, сообщения наперёд, знания; интеграция
- 2026-10-21 — этап 3 — питание, шаги/расход, тело, тренировки; 459 тестов, CI зелёный
- 2026-10-21 — этап 2 — интеграция A–D, 317 тестов зелёные; начат этап 3 (каркас)
- 2026-10-21 — этап 1 — 1.3: лаг отсчёта (лишние вызовы TTS) исправлен; этап 1 завершён, начат этап 2
- 2026-10-21 — этап 1 — доработка 1.2 (фото-сессия: овал, 2 м, голос ассистента; персонаж 2-м шагом)
- 2026-10-21 — этап 1 — доработка 1.1 (сабагенты F/G/H) интегрирована, CI зелёный, ждёт проверки на телефоне
- 2026-10-21 — этап 1 — собран, CI зелёный, ждёт проверки на телефоне
- 2026-10-21 — этап 0 — проверен на телефоне; добавлен веб-предпросмотр (main_preview.dart)
- 2026-10-21 — этап 0 — каркас, дизайн-система, главный экран, CapabilityService, сервер-заготовка, CI зелёный
