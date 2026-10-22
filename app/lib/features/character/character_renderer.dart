// Единый интерфейс отрисовки персонажа (SPEC §9.2): состояние + направление + размер.
// Текущая реализация — векторная (CharacterView/CharacterPainter). Профессиональные ассеты (Rive или
// спрайт-листы) подключаются новой реализацией CharacterRenderer без переделки оверлея и экранов.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import 'character_view.dart';

/// Что нарисовать: кто, в каком состоянии, куда смотрит, какого размера.
@immutable
class CharacterRenderSpec {
  const CharacterRenderSpec({
    required this.archetype,
    this.state = CharacterState.idle,
    this.facingLeft = false,
    this.height = 160,
  });

  final CharacterArchetype archetype;

  /// idle, walk, talk, happy, angry, sit, sleep, point — все обязаны поддерживаться.
  final CharacterState state;
  final bool facingLeft;

  /// Высота в логических пикселях; ширина — [CharacterRenderer.widthFor].
  final double height;
}

/// Отрисовщик персонажа. Виджет сам анимирует состояние по кругу и плавно переходит между
/// состояниями; при «Уменьшении движения» — статичная поза.
abstract interface class CharacterRenderer {
  /// Ширина персонажа при высоте [height] (для раскладки оверлея).
  double widthFor(double height);

  Widget build(CharacterRenderSpec spec, {Key? key});
}

/// Векторная рисовка в коде (этап 1) — реализация по умолчанию.
class VectorCharacterRenderer implements CharacterRenderer {
  const VectorCharacterRenderer();

  @override
  double widthFor(double height) => CharacterView.widthFor(height);

  @override
  Widget build(CharacterRenderSpec spec, {Key? key}) => CharacterView(
        key: key,
        archetype: spec.archetype,
        state: spec.state,
        height: spec.height,
        facingLeft: spec.facingLeft,
      );
}

// TODO(rive): RiveCharacterRenderer implements CharacterRenderer — артборд на архетип
// (assets/character/<archetype>.riv), state machine с входом `state` (индекс CharacterState)
// и `facingLeft` (bool; иначе Transform.flip). Без пакета rive в pubspec — не подключаем.
// Переключение: override characterRendererProvider (или выбор по наличию ассета архетипа).

/// Текущий отрисовщик персонажа (оверлей; экраны выбора могут тоже брать его).
final characterRendererProvider = Provider<CharacterRenderer>((ref) => const VectorCharacterRenderer());
