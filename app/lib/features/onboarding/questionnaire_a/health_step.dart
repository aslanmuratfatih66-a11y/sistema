import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/questionnaire_repository.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../step_scope.dart';
import 'data/serial_writer.dart';

/// Этап 5 «Здоровье» (всё необязательно): раздел анкеты health.
class HealthStep extends ConsumerStatefulWidget {
  const HealthStep({super.key});

  @override
  ConsumerState<HealthStep> createState() => _HealthStepState();
}

const _textKeys = ['chronic', 'medications', 'allergies', 'intolerances', 'injuries'];

class _HealthStepState extends ConsumerState<HealthStep> {
  final _writer = SerialWriter();
  bool _loaded = false;
  final Map<String, String> _text = {};
  int? _sleep;
  int? _stress;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await ref.read(questionnaireRepositoryProvider).read(QuestionnaireSection.health);
    if (!mounted) return;
    setState(() {
      _loaded = true;
      for (final k in _textKeys) {
        _text[k] = d[k] as String? ?? '';
      }
      _sleep = (d['sleepQuality'] as num?)?.toInt();
      _stress = (d['stress'] as num?)?.toInt();
    });
  }

  void _patch(Map<String, Object?> patch) =>
      _writer.run(() => ref.read(questionnaireRepositoryProvider).patch(QuestionnaireSection.health, patch));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = StepScope.maybeOf(context);
    scope?.setCanProceed(true);
    if (!_loaded) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: SysLoader(color: SysColors.accent)),
      );
    }
    final labels = {
      'chronic': (l.qaHealthChronic, l.qaHealthChronicHint),
      'medications': (l.qaHealthMedications, l.qaHealthMedicationsHint),
      'allergies': (l.qaHealthAllergies, l.qaHealthAllergiesHint),
      'intolerances': (l.qaHealthIntolerances, l.qaHealthIntolerancesHint),
      'injuries': (l.qaHealthInjuries, l.qaHealthInjuriesHint),
    };
    final scale = [for (var i = 1; i <= 5; i++) SysChoice(i, '$i')];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scope?.editing != true) ...[
          Text(l.qaHealthIntro, style: SysText.secondary),
          const SysFieldGap(),
        ],
        for (final k in _textKeys) ...[
          SysFieldLabel(labels[k]!.$1, hint: labels[k]!.$2, optional: true, optionalLabel: l.commonOptional),
          SysTextField(
            value: _text[k] ?? '',
            maxLines: 3,
            onChanged: (v) {
              _text[k] = v;
              final t = v.trim();
              _patch({k: t.isEmpty ? null : t});
            },
          ),
          const SysFieldGap(),
        ],
        SysFieldLabel(l.qaHealthSleep, hint: l.qaHealthSleepHint, optional: true, optionalLabel: l.commonOptional),
        SysSegmented<int>(
          choices: scale,
          value: _sleep,
          onChanged: (v) {
            setState(() => _sleep = v);
            _patch({'sleepQuality': v});
          },
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qaHealthStress, hint: l.qaHealthStressHint, optional: true, optionalLabel: l.commonOptional),
        SysSegmented<int>(
          choices: scale,
          value: _stress,
          onChanged: (v) {
            setState(() => _stress = v);
            _patch({'stress': v});
          },
        ),
      ],
    );
  }
}
