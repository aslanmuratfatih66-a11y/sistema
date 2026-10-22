// Настройки раздела: вход по Face ID / отпечатку / PIN, «налог на фастфуд», категории.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/app_lock.dart';
import '../../../core/security/app_lock_gate.dart' show PinPad;
import '../../../core/security/app_lock_impl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/finance_repository.dart';
import '../fin_texts.dart';
import '../finance_providers.dart';
import '../widgets/fin_common.dart';
import 'categories_screen.dart';

class FinSettingsScreen extends ConsumerStatefulWidget {
  const FinSettingsScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const FinSettingsScreen()));

  @override
  ConsumerState<FinSettingsScreen> createState() => _FinSettingsScreenState();
}

class _FinSettingsScreenState extends ConsumerState<FinSettingsScreen> {
  late final AppLockImpl _lock = ref.read(appLockImplProvider);
  AppLockMode? _mode;
  int _timeout = 1;
  bool _bioAvailable = false;
  FinSettings? _fin;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await _lock.mode();
    final t = await _lock.timeoutMinutes();
    final b = await _lock.biometricAvailable();
    final f = await ref.read(financeRepositoryProvider).settings();
    if (mounted) {
      setState(() {
        _mode = m;
        _timeout = t;
        _bioAvailable = b;
        _fin = f;
      });
    }
  }

  Future<String?> _askNewPin() async {
    final l = AppLocalizations.of(context);
    final first = await PinSetupScreen.open(context, title: l.finLockNewPin);
    if (first == null || !mounted) return null;
    final second = await PinSetupScreen.open(context, title: l.finLockRepeatPin);
    if (second == null || !mounted) return null;
    if (first != second) {
      finSnack(context, l.finLockPinMismatch);
      return null;
    }
    return first;
  }

  Future<void> _setMode(AppLockMode m) async {
    final l = AppLocalizations.of(context);
    final needsPin = m == AppLockMode.pin || m == AppLockMode.biometricOrPin;
    final needsBio = m == AppLockMode.biometric || m == AppLockMode.biometricOrPin;
    if (needsBio && !_bioAvailable) {
      finSnack(context, l.finLockNoBiometric);
      return;
    }
    String? pin;
    if (needsPin && !await _lock.hasPin()) {
      pin = await _askNewPin();
      if (pin == null) return;
    }
    if (needsBio) {
      // Проверка, что биометрия срабатывает, до включения.
      if (!await _lock.authenticateBiometric(l.finLockReason)) return;
    }
    try {
      await _lock.setMode(m, pin: pin);
    } catch (_) {
      if (mounted) finSnack(context, l.finSaveError);
    }
    await _load();
  }

  Future<void> _changePin() async {
    final pin = await _askNewPin();
    if (pin == null) return;
    await _lock.setMode(await _lock.mode(), pin: pin);
    if (mounted) finSnack(context, AppLocalizations.of(context).finLockPinChanged);
  }

  Future<void> _saveFin(FinSettings s) async {
    setState(() => _fin = s);
    await ref.read(financeRepositoryProvider).saveSettings(s);
    ref.invalidate(finSettingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mode = _mode;
    final fin = _fin;
    final usesPin = mode == AppLockMode.pin || mode == AppLockMode.biometricOrPin;
    return ScheduleSubPage(
      title: l.finSettings,
      onBack: () => Navigator.of(context).maybePop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanel(
            title: l.finLockSection,
            child: mode == null
                ? const SizedBox(height: 44)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l.finLockIntro, style: SysText.secondary),
                      const SizedBox(height: 10),
                      SysChoiceChips<AppLockMode>(
                        choices: [for (final m in AppLockMode.values) SysChoice(m, lockModeLabel(l, m))],
                        selected: {mode},
                        allowEmpty: false,
                        onChanged: (s) => _setMode(s.first),
                      ),
                      if (!_bioAvailable) ...[
                        const SizedBox(height: 6),
                        Text(l.finLockNoBiometric, style: SysText.caption),
                      ],
                      if (mode != AppLockMode.off) ...[
                        const SysFieldGap(),
                        SysFieldLabel(l.finLockTimeout),
                        SysSegmented<int>(
                          choices: [
                            SysChoice(0, l.finLockTimeoutNow),
                            SysChoice(1, l.finMinutes(1)),
                            SysChoice(5, l.finMinutes(5)),
                            SysChoice(15, l.finMinutes(15)),
                          ],
                          value: _timeout,
                          onChanged: (v) async {
                            await _lock.setTimeoutMinutes(v);
                            setState(() => _timeout = v);
                          },
                        ),
                      ],
                      if (usesPin)
                        FinActions(children: [
                          SysButton.secondary(label: l.finLockChangePin, onPressed: _changePin),
                        ]),
                      if (mode == AppLockMode.pin) ...[
                        const SizedBox(height: 6),
                        Text(l.finLockPinWarning, style: SysText.caption),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 14),
          SysPanel(
            title: l.finJunkTaxSection,
            tone: PanelTone.gold,
            child: fin == null
                ? const SizedBox(height: 44)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SysSwitchRow(
                        label: l.finJunkTaxEnabled,
                        hint: l.finJunkTaxHint,
                        value: fin.junkTaxEnabled,
                        onChanged: (v) => _saveFin(fin.copyWith(junkTaxEnabled: v)),
                      ),
                      if (fin.junkTaxEnabled) ...[
                        const SysFieldGap(),
                        SysNumberField(
                          value: fin.junkTax,
                          label: l.finJunkTaxAmount,
                          unit: '◆',
                          decimal: false,
                          min: 1,
                          max: 100,
                          onChanged: (v) {
                            final n = v?.toInt();
                            if (n != null && n >= 1 && n <= 100) _saveFin(fin.copyWith(junkTax: n));
                          },
                        ),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 14),
          SysButton.secondary(
            label: l.finCategories,
            icon: SysGlyph.star,
            expand: true,
            onPressed: () => CategoriesScreen.open(context),
          ),
        ],
      ),
    );
  }
}

/// Ввод нового PIN (экран, возвращает PIN или null).
class PinSetupScreen extends StatelessWidget {
  const PinSetupScreen({super.key, required this.title});

  final String title;

  static Future<String?> open(BuildContext context, {required String title}) =>
      Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => PinSetupScreen(title: title)));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ScheduleSubPage(
      title: title,
      onBack: () => Navigator.of(context).maybePop(),
      child: SysPanel(
        title: title,
        child: PinPad(
          hint: l.finLockPinRule(AppLockImpl.minPin, AppLockImpl.maxPin),
          onSubmit: (pin) async {
            Navigator.of(context).pop(pin);
            return true;
          },
        ),
      ),
    );
  }
}
