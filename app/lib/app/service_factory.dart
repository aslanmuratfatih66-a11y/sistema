// Создание сервисов вне дерева виджетов: main и фоновые isolate'ы (кнопки уведомлений, BGAppRefresh).
// Правит главный агент; реализацию движка подключает при интеграции этапа 2.
import '../core/db/database.dart';
import '../domain/quests/quest_api.dart';

/// Движок квестов поверх [db]. В фоне вызывается с собственным экземпляром БД.
QuestService createQuestService(AppDatabase db) =>
    throw UnimplementedError('createQuestService: подключается при интеграции этапа 2');
