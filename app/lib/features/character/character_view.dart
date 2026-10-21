// КОНТРАКТ каркаса: отрисовка персонажа. Реализует сабагент F (векторно в коде; позже — Rive
// за тем же интерфейсом). Публичное API менять нельзя, можно добавлять параметры со значениями по умолчанию.
import 'package:flutter/widgets.dart';

import '../../core/models/enums.dart';

class CharacterView extends StatelessWidget {
  const CharacterView({
    super.key,
    required this.archetype,
    this.state = CharacterState.idle,
    this.height = 160,
    this.facingLeft = false,
  });

  final CharacterArchetype archetype;
  final CharacterState state;

  /// Высота персонажа в логических пикселях; ширина — по пропорциям.
  final double height;
  final bool facingLeft;

  @override
  Widget build(BuildContext context) => SizedBox(height: height, width: height * .6);
}
