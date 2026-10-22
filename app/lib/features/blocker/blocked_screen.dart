// Заглушка этапа 7 — реализует сабагент.
import 'package:flutter/material.dart';

class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key, this.app});

  /// appId из sistema://app/blocked?app=….
  final String? app;

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}
