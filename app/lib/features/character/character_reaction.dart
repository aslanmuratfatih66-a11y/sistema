import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';

/// Реакция персонажа, запрошенная другим модулем.
class CharacterReaction {
  const CharacterReaction(this.state, {this.line, required this.serial});

  /// Состояние, которое персонаж проиграет (~3 с), затем вернётся к своим делам.
  final CharacterState state;

  /// Реплика в облачке (и озвучка). null — без реплики.
  final String? line;

  /// Порядковый номер: одинаковые реакции подряд тоже срабатывают.
  final int serial;
}

/// Публичный способ сыграть реакцию персонажа из любого модуля.
///
/// ```dart
/// // Квест выполнен (этап 2):
/// ref.read(characterReactionProvider.notifier).react(CharacterState.happy, line: l.questDoneLine);
/// // Провал:
/// ref.read(characterReactionProvider.notifier).react(CharacterState.angry);
/// ```
/// Оверлей (CharacterOverlay) слушает провайдер: персонаж просыпается, проигрывает состояние,
/// показывает реплику в облачке и озвучивает её. Если персонаж не выбран или убран в карман —
/// реакция игнорируется.
class CharacterReactionController extends Notifier<CharacterReaction?> {
  var _serial = 0;

  @override
  CharacterReaction? build() => null;

  void react(CharacterState characterState, {String? line}) {
    state = CharacterReaction(characterState, line: line, serial: ++_serial);
  }
}

final characterReactionProvider =
    NotifierProvider<CharacterReactionController, CharacterReaction?>(CharacterReactionController.new);
