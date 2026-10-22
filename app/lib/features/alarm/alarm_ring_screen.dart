// Звонящий будильник (SPEC §8.11): полноэкранно, выключается только заданием —
// приседания по акселерометру или скан того самого QR. «Отложить на 5 мин» — не больше 2 раз.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/routes.dart';
import '../../core/alarm/alarm_api.dart';
import '../../core/alarm/alarm_repository.dart';
import '../../core/alarm/channel_alarm_scheduler.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../core/voice/tts_service.dart';
import '../../domain/quests/quest_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'alarm_texts.dart';
import 'squat_counter.dart';

class AlarmRingScreen extends ConsumerStatefulWidget {
  const AlarmRingScreen({super.key, this.alarmId});

  final String? alarmId;

  @override
  ConsumerState<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends ConsumerState<AlarmRingScreen> {
  AlarmRow? _alarm;
  AlarmRunRow? _run;
  bool _loading = true;
  bool _test = false;
  bool _done = false;
  bool _busy = false;
  int _squats = 0;
  bool _sensorError = false;
  String? _qrError;
  SquatCounter? _counter;
  Timer? _clock;
  DateTime _now = DateTime.now();

  AlarmRepository get _repo => ref.read(alarmRepositoryProvider);
  AlarmScheduler get _scheduler => ref.read(alarmSchedulerProvider);

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    unawaited(_load());
  }

  @override
  void dispose() {
    _clock?.cancel();
    _counter?.stop();
    super.dispose();
  }

  Future<void> _load() async {
    final id = widget.alarmId;
    final alarm = id == null ? null : await _repo.get(id);
    if (alarm == null) {
      if (id != null) unawaited(_scheduler.stop(id));
      if (mounted) setState(() => _loading = false);
      return;
    }
    AlarmRing? pending;
    try {
      pending = await _scheduler.pendingRing();
    } catch (_) {
      pending = null;
    }
    final firedAt = pending?.alarmId == alarm.id ? pending!.firedAt : DateTime.now();
    final run = await _repo.openRun(alarm, firedAt);
    final test = await _repo.isTestRing(alarm.id);
    final s = _scheduler;
    if (s is AlarmRingControl) unawaited((s as AlarmRingControl).startRinging(alarm.id));
    if (!mounted) return;
    setState(() {
      _alarm = alarm;
      _run = run;
      _test = test;
      _loading = false;
    });
    if (_usesSquats(alarm)) _startCounter(alarm);
  }

  bool _usesSquats(AlarmRow a) => almTaskOf(a) == AlarmTask.squats || (a.qrCode?.isEmpty ?? true);

  void _startCounter(AlarmRow a) {
    final lang = Localizations.localeOf(context).languageCode;
    final tts = ref.read(ttsServiceProvider);
    _counter = SquatCounter(
      onSquat: (n) {
        if (!mounted || _done) return;
        HapticFeedback.heavyImpact();
        setState(() => _squats = n);
        unawaited(tts.speak('$n', languageCode: lang).catchError((Object _) {}));
        if (n >= a.squats) unawaited(_complete());
      },
      onError: (_) {
        if (mounted) setState(() => _sensorError = true);
      },
    )..start();
  }

  Future<void> _complete() async {
    final a = _alarm, run = _run;
    if (a == null || run == null || _done || _busy) return;
    _busy = true;
    _counter?.stop();
    QuestService? quests;
    try {
      quests = ref.read(questServiceProvider);
    } catch (_) {
      quests = null;
    }
    await _scheduler.stop(a.id);
    await _repo.dismiss(run, a, quests: quests);
    await _scheduler.sync(await _repo.all());
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    setState(() {
      _done = true;
      _busy = false;
    });
    await Future<void>.delayed(const Duration(seconds: 3));
    if (mounted) GoRouter.of(context).go(Routes.status);
  }

  Future<void> _snooze() async {
    final a = _alarm, run = _run;
    if (a == null || run == null || _busy) return;
    _busy = true;
    try {
      if (!await _repo.snooze(run)) return;
      _counter?.stop();
      await _scheduler.stop(a.id);
      await _scheduler.sync(await _repo.all());
      if (mounted) GoRouter.of(context).go(Routes.status);
    } finally {
      _busy = false;
    }
  }

  Future<void> _scan() async {
    final a = _alarm;
    if (a == null) return;
    final code = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const _QrScanPage()));
    if (code == null || !mounted) return;
    if (code.trim() == a.qrCode?.trim()) {
      setState(() => _qrError = null);
      await _complete();
    } else {
      HapticFeedback.vibrate();
      setState(() => _qrError = AppLocalizations.of(context).almQrWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: _done || (!_loading && _alarm == null),
      child: Scaffold(
        backgroundColor: SysColors.background,
        body: SystemBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _alarm == null
                      ? _notFound(l)
                      : _done
                          ? _doneView(l)
                          : _ringView(l, _alarm!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _notFound(AppLocalizations l) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.almNotFound, style: SysText.secondary, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          SysButton.secondary(label: l.commonClose, onPressed: () => GoRouter.of(context).go(Routes.status)),
        ],
      );

  Widget _doneView(AppLocalizations l) => Center(
        child: SysPanel(
          tone: PanelTone.success,
          title: l.almDone,
          child: Text(l.almDoneBody, style: SysText.body),
        ),
      );

  Widget _ringView(AppLocalizations l, AlarmRow a) {
    final run = _run;
    final snoozes = run?.snoozes ?? 0;
    final left = alarmMaxSnoozes - snoozes;
    final label = a.label?.trim();
    final squats = _usesSquats(a);
    final reward = AlarmRepository.rewardFor(snoozes);
    final time = '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(l.almRingTitle.toUpperCase(), style: SysText.heading)),
            if (_test) SysPill(label: l.almTestRing, tone: PanelTone.gold),
          ],
        ),
        const SizedBox(height: 8),
        Text(time, style: SysText.display, textAlign: TextAlign.center),
        if (label != null && label.isNotEmpty)
          Text(label, style: SysText.title, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Expanded(
          child: SysPanel(
            tone: PanelTone.danger,
            title: l.almTask,
            child: squats ? _squatsView(l, a) : _qrView(l),
          ),
        ),
        const SizedBox(height: 12),
        if (!_test && reward > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l.almReward(reward), style: SysText.caption, textAlign: TextAlign.center),
          ),
        if (left > 0)
          SysButton.secondary(label: l.almSnooze(left), expand: true, onPressed: _busy ? null : _snooze)
        else
          Text(l.almSnoozeNone, style: SysText.caption, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _squatsView(AppLocalizations l, AlarmRow a) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (almTaskOf(a) == AlarmTask.qr) ...[
            Text(l.almQrMissing, style: SysText.caption, textAlign: TextAlign.center),
            const SizedBox(height: 8),
          ],
          Text(l.almRingBodySquats(a.squats), style: SysText.body, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              l.almSquatsProgress(_squats, a.squats),
              style: SysText.display.copyWith(fontSize: 96, fontFamily: SysFonts.mono),
            ),
          ),
          const SizedBox(height: 8),
          SysBar(value: a.squats == 0 ? 1 : (_squats / a.squats).clamp(0, 1).toDouble()),
          const SizedBox(height: 12),
          Text(l.almSquatsHint, style: SysText.secondary, textAlign: TextAlign.center),
          if (_sensorError) ...[
            const SizedBox(height: 16),
            Text(l.almSensorError, style: SysText.caption, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            HoldButton(
              label: l.almHoldFallback,
              duration: const Duration(seconds: 20),
              expand: true,
              onCompleted: () => unawaited(_complete()),
            ),
          ],
        ],
      );

  Widget _qrView(AppLocalizations l) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: SysIcon(SysGlyph.shield, size: 64)),
          const SizedBox(height: 16),
          Text(l.almRingBodyQr, style: SysText.body, textAlign: TextAlign.center),
          if (_qrError != null) ...[
            const SizedBox(height: 10),
            Text(_qrError!, style: SysText.secondary.copyWith(color: SysColors.calories), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 20),
          SysButton.primary(label: l.almScanQr, expand: true, onPressed: _busy ? null : _scan),
        ],
      );
}

class _QrScanPage extends StatefulWidget {
  const _QrScanPage();

  @override
  State<_QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<_QrScanPage> {
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
                child: Text(l.almScanNoCamera, style: SysText.secondary, textAlign: TextAlign.center),
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
                  borderRadius: BorderRadius.circular(SysDims.radius),
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
                      Expanded(child: Text(l.almScanTitle.toUpperCase(), style: SysText.heading)),
                    ],
                  ),
                  const Spacer(),
                  Text(l.almScanHint, style: SysText.secondary, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
