// Когда показывать персонажа поверх других приложений (Android, SPEC §9.2):
//  • приложение ушло в фон (paused/hidden) + режим включён (CharacterSystemOverlay.settingKey) +
//    есть разрешение + персонаж выбран → show(аватар);
//  • вернулось (resumed) → hide();
//  • пока свёрнуто: реакции персонажа (characterReactionProvider — их шлёт characterSayProvider) и
//    наступившие сообщения ИИ из кэша AiMessageStore (AiMessageSync.onForeground в фоне молчит) →
//    облачко на ~7 с + аватар в состоянии реакции, затем обратно idle.
//
// Запуск в main: `container.read(systemOverlayControllerProvider).start();`
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/questionnaire_repository.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../core/notifications/ai_messages.dart';
import '../../core/notifications/reminder_texts.dart';
import 'character_reaction.dart';
import 'character_system_overlay.dart';
import 'model/character_profile.dart';
import 'system_overlay_avatar.dart';

class SystemOverlayController {
  SystemOverlayController(this._ref);

  final Ref _ref;

  /// Пауза перед показом: короткие уходы (системный диалог, выбор фото) не дёргают оверлей.
  static const showDelay = Duration(milliseconds: 900);
  static const bubbleDuration = Duration(seconds: 7);
  static const _maxChars = 220;

  AppLifecycleListener? _lifecycle;
  ProviderSubscription<CharacterReaction?>? _reactionSub;
  bool _background = false;
  bool _shown = false;
  int _gen = 0;
  CharacterArchetype? _archetype;
  Timer? _showTimer;
  Timer? _revertTimer;
  Timer? _messageTimer;
  final _avatars = <String, Uint8List>{};
  final _spoken = <String>{};

  CharacterSystemOverlay get _overlay => _ref.read(characterSystemOverlayProvider);
  AppDatabase get _db => _ref.read(databaseProvider);

  void start() {
    if (_lifecycle != null || !_overlay.isSupported) return;
    // Остаток прошлого запуска процесса (Activity пересоздана, пока оверлей висел).
    unawaited(_overlay.hide());
    _lifecycle = AppLifecycleListener(onStateChange: _onLifecycle);
    _reactionSub = _ref.listen<CharacterReaction?>(characterReactionProvider, (_, r) {
      if (r != null) _onReaction(r);
    });
  }

  void dispose() {
    _cancelTimers();
    _lifecycle?.dispose();
    _lifecycle = null;
    _reactionSub?.close();
    _reactionSub = null;
  }

  void _onLifecycle(AppLifecycleState s) {
    switch (s) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _enterBackground();
      case AppLifecycleState.resumed:
        _enterForeground();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  void _enterBackground() {
    if (_background) return;
    _background = true;
    final gen = ++_gen;
    _showTimer?.cancel();
    _showTimer = Timer(showDelay, () => unawaited(_show(gen)));
  }

  void _enterForeground() {
    final wasActive = _background || _shown;
    _background = false;
    _gen++;
    _cancelTimers();
    _shown = false;
    if (wasActive) unawaited(_overlay.hide());
  }

  bool _alive(int gen) => gen == _gen && _background;

  Future<void> _show(int gen) async {
    try {
      final db = _db;
      if (await db.getSetting(CharacterSystemOverlay.settingKey) != 'true') return;
      if (!_alive(gen) || !await _overlay.hasPermission()) return;
      final section = await QuestionnaireRepository(db).read(QuestionnaireSection.character);
      final archetype = archetypeFromName(section['archetype']);
      if (archetype == null || !_alive(gen)) return;
      _archetype = archetype;
      final l = await reminderL10n(db);
      final avatar = await _avatar(CharacterState.idle);
      if (!_alive(gen)) return;
      await _overlay.show(
        avatar: avatar,
        texts: SystemOverlayTexts(
          notificationTitle: l.ovlNotificationTitle,
          notificationBody: l.ovlNotificationBody,
          hideAction: l.ovlHideAction,
          avatarLabel: l.ovlAvatarLabel(archetypeName(l, archetype)),
        ),
      );
      if (!_alive(gen)) {
        // Вернулись, пока показывали.
        unawaited(_overlay.hide());
        return;
      }
      _shown = true;
      unawaited(_armMessages(gen));
    } catch (e) {
      debugPrint('SystemOverlayController: $e');
    }
  }

  // ---------- Реплики ----------

  void _onReaction(CharacterReaction r) {
    if (!_background || !_shown) return;
    unawaited(_present(r.state, r.line));
  }

  Future<void> _present(CharacterState state, String? line) async {
    final gen = _gen;
    final png = await _avatar(state);
    if (!_alive(gen) || !_shown) return;
    if (png != null) unawaited(_overlay.setAvatar(png));
    final t = line?.trim() ?? '';
    if (t.isNotEmpty) {
      final short = t.length > _maxChars ? '${t.substring(0, _maxChars - 1).trimRight()}…' : t;
      unawaited(_overlay.say(short, duration: bubbleDuration));
    }
    _revertTimer?.cancel();
    if (state != CharacterState.idle) {
      _revertTimer = Timer(bubbleDuration, () async {
        if (!_alive(gen) || !_shown) return;
        final idle = await _avatar(CharacterState.idle);
        if (idle != null && _alive(gen) && _shown) unawaited(_overlay.setAvatar(idle));
      });
    }
  }

  /// Таймер до ближайшего сообщения ИИ из кэша (пачка уже загружена AiMessageSync).
  Future<void> _armMessages(int gen) async {
    _messageTimer?.cancel();
    final List<AiMessage> list;
    try {
      list = await AiMessageStore(_db).load();
    } catch (_) {
      return;
    }
    if (!_alive(gen)) return;
    final now = DateTime.now();
    final next = list.where((m) => m.deliverAt.isAfter(now) && !_spoken.contains(m.id)).firstOrNull;
    if (next == null) return;
    _messageTimer = Timer(next.deliverAt.difference(now), () {
      if (!_alive(gen)) return;
      _spoken.add(next.id);
      final state = switch (next.kind) {
        AiMessageKind.reproach => CharacterState.angry,
        AiMessageKind.cheer => CharacterState.happy,
        _ => CharacterState.talk,
      };
      unawaited(_present(state, next.body));
      unawaited(_armMessages(gen));
    });
  }

  Future<Uint8List?> _avatar(CharacterState state) async {
    final a = _archetype;
    if (a == null) return null;
    final key = '${a.name}.${state.name}';
    final cached = _avatars[key];
    if (cached != null) return cached;
    final png = await renderCharacterAvatar(a, state: state);
    if (png != null) _avatars[key] = png;
    return png;
  }

  void _cancelTimers() {
    _showTimer?.cancel();
    _revertTimer?.cancel();
    _messageTimer?.cancel();
    _showTimer = _revertTimer = _messageTimer = null;
  }
}

final systemOverlayControllerProvider = Provider<SystemOverlayController>((ref) {
  final c = SystemOverlayController(ref);
  ref.onDispose(c.dispose);
  return c;
});
