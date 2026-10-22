import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';

/// Реакция персонажа, запрошенная другим модулем.
class CharacterReaction {
  const CharacterReaction(this.state, {this.line, required this.serial, this.voice = true});

  /// Состояние, которое персонаж проиграет (~3 с), затем вернётся к своим делам.
  final CharacterState state;

  /// Реплика в облачке (и озвучка). null — без реплики.
  final String? line;

  /// Озвучить реплику системным TTS голосом персонажа. false — только облачко (например, чат
  /// сам проигрывает серверный TTS).
  final bool voice;

  /// Порядковый номер: одинаковые реакции подряд тоже срабатывают.
  final int serial;
}

/// Публичный способ сыграть реакцию персонажа из любого модуля.
///
/// ```dart
/// ref.read(characterReactionProvider.notifier).react(CharacterState.angry);
/// ref.read(characterSayProvider).say('Ответ ИИ', state: CharacterState.talk);
/// ```
/// Оверлей (CharacterOverlay) слушает провайдер: персонаж просыпается, проигрывает состояние,
/// показывает реплику в облачке и озвучивает её. Если персонаж не выбран или убран в карман —
/// реакция игнорируется.
class CharacterReactionController extends Notifier<CharacterReaction?> {
  var _serial = 0;

  @override
  CharacterReaction? build() => null;

  void react(CharacterState characterState, {String? line, bool voice = true}) {
    state = CharacterReaction(characterState, line: line, voice: voice, serial: ++_serial);
  }
}

final characterReactionProvider =
    NotifierProvider<CharacterReactionController, CharacterReaction?>(CharacterReactionController.new);

/// Сказать реплику персонажем (облачко + озвучка) — для чата (D), сообщений (E) и др.
///
/// ```dart
/// ref.read(characterSayProvider).say(reply);                               // talk + голос
/// ref.read(characterSayProvider).say(text, state: CharacterState.point);  // указывает
/// ref.read(characterSayProvider).say(text, voice: false);                 // только облачко
/// ```
class CharacterSay {
  const CharacterSay(this._controller);

  final CharacterReactionController _controller;

  /// Длинный текст обрезается до [maxChars] (облачко — короткое; полный ответ — в чате).
  void say(String line, {CharacterState state = CharacterState.talk, bool voice = true, int maxChars = 220}) {
    final t = line.trim();
    if (t.isEmpty) return;
    final short = t.length > maxChars ? '${t.substring(0, maxChars - 1).trimRight()}…' : t;
    _controller.react(state, line: short, voice: voice);
  }

  /// Только состояние, без реплики (~3 с).
  void play(CharacterState state) => _controller.react(state);
}

final characterSayProvider =
    Provider<CharacterSay>((ref) => CharacterSay(ref.read(characterReactionProvider.notifier)));
