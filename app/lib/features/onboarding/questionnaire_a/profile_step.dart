import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/profile_repository.dart';
import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../step_scope.dart';
import 'data/cities.dart';
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
  final _cityController = TextEditingController();
  final _cityFocus = FocusNode();

  /// Город, по которому сейчас выставлен пояс (для подписи под полем пояса).
  City? _tzCity;

  @override
  void initState() {
    super.initState();
    _cityFocus.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _cityFocus.dispose();
    super.dispose();
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
      _cityController.text = p?.city ?? '';
      final city = findCity(_cityController.text);
      if (city != null && _timezone == timezoneFromOffset(Duration(hours: city.utcOffsetHours))) _tzCity = city;
    });
    if (_timezone == null) {
      // По умолчанию — пояс устройства.
      final tz = deviceTimezone();
      setState(() => _timezone = tz);
      _save(ProfilesCompanion(timezone: Value(tz)));
    }
  }

  void _save(ProfilesCompanion patch) => _writer.run(() => ref.read(profileRepositoryProvider).update(patch));

  void _setTimezone(String tz, {City? fromCity}) {
    setState(() {
      _timezone = tz;
      _tzCity = fromCity;
    });
    _save(ProfilesCompanion(timezone: Value(tz)));
  }

  void _onCityChanged(String text) {
    final c = text.trim();
    _save(ProfilesCompanion(city: Value(c.isEmpty ? null : c)));
    // Точное совпадение со справочником — сразу подставляем пояс города.
    final city = findCity(c);
    if (city != null) {
      _setTimezone(timezoneFromOffset(Duration(hours: city.utcOffsetHours)), fromCity: city);
    } else {
      setState(() {});
    }
  }

  void _pickCity(City city) {
    final name = city.name(Localizations.localeOf(context).languageCode);
    _cityController.value = TextEditingValue(text: name, selection: TextSelection.collapsed(offset: name.length));
    _cityFocus.unfocus();
    _onCityChanged(name);
  }

  Future<void> _pickTimezone() async {
    final l = AppLocalizations.of(context);
    final current = _timezone;
    final device = deviceTimezone();
    final lang = Localizations.localeOf(context).languageCode;
    // Текущий пояс телефона — первым, дальше по порядку.
    final options = [device, ...timezoneOptions.where((t) => t != device)];
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
                      subtitle: _zoneSubtitle(l, tz, device, lang),
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
    if (picked != null && picked != current) _setTimezone(picked);
  }

  Widget? _zoneSubtitle(AppLocalizations l, String tz, String device, String lang) {
    final hours = wholeHoursOf(tz);
    final examples = hours == null ? const <City>[] : citiesForOffset(hours);
    final parts = [
      if (tz == device) l.qaTzDeviceBadge,
      if (examples.isNotEmpty) examples.map((c) => c.name(lang)).join(', '),
    ];
    return parts.isEmpty ? null : Text(parts.join(' · '), style: SysText.caption);
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
    final lang = Localizations.localeOf(context).languageCode;
    final cityText = _cityController.text.trim();
    final suggestions =
        _cityFocus.hasFocus && findCity(cityText) == null ? suggestCities(cityText) : const <City>[];
    final tzCity = _tzCity;
    final String? tzNote = tzCity != null
        ? l.qaTzFromCity(tzCity.name(lang))
        : tz == deviceTimezone()
            ? l.qaTzFromDevice
            : null;
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
        SysFieldLabel(l.qaProfileCity, hint: l.qaTzCityHint, optional: true, optionalLabel: l.commonOptional),
        TextField(
          controller: _cityController,
          focusNode: _cityFocus,
          textCapitalization: TextCapitalization.words,
          style: SysText.body,
          cursorColor: SysColors.accentLight,
          onChanged: _onCityChanged,
        ),
        if (suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SysChoiceChips<City>(
              choices: [
                for (final c in suggestions) SysChoice(c, '${c.name(lang)}  ${displayTimezone(timezoneFromOffset(Duration(hours: c.utcOffsetHours)))}'),
              ],
              selected: const {},
              onChanged: (sel) {
                if (sel.isNotEmpty) _pickCity(sel.first);
              },
            ),
          ),
        const SysFieldGap(),
        SysFieldLabel(l.qaProfileTimezone),
        SysPickerField(
          text: tz == null ? null : displayTimezone(tz),
          glyph: SysGlyph.clock,
          onTap: _pickTimezone,
        ),
        if (tzNote != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(tzNote, style: SysText.caption),
          ),
      ],
    );
  }
}
