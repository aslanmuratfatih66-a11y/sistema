// КАРКАС: заглушка. Реализует сабагент A.
import 'package:flutter/widgets.dart';

import 'sys_icon.dart';

class SysNavItem {
  const SysNavItem({required this.glyph, required this.label});
  final SysGlyph glyph;
  final String label;
}

/// Нижняя навигация в стиле системной панели (учитывает safe area снизу).
class SysBottomNav extends StatelessWidget {
  const SysBottomNav({super.key, required this.items, required this.currentIndex, required this.onTap});

  final List<SysNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => const SizedBox(height: 64);
}
