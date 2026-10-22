// QR-код будильника: показ и «поделиться для печати».
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';

class AlarmQrView extends StatelessWidget {
  const AlarmQrView({super.key, required this.code, this.size = 200});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(SysDims.radius)),
        child: QrImageView(data: code, size: size, backgroundColor: Colors.white),
      );
}

/// PNG с кодом (белое поле для печати) → системный «Поделиться».
Future<void> shareAlarmQr(BuildContext context, String code, {Rect? origin}) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final painter = QrPainter(data: code, version: QrVersions.auto, gapless: true);
    const qrSize = 900.0, pad = 90.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(const Rect.fromLTWH(0, 0, qrSize + pad * 2, qrSize + pad * 2), Paint()..color = Colors.white);
    canvas.translate(pad, pad);
    painter.paint(canvas, const Size(qrSize, qrSize));
    final image = await recorder.endRecording().toImage((qrSize + pad * 2).toInt(), (qrSize + pad * 2).toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('png');
    final bytes = data.buffer.asUint8List();
    final XFile file;
    if (kIsWeb) {
      file = XFile.fromData(bytes, name: 'alarm-qr.png', mimeType: 'image/png');
    } else {
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}${Platform.pathSeparator}sistema-alarm-qr.png');
      await f.writeAsBytes(bytes, flush: true);
      file = XFile(f.path, name: 'sistema-alarm-qr.png', mimeType: 'image/png');
    }
    await SharePlus.instance.share(ShareParams(files: [file], text: l.almQrShareText, sharePositionOrigin: origin));
  } catch (e) {
    debugPrint('shareAlarmQr: $e');
    messenger?.showSnackBar(SnackBar(content: Text(l.almQrShareFailed)));
  }
}
