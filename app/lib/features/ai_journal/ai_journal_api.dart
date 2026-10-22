// Расходы ИИ и журнал действий ИИ (SPEC §9.1). Только через aiGatewayProvider.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_api.dart';

class AiTaskUsage {
  const AiTaskUsage(this.task, this.usd, this.calls);
  final String task;
  final double usd;
  final int calls;
}

class AiUsage {
  const AiUsage({
    required this.monthUsd,
    required this.budgetUsd,
    required this.dayUsd,
    required this.degraded,
    required this.byTask,
  });

  factory AiUsage.fromJson(Map<String, dynamic> j) => AiUsage(
        monthUsd: _num(j['month_usd']),
        budgetUsd: _num(j['budget_usd']),
        dayUsd: _num(j['day_usd']),
        degraded: j['degraded'] == true,
        byTask: [
          for (final t in (j['by_task'] as List? ?? const []))
            if (t is Map) AiTaskUsage('${t['task']}', _num(t['usd']), _num(t['calls']).round()),
        ]..sort((a, b) => b.usd.compareTo(a.usd)),
      );

  final double monthUsd;
  final double budgetUsd;
  final double dayUsd;
  final bool degraded;
  final List<AiTaskUsage> byTask;
}

class AiAction {
  const AiAction({
    required this.id,
    required this.tool,
    required this.summary,
    required this.at,
    this.undoneAt,
    required this.canUndo,
  });

  factory AiAction.fromJson(Map<String, dynamic> j) => AiAction(
        id: '${j['id']}',
        tool: '${j['tool'] ?? ''}',
        summary: '${j['summary'] ?? ''}',
        at: DateTime.fromMillisecondsSinceEpoch(_num(j['at']).round()),
        undoneAt: j['undone_at'] == null ? null : DateTime.fromMillisecondsSinceEpoch(_num(j['undone_at']).round()),
        canUndo: j['can_undo'] == true,
      );

  final String id;
  final String tool;
  final String summary;
  final DateTime at;
  final DateTime? undoneAt;
  final bool canUndo;
}

double _num(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

class AiJournalApi {
  const AiJournalApi(this._gateway);

  final AiGateway _gateway;

  Future<AiUsage> usage() async => AiUsage.fromJson(await _gateway.json('GET', '/api/v1/ai/usage'));

  Future<List<AiAction>> actions({int limit = 50}) async {
    final j = await _gateway.json('GET', '/api/v1/ai/actions', query: {'limit': '$limit'});
    return [
      for (final a in (j['actions'] as List? ?? const []))
        if (a is Map<String, dynamic>) AiAction.fromJson(a),
    ];
  }

  /// Отменить действие ИИ. Ошибки — [AiException].
  Future<void> undo(String id) => _gateway.json('POST', '/api/v1/ai/actions/${Uri.encodeComponent(id)}/undo');
}

final aiJournalApiProvider = Provider<AiJournalApi>((ref) => AiJournalApi(ref.watch(aiGatewayProvider)));

final aiUsageProvider = FutureProvider.autoDispose<AiUsage>((ref) => ref.watch(aiJournalApiProvider).usage());

final aiActionsProvider =
    FutureProvider.autoDispose<List<AiAction>>((ref) => ref.watch(aiJournalApiProvider).actions());

/// Id действий, отменённых в этой сессии (чат и журнал показывают «Отменено» без перезапроса).
final undoneAiActionsProvider = NotifierProvider<UndoneAiActions, Set<String>>(UndoneAiActions.new);

class UndoneAiActions extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void add(String id) => state = {...state, id};
}
