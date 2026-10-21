import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/profile_repository.dart';
import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../step_scope.dart';
import 'data/serial_writer.dart';
import 'data/timezones.dart';

/// Этап 1 «Профиль»: имя (обязательно), язык, пол, дата рождения, часовой пояс, город.
class ProfileStep extends ConsumerStatefulWidget {
  const ProfileStep({super.key});

  @override
  ConsumerState<ProfileStep> createState() => _ProfileStepState();
}

const _systemLocale = 'system';

class _ProfileStepState extends ConsumerState<ProfileStep> {
  final _writer = SerialWriter();
  bool _loaded = false;
  String _name = '';
  bool _nameTouched = false;
  String? _locale;
  Sex? _sex;
  DateTime? _birthDate;
  String? _timezone;
  String _city = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ref.read(profileRepositoryProvider).get();
    if (!mounted) return;
    setState(() {
      _loaded = true;
      _name = p?.name ?? '';
      _locale = p?.locale;
      _sex = enumByName(Sex.values, p?.sex);
      _birthDate = p?.birthDate;
      _timezone = p?.timezone;
      _city = p?.city ?? '';
    });
    if (_timezone == null) {
      // По умолчанию — пояс устройства.
      final tz = deviceTimezone();
      setState(() => _timezone = tz);
      _save(ProfilesCompanion(timezone: Value(tz)));
    }
  }

  void _save(ProfilesCompanion patch) => _writer.run(() => ref.read(profileRepositoryProvider).update(patch));

  Future<void> _pickTimezone() async {
    final l = AppLocalizations.of(context);
    final current = _timezone;
    final options = [...timezoneOptions];
    if (current != null && !options.contains(current)) options.add(current);
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: SysColors.panelBottom,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(l.qaProfileTimezone.toUpperCase(), style: SysText.heading),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final tz in options)
                    ListTile(
                      minTileHeight: SysDims.minTap,
                      title: Text(
                        displayTimezone(tz),
                        style: SysText.mono.copyWith(
                          color: tz == current ? SysColors.accentLighter : SysColors.textSecondary,
                        ),
                      ),
                      trailing: tz == current ? const SysIcon(SysGlyph.check, size: 16) : null,
                      onTap: () => Navigator.of(c).pop(tz),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null && picked != current) {
      setState(() => _timezone = picked);
      _save(ProfilesCompanion(timezone: Value(picked)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = StepScope.maybeOf(context);
    scope?.setCanProceed(_loaded && _name.trim().isNotEmpty);
    if (!_loaded) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator(color: SysColors.accent)),
      );
    }
    final now = DateTime.now();
    final tz = _timezone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scope?.editing != true) ...[
          Text(l.qaProfileIntro, style: SysText.secondary),
          const SysFieldGap(),
        ],
        SysFieldLabel(l.qaProfileName),
        SysTextField(
          value: _name,
          hint: l.qaProfileNameHint,
          textCapitalization: TextCapitalization.words,
          errorText: _nameTouched && _name.trim().isEmpty ? l.commonRequired : null,
          onChanged: (v) {
            setState(() {
              _name = v;
              _nameTouched = true;
            });
            _save(ProfilesCompanion(name: Value(v.trim())));
          },
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qaProfileLanguage),
        SysSegmented<String>(
          choices: [
            SysChoice('ru', l.qaLangRu),
            SysChoice('tr', l.qaLangTr),
            SysChoice(_systemLocale, l.qaLangSystem),
          ],
          value: _locale ?? _systemLocale,
          onChanged: (v) {
            final locale = v == _systemLocale ? null : v;
            setState(() => _locale = locale);
            _save(ProfilesCompanion(locale: Value(locale)));
          },
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qaProfileSex),
        SysSegmented<Sex>(
          choices: [SysChoice(Sex.male, l.qaSexMale), SysChoice(Sex.female, l.qaSexFemale)],
          value: _sex,
          onChanged: (v) {
            setState(() => _sex = v);
            _save(ProfilesCompanion(sex: Value(v.name)));
          },
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qaProfileBirthDate),
        SysDateField(
          date: _birthDate,
          firstDate: DateTime(1930),
          lastDate: now,
          initialDate: DateTime(now.year - 18, 1, 1),
          onChanged: (d) {
            final date = DateTime(d.year, d.month, d.day);
            setState(() => _birthDate = date);
            _save(ProfilesCompanion(birthDate: Value(date)));
          },
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qaProfileTimezone, hint: l.qaProfileTimezoneHint),
        SysPickerField(
          text: tz == null ? null : displayTimezone(tz),
          glyph: SysGlyph.clock,
          onTap: _pickTimezone,
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qaProfileCity, hint: l.qaProfileCityHint, optional: true, optionalLabel: l.commonOptional),
        SysTextField(
          value: _city,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) {
            setState(() => _city = v);
            final c = v.trim();
            _save(ProfilesCompanion(city: Value(c.isEmpty ? null : c)));
          },
        ),
      ],
    );
  }
}
