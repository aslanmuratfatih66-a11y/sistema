// Заглушка этапа 7 — реализует сабагент.
import 'package:flutter/material.dart';

class AlarmRingScreen extends StatelessWidget {
  const AlarmRingScreen({super.key, this.alarmId});

  final String? alarmId;

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}
