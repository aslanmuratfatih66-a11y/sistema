// Заглушка этапа 7 — реализует сабагент.
import 'package:flutter/material.dart';

class ReceiptInputScreen extends StatelessWidget {
  const ReceiptInputScreen({super.key, this.mode});

  /// 'qr' | 'photo'.
  final String? mode;

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}
