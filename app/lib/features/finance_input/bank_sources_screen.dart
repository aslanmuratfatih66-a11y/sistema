// Банки на Android (SPEC §8.7): выбор банков, доступ к уведомлениям и SMS, входящие с подтверждением.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/capabilities/capability_service.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../nutrition/nutrition_format.dart';
import 'bank_inbox_service.dart';
import 'fni_banks.dart';
import 'fni_common.dart';
import 'fni_parsers.dart';

class BankSourcesScreen extends ConsumerStatefulWidget {
  const BankSourcesScreen({super.key});

  @override
  ConsumerState<BankSourcesScreen> createState() => _BankSourcesScreenState();
}

class _BankSourcesScreenState extends ConsumerState<BankSourcesScreen> with WidgetsBindingObserver {
  BankSources? _sources;
  bool _listener = false;
  bool _sms = false;
  bool _working = false;

  BankInboxService get _svc => ref.read(bankInboxServiceProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshAccess();
  }

  Future<void> _load() async {
    final s = await _svc.loadSources();
    if (mounted) setState(() => _sources = s);
    await _refreshAccess();
  }

  Future<void> _refreshAccess() async {
    final ch = ref.read(bankChannelProvider);
    final listener = await ch.isListenerEnabled();
    var sms = false;
    if (ch.supported) {
      try {
        sms = await Permission.sms.isGranted;
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _listener = listener;
        _sms = sms;
      });
    }
  }

  Future<void> _set(String key, BankToggle t) async {
    final s = (_sources ?? const BankSources()).withBank(key, t);
    setState(() => _sources = s);
    await _svc.saveSources(s);
  }

  Future<void> _requestSms() async {
    try {
      final st = await Permission.sms.request();
      if (st.isPermanentlyDenied) await openAppSettings();
    } catch (_) {}
    await _refreshAccess();
  }

  Future<void> _run(Future<void> Function() f) async {
    setState(() => _working = true);
    try {
      await f();
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final caps = ref.watch(deviceCapabilitiesProvider);
    final supported = caps.value?.has(Capability.bankNotifications) ?? ref.read(bankChannelProvider).supported;
    if (!supported) {
      return NutPage(
        title: l.fniBanksTitle,
        child: SysPanel(child: Text(l.fniBanksAndroidOnly, style: SysText.secondary)),
      );
    }
    final s = _sources;
    final anySms = s?.banks.values.any((b) => b.sms) ?? false;
    final anyNotif = s?.banks.values.any((b) => b.notifications) ?? false;
    return NutPage(
      title: l.fniBanksTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanel(
            title: l.fniAccess,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AccessRow(
                  label: l.fniAccessNotifications,
                  granted: _listener,
                  needed: anyNotif,
                  action: l.fniOpenSettings,
                  onAction: () => ref.read(bankChannelProvider).openListenerSettings(),
                ),
                const SizedBox(height: 8),
                _AccessRow(
                  label: l.fniAccessSms,
                  granted: _sms,
                  needed: anySms,
                  action: l.fniAllow,
                  onAction: _requestSms,
                ),
                const SizedBox(height: 8),
                Text(l.fniAccessHint, style: SysText.caption),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (s == null)
            const FniBusy()
          else
            SysPanel(
              title: l.fniBanksList,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final b in bankCatalog) _BankTile(info: b, toggle: s.of(b.key), onChanged: (t) => _set(b.key, t)),
                  _BankTile(info: null, toggle: s.of(otherBankKey), onChanged: (t) => _set(otherBankKey, t)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SysButton.secondary(
                  label: l.fniProcessNow,
                  onPressed: _working ? null : () => _run(_svc.process),
                ),
              ),
              if (_sms && anySms) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: SysButton.secondary(
                    label: l.fniSmsHistory,
                    onPressed: _working
                        ? null
                        : () => _run(() async {
                              final n = await _svc.importSmsHistory();
                              if (context.mounted) fniSnack(context, l.fniSmsFound(n));
                            }),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          const _InboxList(),
        ],
      ),
    );
  }
}

class _AccessRow extends StatelessWidget {
  const _AccessRow({required this.label, required this.granted, required this.needed, required this.action, required this.onAction});

  final String label;
  final bool granted;
  final bool needed;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: Text(label, style: SysText.body)),
        if (granted)
          SysPill(label: l.fniGranted, tone: PanelTone.success, icon: SysGlyph.check)
        else
          SysButton(
            label: action,
            variant: needed ? SysButtonVariant.primary : SysButtonVariant.secondary,
            onPressed: onAction,
          ),
      ],
    );
  }
}

/// Банк: уведомления / SMS; для «другого» — свои пакеты и отправители.
class _BankTile extends StatelessWidget {
  const _BankTile({required this.info, required this.toggle, required this.onChanged});

  final BankInfo? info;
  final BankToggle toggle;
  final ValueChanged<BankToggle> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final b = info;
    final senders = [...?b?.smsSenders, ...toggle.extraSenders];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(b?.name ?? l.fniOtherBank, style: SysText.title),
          SysSwitchRow(
            label: l.fniSourceNotifications,
            value: toggle.notifications,
            onChanged: (v) => onChanged(toggle.copyWith(notifications: v)),
          ),
          SysSwitchRow(
            label: l.fniSourceSms,
            hint: senders.isEmpty ? null : l.fniSenders(senders.join(', ')),
            value: toggle.sms,
            onChanged: (v) => onChanged(toggle.copyWith(sms: v)),
          ),
          if (toggle.any) ...[
            if (b == null)
              SysTextField(
                label: l.fniPackages,
                hint: 'com.bank.app',
                value: toggle.extraPackages.join(', '),
                textCapitalization: TextCapitalization.none,
                onChanged: (v) => onChanged(toggle.copyWith(extraPackages: _split(v))),
              ),
            SysTextField(
              label: l.fniExtraSenders,
              hint: l.fniExtraSendersHint,
              value: toggle.extraSenders.join(', '),
              textCapitalization: TextCapitalization.none,
              onChanged: (v) => onChanged(toggle.copyWith(extraSenders: _split(v))),
            ),
          ],
        ],
      ),
    );
  }

  static List<String> _split(String v) => [
        for (final s in v.split(RegExp(r'[,;\n]')))
          if (s.trim().isNotEmpty) s.trim(),
      ];
}

/// Входящие уведомления/SMS со статусами и действиями.
class _InboxList extends ConsumerWidget {
  const _InboxList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final rows = ref.watch(bankInboxProvider).value ?? const <BankInboxRow>[];
    return SysPanel(
      title: l.fniInbox,
      child: rows.isEmpty
          ? Text(l.fniInboxEmpty, style: SysText.secondary)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final r in rows) _InboxTile(row: r)],
            ),
    );
  }
}

class _InboxTile extends ConsumerWidget {
  const _InboxTile({required this.row});

  final BankInboxRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final info = inboxParsed(row);
    final p = info.parsed;
    final svc = ref.read(bankInboxServiceProvider);
    final canFix = row.transactionId == null || ref.watch(bankTxRemoverProvider) != null;
    final (String label, PanelTone tone) = switch (row.status) {
      'parsed' when info.review => (l.fniStatusReview, PanelTone.gold),
      'parsed' => (l.fniStatusAdded, PanelTone.success),
      'ignored' when info.duplicate => (l.fniStatusDuplicate, PanelTone.accent),
      'ignored' => (l.fniStatusIgnored, PanelTone.accent),
      'failed' => (l.fniStatusFailed, PanelTone.danger),
      _ => (l.fniStatusPending, PanelTone.accent),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${bankByKey(row.bank)?.name ?? row.sender} · ${DateFormat.MMMd(l.localeName).add_Hm().format(row.receivedAt)}',
                  style: SysText.caption,
                ),
              ),
              SysPill(label: label, tone: tone),
            ],
          ),
          const SizedBox(height: 4),
          Text(row.body, style: SysText.secondary, maxLines: 3, overflow: TextOverflow.ellipsis),
          if (p != null) ...[
            const SizedBox(height: 4),
            Text(
              '${p.kind == FinTxKind.income ? '+' : p.kind == FinTxKind.expense ? '−' : ''}${moneyText(l, p.amount, p.currency)}'
              '${p.merchant == null ? '' : ' · ${p.merchant}'}${p.cardLast4 == null ? '' : ' · *${p.cardLast4}'}',
              style: SysText.mono,
            ),
          ],
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (row.status == 'parsed' && info.review)
                SysButton.secondary(label: l.fniConfirm, onPressed: () => svc.confirm(row)),
              if (canFix && !(row.status == 'parsed' && !info.review && row.parser != 'ai'))
                SysButton.secondary(
                  label: row.status == 'parsed' ? l.fniFix : l.fniAddManually,
                  onPressed: () async {
                    final np = await showBankEditDialog(context, p, bank: bankByKey(row.bank));
                    if (np == null) return;
                    final ok = await svc.correct(row, np);
                    if (!ok && context.mounted) fniSnack(context, l.fniFixInFinance);
                  },
                ),
              if (row.status == 'pending' || row.status == 'failed' || (row.status == 'parsed' && canFix))
                SysButton.secondary(
                  label: l.fniIgnore,
                  onPressed: () async {
                    final ok = await svc.ignore(row);
                    if (!ok && context.mounted) fniSnack(context, l.fniFixInFinance);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ручной ввод/исправление: тип, сумма, валюта, мерчант.
Future<BankParsed?> showBankEditDialog(BuildContext context, BankParsed? initial, {BankInfo? bank}) {
  final l = AppLocalizations.of(context);
  var kind = initial?.kind ?? FinTxKind.expense;
  num? amount = initial == null ? null : initial.amount / 100;
  var currency = initial?.currency ?? bank?.currency ?? defaultCurrency(l);
  var merchant = initial?.merchant ?? '';
  return showDialog<BankParsed>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, set) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: SysPanel(
          title: l.fniEditTitle,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SysSegmented<FinTxKind>(
                  choices: [
                    SysChoice(FinTxKind.expense, l.fniExpense),
                    SysChoice(FinTxKind.income, l.fniIncome),
                    SysChoice(FinTxKind.transfer, l.fniTransfer),
                  ],
                  value: kind,
                  onChanged: (v) => set(() => kind = v),
                ),
                const SysFieldGap(),
                SysNumberField(
                  label: l.fniAmount,
                  value: amount,
                  min: 0,
                  onChanged: (v) => set(() => amount = v),
                ),
                const SysFieldGap(),
                SysChoiceChips<String>(
                  choices: const [
                    SysChoice('RUB', '₽ RUB'),
                    SysChoice('TRY', '₺ TRY'),
                    SysChoice('USD', r'$ USD'),
                    SysChoice('EUR', '€ EUR'),
                  ],
                  selected: {currency},
                  allowEmpty: false,
                  onChanged: (s) => set(() => currency = s.first),
                ),
                const SysFieldGap(),
                SysTextField(label: l.fniMerchant, value: merchant, onChanged: (v) => merchant = v),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: SysButton.secondary(label: l.fniCancel, onPressed: () => Navigator.of(c).pop())),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SysButton.primary(
                        label: l.fniSave,
                        onPressed: (amount ?? 0) <= 0
                            ? null
                            : () => Navigator.of(c).pop(BankParsed(
                                  kind: kind,
                                  amount: toMinor(amount!.toDouble()),
                                  currency: currency,
                                  merchant: merchant.trim().isEmpty ? null : merchant.trim(),
                                  cardLast4: initial?.cardLast4,
                                )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
