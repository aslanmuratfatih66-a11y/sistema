// Импорт выписки банка (SPEC §8.7, в первую очередь iOS): CSV/PDF → сервер → строки с отметками → журнал.
import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../domain/finance/finance_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../nutrition/nutrition_format.dart';
import '../vision/vision_common.dart' show visionErrorText;
import 'fni_api.dart';
import 'fni_banks.dart';
import 'fni_common.dart';

/// Файл ≤ 3 МБ: base64 укладывается в лимит тела сервера 4 МБ.
const _maxFileBytes = 3 * 1024 * 1024;

class StatementImportScreen extends ConsumerStatefulWidget {
  const StatementImportScreen({super.key});

  @override
  ConsumerState<StatementImportScreen> createState() => _StatementImportScreenState();
}

class _StatementImportScreenState extends ConsumerState<StatementImportScreen> {
  String? _file;
  List<StatementRow>? _rows;
  Set<String> _dupes = {};
  final Set<String> _selected = {};
  String? _error;
  bool _busy = false;
  bool _importing = false;
  int _done = 0;
  String? _accountId;
  String? _bank;

  Future<void> _pick() async {
    final l = AppLocalizations.of(context);
    final lang = fniLang(context);
    final PlatformFile? f;
    try {
      f = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['csv', 'pdf', 'txt']);
    } on MissingPluginException {
      return;
    } catch (_) {
      if (mounted) setState(() => _error = l.fniFileFailed);
      return;
    }
    if (f == null || !mounted) return;
    final name = f.name;
    final List<int> bytes;
    try {
      bytes = await f.readAsBytes();
    } catch (_) {
      if (mounted) setState(() => _error = l.fniFileFailed);
      return;
    }
    if (bytes.length > _maxFileBytes) {
      setState(() => _error = l.fniFileTooLarge);
      return;
    }
    final pdf = name.toLowerCase().endsWith('.pdf');
    setState(() {
      _file = name;
      _busy = true;
      _error = null;
      _rows = null;
      _selected.clear();
      _done = 0;
    });
    try {
      final rows = await ref.read(financeInputApiProvider).statement(
            filename: name,
            mime: pdf ? 'application/pdf' : 'text/csv',
            bytes: bytes,
            lang: lang,
          );
      final dupes = await _existingRefs(rows.map((r) => r.ref).toList());
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _dupes = dupes;
        _selected
          ..clear()
          ..addAll(rows.map((r) => r.ref).where((r) => !dupes.contains(r)));
        _busy = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = visionErrorText(l, e);
        });
      }
    }
  }

  /// Уже импортированные строки (по externalRef операций).
  Future<Set<String>> _existingRefs(List<String> refs) async {
    final db = ref.read(databaseProvider);
    final out = <String>{};
    for (var i = 0; i < refs.length; i += 500) {
      final chunk = refs.sublist(i, (i + 500).clamp(0, refs.length));
      final rows = await (db.selectOnly(db.finTransactions)
            ..addColumns([db.finTransactions.externalRef])
            ..where(db.finTransactions.externalRef.isIn(chunk) & db.finTransactions.deletedAt.isNull()))
          .get();
      for (final r in rows) {
        final v = r.read(db.finTransactions.externalRef);
        if (v != null) out.add(v);
      }
    }
    return out;
  }

  Future<void> _import() async {
    final rows = _rows;
    if (rows == null) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _importing = true;
      _done = 0;
    });
    final ledger = ref.read(financeLedgerProvider);
    var added = 0, dup = 0;
    try {
      for (final r in rows) {
        if (!_selected.contains(r.ref)) continue;
        final id = await ledger.add(TxDraft(
          kind: r.kind,
          amount: r.amount,
          currency: r.currency,
          occurredAt: r.occurredAt,
          source: FinTxSource.statement,
          accountId: _accountId,
          bank: _bank,
          merchant: r.merchant ?? (r.description.isEmpty ? null : r.description),
          note: r.merchant != null && r.description.isNotEmpty ? r.description : null,
          externalRef: r.ref,
        ));
        if (id == null) {
          dup++;
        } else {
          added++;
        }
        if (mounted) setState(() => _done = added + dup);
      }
    } catch (_) {
      if (mounted) fniSnack(context, l.fniSaveFailed);
    }
    if (!mounted) return;
    fniSnack(context, l.fniImported(added, dup));
    final refs = await _existingRefs(rows.map((r) => r.ref).toList());
    if (!mounted) return;
    setState(() {
      _importing = false;
      _dupes = refs;
      _selected.removeAll(refs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = _rows;
    final money = NumberFormat.decimalPatternDigits(locale: l.localeName, decimalDigits: 2);
    return NutPage(
      title: l.fniStatementTitle,
      bottom: rows == null || rows.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SysButton.primary(
                label: _importing ? l.fniImporting(_done, _selected.length) : l.fniImportN(_selected.length),
                expand: true,
                onPressed: _importing || _selected.isEmpty ? null : _import,
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanel(
            title: l.fniStatementFile,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.fniStatementHint, style: SysText.secondary),
                if (_file != null) ...[const SizedBox(height: 8), Text(_file!, style: SysText.mono)],
                const SizedBox(height: 12),
                SysButton.secondary(label: l.fniPickFile, onPressed: _busy || _importing ? null : _pick),
              ],
            ),
          ),
          if (_busy) FniBusy(text: l.fniStatementParsing),
          if (_error != null) ...[
            const SizedBox(height: 12),
            SysPanel(tone: PanelTone.danger, child: Text(_error!, style: SysText.body)),
          ],
          if (rows != null) ...[
            const SizedBox(height: 12),
            if (rows.isEmpty)
              SysEmptyState.inline(l.fniStatementEmpty, glyph: SysGlyph.wallet)
            else ...[
              FniAccountCategory(
                kind: FinTxKind.expense,
                accountId: _accountId,
                categoryId: null,
                showCategory: false,
                onAccount: (v) => setState(() => _accountId = v),
                onCategory: (_) {},
              ),
              const SysFieldGap(),
              SysFieldLabel(l.fniBank),
              SysChoiceChips<String>(
                choices: [for (final b in bankCatalog) SysChoice(b.key, b.name)],
                selected: _bank == null ? <String>{} : {_bank!},
                allowEmpty: true,
                onChanged: (s) => setState(() => _bank = s.isEmpty ? null : s.first),
              ),
              const SizedBox(height: 12),
              SysPanel(
                title: l.fniRows(rows.length),
                trailing: TextButton(
                  onPressed: _importing
                      ? null
                      : () => setState(() {
                            final all = rows.map((r) => r.ref).where((r) => !_dupes.contains(r)).toSet();
                            if (_selected.length == all.length) {
                              _selected.clear();
                            } else {
                              _selected
                                ..clear()
                                ..addAll(all);
                            }
                          }),
                  child: Text(l.fniSelectAll, style: SysText.label),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final r in rows)
                      InkWell(
                        onTap: _importing
                            ? null
                            : () => setState(() => _selected.contains(r.ref) ? _selected.remove(r.ref) : _selected.add(r.ref)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NutCheckBox(checked: _selected.contains(r.ref)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.merchant ?? (r.description.isEmpty ? '—' : r.description),
                                      style: SysText.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      DateFormat.yMMMd(l.localeName).add_Hm().format(r.occurredAt) +
                                          (_dupes.contains(r.ref) ? ' · ${l.fniAlreadyImported}' : ''),
                                      style: SysText.caption,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${r.kind == FinTxKind.income ? '+' : r.kind == FinTxKind.expense ? '−' : ''}'
                                '${money.format(r.amount / 100)} ${r.currency}',
                                style: SysText.mono.copyWith(
                                  color: r.kind == FinTxKind.income ? SysColors.success : SysColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
