// Экран блокировки: при старте и при возврате из фона дольше N минут (SPEC §8.7 «Вход по Face ID / отпечатку / PIN»).
// Подключение: MaterialApp.router(builder: (context, child) => AppLockGate(child: child!)) — внутри Localizations.
// Поле ввода не используется (над Navigator нет Overlay) — своя цифровая клавиатура.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'app_lock.dart';
import 'app_lock_impl.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  late final AppLockImpl _lock = ref.read(appLockImplProvider);

  /// null — режим ещё не прочитан (показываем пустой фон, чтобы не мелькало содержимое).
  bool? _locked;
  bool _obscured = false;
  DateTime? _bgSince;
  AppLockMode _mode = AppLockMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lock.addListener(_onLockChanged);
    _init();
  }

  Future<void> _init() async {
    final m = await _lock.mode();
    if (!mounted) return;
    setState(() {
      _mode = m;
      _locked = m != AppLockMode.off;
    });
    if (_locked == true) _tryBiometric();
  }

  void _onLockChanged() async {
    final m = await _lock.mode();
    if (!mounted) return;
    // Смена режима в настройках не блокирует текущий сеанс.
    setState(() {
      _mode = m;
      if (m == AppLockMode.off) _locked = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lock.removeListener(_onLockChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_lock.authInProgress) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _bgSince ??= DateTime.now();
        if (_mode != AppLockMode.off && !_obscured) setState(() => _obscured = true);
      case AppLifecycleState.inactive:
        // Снимок в переключателе приложений — без содержимого.
        if (_mode != AppLockMode.off && !_obscured) setState(() => _obscured = true);
      case AppLifecycleState.resumed:
        _onResumed();
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _onResumed() async {
    final since = _bgSince;
    _bgSince = null;
    final timeout = await _lock.timeoutMinutes();
    if (!mounted) return;
    final lockNow = _mode != AppLockMode.off &&
        _locked == false &&
        since != null &&
        DateTime.now().difference(since) >= Duration(minutes: timeout);
    setState(() {
      _obscured = false;
      if (lockNow) _locked = true;
    });
    if (lockNow) _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    if (_mode != AppLockMode.biometric && _mode != AppLockMode.biometricOrPin) return;
    final l = AppLocalizations.of(context);
    final ok = await _lock.unlock(reason: l.finLockReason);
    if (ok && mounted) setState(() => _locked = false);
  }

  void _unlocked() => setState(() => _locked = false);

  @override
  Widget build(BuildContext context) {
    final locked = _locked;
    final cover = locked != false || _obscured;
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          excluding: cover,
          child: IgnorePointer(ignoring: cover, child: TickerMode(enabled: !cover, child: widget.child)),
        ),
        if (locked == null)
          const ColoredBox(color: SysColors.background)
        else if (locked)
          _LockScreen(mode: _mode, lock: _lock, onBiometric: _tryBiometric, onUnlocked: _unlocked)
        else if (_obscured)
          const SystemBackground(child: Center(child: SysIcon(SysGlyph.shield, size: 48))),
      ],
    );
  }
}

class _LockScreen extends StatefulWidget {
  const _LockScreen({required this.mode, required this.lock, required this.onBiometric, required this.onUnlocked});

  final AppLockMode mode;
  final AppLockImpl lock;
  final Future<void> Function() onBiometric;
  final VoidCallback onUnlocked;

  @override
  State<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<_LockScreen> {
  String? _error;
  Duration? _cooldown;
  Timer? _timer;
  bool _checking = false;

  bool get _pin => widget.mode == AppLockMode.pin || widget.mode == AppLockMode.biometricOrPin;
  bool get _bio => widget.mode == AppLockMode.biometric || widget.mode == AppLockMode.biometricOrPin;

  @override
  void initState() {
    super.initState();
    _refreshCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refreshCooldown() async {
    final c = await widget.lock.pinCooldown();
    if (!mounted) return;
    setState(() => _cooldown = c);
    _timer?.cancel();
    if (c != null) _timer = Timer(const Duration(seconds: 1), _refreshCooldown);
  }

  Future<bool> _submit(String pin) async {
    if (_checking) return false;
    setState(() => _checking = true);
    final ok = await widget.lock.verifyPin(pin);
    if (!mounted) return ok;
    setState(() => _checking = false);
    if (ok) {
      widget.onUnlocked();
    } else {
      HapticFeedback.heavyImpact();
      setState(() => _error = AppLocalizations.of(context).finLockWrongPin);
      await _refreshCooldown();
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cd = _cooldown;
    return Material(
      type: MaterialType.transparency,
      child: SystemBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: SysPanel(
                  title: l.finLockTitle,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: SysIcon(SysGlyph.shield, size: 40)),
                      const SizedBox(height: 10),
                      Text(_pin ? l.finLockEnterPin : l.finLockUseBiometric,
                          textAlign: TextAlign.center, style: SysText.secondary),
                      const SizedBox(height: 14),
                      if (_pin)
                        PinPad(
                          key: const Key('fin-lock-pad'),
                          enabled: cd == null && !_checking,
                          error: cd != null ? l.finLockCooldown(cd.inSeconds + 1) : _error,
                          onSubmit: _submit,
                        ),
                      if (_bio) ...[
                        const SizedBox(height: 12),
                        SysButton.secondary(
                          key: const Key('fin-lock-bio'),
                          label: l.finLockBiometricButton,
                          icon: SysGlyph.shield,
                          expand: true,
                          onPressed: widget.onBiometric,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Цифровая клавиатура PIN (4–8 цифр). [onSubmit] возвращает true — ввод принят (поле не очищается до этого).
class PinPad extends StatefulWidget {
  const PinPad({super.key, required this.onSubmit, this.enabled = true, this.error, this.hint});

  final Future<bool> Function(String pin) onSubmit;
  final bool enabled;
  final String? error;
  final String? hint;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _pin = '';

  void _tap(String d) {
    if (!widget.enabled || _pin.length >= AppLockImpl.maxPin) return;
    HapticFeedback.selectionClick();
    setState(() => _pin += d);
  }

  void _back() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _ok() async {
    if (!widget.enabled || _pin.length < AppLockImpl.minPin) return;
    final pin = _pin;
    await widget.onSubmit(pin);
    if (mounted) setState(() => _pin = '');
  }

  Widget _key(String label, VoidCallback? onTap, {String? semantic, Widget? child}) => Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Semantics(
            button: true,
            label: semantic ?? label,
            excludeSemantics: true,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(SysDims.radius),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: SysColors.panelBorder),
                  borderRadius: BorderRadius.circular(SysDims.radius),
                  color: SysColors.accent.withValues(alpha: .06),
                ),
                child: child ?? Text(label, style: SysText.monoLarge),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final err = widget.error;
    final hint = widget.hint;
    Widget row(List<String> ds) => Row(children: [for (final d in ds) _key(d, () => _tap(d))]);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: l.finLockDigits(_pin.length),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < AppLockImpl.maxPin; i++)
                if (i < _pin.length || i < AppLockImpl.minPin)
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length ? SysColors.accentLight : Colors.transparent,
                      border: Border.all(color: SysColors.accentLight),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (err != null)
          Text(err, textAlign: TextAlign.center, style: SysText.caption.copyWith(color: SysColors.dangerLight))
        else if (hint != null)
          Text(hint, textAlign: TextAlign.center, style: SysText.caption),
        const SizedBox(height: 8),
        row(['1', '2', '3']),
        row(['4', '5', '6']),
        row(['7', '8', '9']),
        Row(children: [
          _key('⌫', _back, semantic: l.finLockErase, child: const SysIcon(SysGlyph.close, size: 22)),
          _key('0', () => _tap('0')),
          _key('OK', _pin.length >= AppLockImpl.minPin && widget.enabled ? _ok : null,
              semantic: l.finLockOk, child: const SysIcon(SysGlyph.check, size: 22)),
        ]),
      ],
    );
  }
}
