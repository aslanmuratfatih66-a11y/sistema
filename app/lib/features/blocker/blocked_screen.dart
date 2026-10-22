// Заглушка «Система: отбой» (SPEC §8.6). Открывается по sistema://app/blocked?app=<id> из автоматизации
// «Команд» (iOS). Сама решает: блок сейчас (режим дисциплины + после отбоя) → заглушка и попытка (+ штраф
// с 3-й за ночь); иначе — «Сейчас можно» и возврат.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/data/questionnaire_repository.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../core/notifications/reminder_texts.dart';
import '../../domain/discipline/app_blocker_catalog.dart';
import '../../domain/discipline/app_blocker_repository.dart';
import '../../domain/discipline/app_blocker_sync.dart';
import '../../domain/discipline/app_blocker_window.dart';
import '../../domain/quests/quest_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../character/character_view.dart';
import '../character/model/character_profile.dart';

/// Ключ попытки без ?app= (автоматизация без параметра).
const _unknownApp = 'unknown';

class BlockedScreen extends ConsumerStatefulWidget {
  const BlockedScreen({super.key, this.app});

  /// appId из sistema://app/blocked?app=….
  final String? app;

  @override
  ConsumerState<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends ConsumerState<BlockedScreen> {
  bool _checking = true;
  BlockWindow? _window;
  BlockAttemptResult? _result;
  Timer? _autoClose;

  String get _appId {
    final a = widget.app?.trim();
    return a == null || a.isEmpty ? _unknownApp : a;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_check());
  }

  @override
  void dispose() {
    _autoClose?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    final db = ref.read(databaseProvider);
    QuestService? quests;
    try {
      quests = ref.read(questServiceProvider);
    } catch (_) {
      quests = null;
    }
    BlockWindow? window;
    BlockAttemptResult? result;
    if (quests != null) {
      try {
        window = await currentBlockWindow(db: db, quests: quests);
        if (window != null) {
          result = await ref.read(appBlockerRepositoryProvider).recordAttempt(
                _appId,
                at: DateTime.now(),
                night: window,
              );
        }
      } catch (e) {
        debugPrint('blocked: $e');
      }
    }
    if (!mounted) return;
    setState(() {
      _checking = false;
      _window = window;
      _result = result;
    });
    if (window == null) {
      _autoClose = Timer(const Duration(seconds: 2), _leave);
    }
  }

  void _leave() {
    if (!mounted) return;
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.status);
    }
  }

  String? _appName(AppLocalizations l) {
    if (_appId == iosGamesAppId) return l.blkIosGames;
    return iosBlockerAppName(_appId);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final character = ref.watch(questionnaireSectionProvider(QuestionnaireSection.character)).value ?? const {};
    final archetype = archetypeFromName(character['archetype']);
    final window = _window;

    final Widget content;
    if (_checking) {
      content = Text(l.blkChecking, style: SysText.secondary, textAlign: TextAlign.center);
    } else if (window == null) {
      content = SysPanel(
        key: const Key('blk-allowed'),
        title: l.blkBlockedLabel,
        tone: PanelTone.success,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.blkAllowedTitle.toUpperCase(), style: SysText.title),
            const SizedBox(height: 8),
            Text(l.blkAllowedMessage, style: SysText.secondary),
            const SizedBox(height: 14),
            SysButton.secondary(label: l.blkClose, onPressed: _leave, expand: true),
          ],
        ),
      );
    } else {
      content = _BlockedPanel(
        window: window,
        appName: _appName(l),
        result: _result,
        onClose: _leave,
      );
    }

    final attempts = _result?.attemptsTonight ?? 0;
    return Scaffold(
      backgroundColor: SysColors.background,
      body: SystemBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (archetype != null && window != null) ...[
                    Center(
                      child: CharacterView(
                        archetype: archetype,
                        state: attempts >= blockPenaltyFromAttempt ? CharacterState.angry : CharacterState.sleep,
                        height: 150,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (archetype == null && window != null) ...[
                    const Center(child: SysIcon(SysGlyph.moon, size: 64, color: SysColors.accentLight)),
                    const SizedBox(height: 16),
                  ],
                  content,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BlockedPanel extends ConsumerWidget {
  const _BlockedPanel({required this.window, required this.appName, required this.result, required this.onClose});

  final BlockWindow window;
  final String? appName;
  final BlockAttemptResult? result;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final time = reminderTime(window.until);
    final name = appName;
    final count = ref.watch(_attemptCountProvider(window)).value ?? result?.attemptsTonight ?? 1;
    final penalty = result?.penalty ?? 0;
    return SysPanel(
      key: const Key('blk-blocked'),
      title: l.blkBlockedLabel,
      tone: PanelTone.danger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text(l.blkBlockedTitle.toUpperCase(), style: SysText.heading)),
          const SizedBox(height: 10),
          Text(
            name == null ? l.blkBlockedMessage(time) : l.blkBlockedMessageApp(name, time),
            style: SysText.body,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SysPill(label: l.blkAttemptsTonight(count), tone: PanelTone.danger, icon: SysGlyph.warning),
              if (penalty > 0)
                SysPill(label: l.blkPenaltyApplied('$penalty'), tone: PanelTone.danger, icon: SysGlyph.diamond),
            ],
          ),
          if (count < blockPenaltyFromAttempt) ...[
            const SizedBox(height: 10),
            Text(l.blkPenaltyWarning('$blockPenaltyDiamonds'), style: SysText.caption),
          ],
          const SizedBox(height: 16),
          SysButton.primary(label: l.blkClose, onPressed: onClose, expand: true),
        ],
      ),
    );
  }
}

final _attemptCountProvider = StreamProvider.autoDispose.family<int, BlockWindow>(
  (ref, w) => ref.watch(appBlockerRepositoryProvider).watchAttemptCount(w.from, w.until),
);
