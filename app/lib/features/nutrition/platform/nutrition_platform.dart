// Камера и галерея для питания — за интерфейсами (в тестах недоступны, подменяются провайдерами).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';

/// Сканер штрихкода: возвращает код или null (отмена / нет камеры).
abstract interface class BarcodeScanner {
  Future<String?> scan(BuildContext context);
}

/// Фото еды: путь к временному файлу или null.
abstract interface class FoodPhotoPicker {
  Future<String?> pick({required bool camera});
}

class ImagePickerFoodPhotoPicker implements FoodPhotoPicker {
  const ImagePickerFoodPhotoPicker();

  @override
  Future<String?> pick({required bool camera}) async {
    final file = await ImagePicker().pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    return file?.path;
  }
}

/// Экран со сканером mobile_scanner (EAN/UPC).
class MobileBarcodeScanner implements BarcodeScanner {
  const MobileBarcodeScanner();

  @override
  Future<String?> scan(BuildContext context) =>
      Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const _ScannerPage()));
}

class _ScannerPage extends StatefulWidget {
  const _ScannerPage();

  @override
  State<_ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<_ScannerPage> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA, BarcodeFormat.upcE],
  );
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final b in capture.barcodes) {
      final v = b.rawValue?.trim();
      if (v != null && v.isNotEmpty) {
        _done = true;
        Navigator.of(context).pop(v);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: SysColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l.nutScanNoCamera, style: SysText.secondary, textAlign: TextAlign.center),
              ),
            ),
          ),
          // Рамка прицела.
          Center(
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: SysColors.accentLighter, width: 2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: l.commonClose,
                        constraints: const BoxConstraints(minWidth: SysDims.minTap, minHeight: SysDims.minTap),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const SysIcon(SysGlyph.close, size: 22),
                      ),
                      const SizedBox(width: 4),
                      Expanded(child: Text(l.nutScanTitle.toUpperCase(), style: SysText.heading)),
                    ],
                  ),
                  const Spacer(),
                  Text(l.nutScanHint, style: SysText.secondary, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final barcodeScannerProvider = Provider<BarcodeScanner>((ref) => const MobileBarcodeScanner());

final foodPhotoPickerProvider = Provider<FoodPhotoPicker>((ref) => const ImagePickerFoodPhotoPicker());
