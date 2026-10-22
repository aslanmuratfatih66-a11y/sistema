// Чек по фото (SPEC §8.7, §9.4): ИИ разбирает магазин, позиции и сумму; результат — в PhotoAnalyses (kind=receipt).
// Запись в финансы — features/finance_input (ReceiptInputScreen) по возвращённому результату.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../nutrition/nutrition_format.dart';
import 'vision_api.dart';
import 'vision_common.dart';
import 'vision_repository.dart';

/// Точка входа: фото чека → разбор → результат. Возвращает разобранный чек (null — отмена/ошибка).
Future<ReceiptResult?> showReceiptFlow(BuildContext context) async {
  final read = ProviderScope.containerOf(context, listen: false).read;
  final path = await pickVisionPhoto(context, read);
  if (path == null || !context.mounted) return null;
  final photo = await storeVisionPhoto(read, path, PhotoKind.receipt);
  if (!context.mounted) return null;
  final result = await Navigator.of(context).push<ReceiptResult>(MaterialPageRoute(
    builder: (_) => ReceiptScreen(photoPath: path, photoId: photo.id),
  ));
  if (result == null) await dropVisionPhoto(read, photo);
  return result?.withPhoto(photo.id);
}

class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({super.key, required this.photoPath, this.photoId});

  final String photoPath;
  final String? photoId;

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  Object? _error;
  ReceiptResult? _result;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    setState(() {
      _error = null;
      _result = null;
    });
    final lang = visionLang(context);
    try {
      final reply = await ref.read(visionApiProvider).receipt(await encodeVisionImage(widget.photoPath), lang);
      if (!_saved) {
        await ref.read(photoAnalysisRepositoryProvider).add(VisionKind.receipt, reply.raw, photoId: widget.photoId);
        _saved = true;
      }
      if (mounted) setState(() => _result = reply.value);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = _result;
    final Widget body;
    if (_error != null) {
      body = VisionError(error: _error!, onRetry: _run);
    } else if (r == null) {
      body = const VisionBusy();
    } else {
      final money = NumberFormat.currency(locale: l.localeName, name: r.currency, symbol: '${r.currency} ', decimalDigits: 2);
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanel(
            title: l.visReceiptTitle,
            trailing: const EstimateBadge(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (r.store.isNotEmpty) VisionRow(label: l.visReceiptStore, value: r.store),
                if (r.date != null) VisionRow(label: l.visReceiptDate, value: DateFormat.yMMMd(l.localeName).format(r.date!)),
                const SizedBox(height: 8),
                for (final it in r.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            it.qty == 1 ? it.name : '${it.name} × ${fmt1(l, it.qty)}',
                            style: SysText.body,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(money.format(it.price), style: SysText.mono),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                VisionRow(label: l.visFoodTotal, value: money.format(r.total)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(l.visReceiptFinanceLater, style: SysText.caption),
          const SizedBox(height: 12),
          SysButton.primary(label: l.visDone, expand: true, onPressed: () => Navigator.of(context).pop(r)),
        ],
      );
    }
    return NutPage(title: l.visReceiptTitle, child: body);
  }
}
