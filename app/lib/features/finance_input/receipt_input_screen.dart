// Чек → операция (SPEC §8.7): QR ФНС (сумма/дата из QR, позиции — если сервер их вернул) или фото (ИИ-разбор).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/models/enums.dart';
import '../../domain/finance/finance_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../nutrition/nutrition_format.dart';
import '../vision/receipt_flow.dart';
import 'fni_api.dart';
import 'fni_common.dart';
import 'fni_parsers.dart';

class ReceiptInputScreen extends ConsumerStatefulWidget {
  const ReceiptInputScreen({super.key, this.mode});

  /// 'qr' | 'photo'.
  final String? mode;

  @override
  ConsumerState<ReceiptInputScreen> createState() => _ReceiptInputScreenState();
}

/// Черновик чека для предпросмотра.
class _Receipt {
  const _Receipt({
    required this.kind,
    required this.total,
    required this.currency,
    required this.at,
    required this.source,
    this.store,
    this.items = const [],
    this.ref,
    this.itemsFromServer = false,
  });

  final FinTxKind kind;
  final int total;
  final String currency;
  final DateTime at;
  final FinTxSource source;
  final String? store;
  final List<TxItem> items;
  final String? ref;
  final bool itemsFromServer;
}

class _ReceiptInputScreenState extends ConsumerState<ReceiptInputScreen> {
  _Receipt? _r;
  String? _error;
  bool _busy = false;
  bool _saving = false;
  String? _accountId;
  String? _photoId;
  String? _categoryId;

  bool get _qr => widget.mode != 'photo';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    setState(() {
      _error = null;
      _r = null;
    });
    if (_qr) {
      await _scanQr();
    } else {
      await _photo();
    }
  }

  Future<void> _scanQr() async {
    final l = AppLocalizations.of(context);
    final raw = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const _QrScannerPage()));
    if (!mounted) return;
    if (raw == null) {
      Navigator.of(context).maybePop();
      return;
    }
    final qr = FnsQr.tryParse(raw);
    if (qr == null) {
      setState(() => _error = l.fniQrNotReceipt);
      return;
    }
    var r = _Receipt(
      kind: qr.kind,
      total: qr.total,
      currency: 'RUB',
      at: qr.at,
      source: FinTxSource.receiptQr,
      ref: qr.ref,
    );
    setState(() {
      _r = r;
      _busy = true;
    });
    // Позиции и магазин — с сервера (ФНС), если доступны; иначе остаётся то, что в QR.
    try {
      final s = await ref.read(financeInputApiProvider).receiptQr(raw);
      if (s.ok) {
        r = _Receipt(
          kind: r.kind,
          total: s.total > 0 ? s.total : r.total,
          currency: r.currency,
          at: s.occurredAt ?? r.at,
          source: r.source,
          store: s.store,
          items: s.items,
          ref: r.ref,
          itemsFromServer: true,
        );
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _r = r;
        _busy = false;
      });
    }
  }

  Future<void> _photo() async {
    final res = await showReceiptFlow(context);
    if (!mounted) return;
    if (res == null) {
      Navigator.of(context).maybePop();
      return;
    }
    final total = toMinor(res.total);
    final at = res.date ?? DateTime.now();
    _photoId = res.photoId;
    setState(() => _r = _Receipt(
          kind: FinTxKind.expense,
          total: total,
          currency: res.currency.isEmpty ? 'RUB' : res.currency.toUpperCase(),
          at: at,
          source: FinTxSource.receiptPhoto,
          store: res.store.isEmpty ? null : res.store,
          items: [for (final i in res.items) TxItem(name: i.name, qty: i.qty <= 0 ? 1 : i.qty, price: toMinor(i.price))],
          // Дедуп только при известной дате (иначе одинаковые чеки разных дней склеятся).
          ref: res.date == null ? null : 'photo:${stableHash('${res.store}|${res.date!.toIso8601String()}|$total')}',
        ));
  }

  Future<void> _save() async {
    final r = _r;
    if (r == null || r.total <= 0) return;
    final l = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final id = await ref.read(financeLedgerProvider).add(TxDraft(
            kind: r.kind,
            amount: r.total,
            currency: r.currency,
            occurredAt: r.at,
            source: r.source,
            accountId: _accountId,
            categoryId: _categoryId,
            merchant: r.store,
            externalRef: r.ref,
            items: r.items,
            photoId: r.source == FinTxSource.receiptPhoto ? _photoId : null,
          ));
      if (!mounted) return;
      fniSnack(context, id == null ? l.fniDuplicate : l.fniAdded);
      Navigator.of(context).maybePop(id != null);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        fniSnack(context, l.fniSaveFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = _r;
    final Widget body;
    if (_error != null) {
      body = SysPanel(
        tone: PanelTone.danger,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_error!, style: SysText.body),
            const SizedBox(height: 12),
            SysButton.secondary(label: l.fniRetry, onPressed: _start),
          ],
        ),
      );
    } else if (r == null) {
      body = const FniBusy();
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanel(
            title: l.fniReceiptTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (r.store != null) FniRow(label: l.fniStore, value: r.store!),
                FniRow(label: l.fniDate, value: DateFormat.yMMMd(l.localeName).add_Hm().format(r.at)),
                if (r.kind == FinTxKind.income) FniRow(label: l.fniKind, value: l.fniRefund),
                if (r.items.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  for (final it in r.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(it.qty == 1 ? it.name : '${it.name} × ${fmt1(l, it.qty)}', style: SysText.body),
                          ),
                          const SizedBox(width: 12),
                          Text(moneyText(l, it.price, r.currency), style: SysText.mono),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                FniRow(label: l.fniTotal, value: moneyText(l, r.total, r.currency)),
              ],
            ),
          ),
          if (_busy) const FniBusy(),
          if (_qr && !_busy && !r.itemsFromServer) ...[
            const SizedBox(height: 8),
            Text(l.fniQrNoItems, style: SysText.caption),
          ],
          const SizedBox(height: 12),
          FniAccountCategory(
            kind: r.kind,
            accountId: _accountId,
            categoryId: _categoryId,
            onAccount: (v) => setState(() => _accountId = v),
            onCategory: (v) => setState(() => _categoryId = v),
          ),
          const SizedBox(height: 16),
          SysButton.primary(label: l.fniAdd, expand: true, onPressed: _saving || _busy ? null : _save),
        ],
      );
    }
    return NutPage(title: _qr ? l.fniReceiptQrTitle : l.fniReceiptPhotoTitle, child: body);
  }
}

/// Сканер QR чека.
class _QrScannerPage extends StatefulWidget {
  const _QrScannerPage();

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
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
                child: Text(l.fniNoCamera, style: SysText.secondary, textAlign: TextAlign.center),
              ),
            ),
          ),
          Center(
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
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
                        tooltip: l.fniClose,
                        constraints: const BoxConstraints(minWidth: SysDims.minTap, minHeight: SysDims.minTap),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const SysIcon(SysGlyph.close, color: SysColors.accentLight),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(l.fniQrHint, style: SysText.secondary, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
