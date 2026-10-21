// Вкладка «Ещё»: разделы анкеты, план/расписание, язык, данные (экспорт/импорт), о приложении.
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../core/capabilities/capability_service.dart';
import '../../core/data/profile_repository.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../home/widgets/finance_summary_panel.dart';
import '../onboarding/onboarding_progress.dart';
import '../onboarding/onboarding_step.dart';
import 'backup/backup_platform.dart';
import 'backup/backup_service.dart';
import 'settings_summaries.dart';

/// Версия приложения. CI может передать `--dart-define=APP_VERSION=…`; без package_info.
const kAppVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

/// Значение «Как в системе» в переключателе языка (в БД — null).
const _systemLocale = '';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _includePhotos = true;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      bottom: false,
      child: ListView(
        key: const Key('settings-list'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const FinanceSummaryPanel(),
          const SizedBox(height: 16),
          _questionnairePanel(l),
          const SizedBox(height: 16),
          SysPanel(
            title: l.setSectionPlan,
            appearDelay: const Duration(milliseconds: 40),
            child: Column(
              children: [
                _NavRow(
                  glyph: SysGlyph.book,
                  title: l.setPlan,
                  hint: l.setPlanHint,
                  onTap: () => context.push(Routes.plan),
                ),
                _NavRow(
                  glyph: SysGlyph.clock,
                  title: l.setSchedule,
                  hint: l.setScheduleHint,
                  onTap: () => context.push(Routes.schedule),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SysPanel(
            title: l.setSectionQuests,
            appearDelay: const Duration(milliseconds: 60),
            child: Column(
              children: [
                _NavRow(
                  glyph: SysGlyph.bell,
                  title: l.setReminders,
                  hint: l.setRemindersHint,
                  onTap: () => context.push(Routes.reminders),
                ),
                _NavRow(
                  glyph: SysGlyph.shield,
                  title: l.setDiscipline,
                  hint: l.setDisciplineHint,
                  onTap: () => context.push(Routes.discipline),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _languagePanel(l),
          const SizedBox(height: 16),
          _dataPanel(l),
          const SizedBox(height: 16),
          _aboutPanel(l),
        ],
      ),
    );
  }

  // ---------- Анкета ----------

  Widget _questionnairePanel(AppLocalizations l) {
    final profile = ref.watch(profileProvider).value;
    final goals = ref.watch(settingsGoalsCountProvider).value ?? 0;
    final weight = ref.watch(settingsLatestWeightProvider).value;

    String? summary(OnboardingStep step) => switch (step) {
          OnboardingStep.profile => (profile?.name.trim().isNotEmpty ?? false) ? profile!.name.trim() : null,
          OnboardingStep.body => _bodySummary(l, profile?.heightCm, weight),
          OnboardingStep.goals => goals > 0 ? l.setGoalsCount(goals) : null,
          _ => null,
        };

    return SysPanel(
      title: l.setSectionQuestionnaire,
      child: Column(
        children: [
          for (final step in OnboardingStep.values)
            _NavRow(
              key: Key('settings-step-${step.name}'),
              glyph: step.glyph,
              title: step.title(l),
              trailing: summary(step),
              onTap: () => context.push(Routes.editStep(step)),
            ),
        ],
      ),
    );
  }

  static String? _bodySummary(AppLocalizations l, double? height, double? weight) {
    final parts = [
      if (height != null) l.setHeightValue(formatSettingsNumber(height)),
      if (weight != null) l.setWeightValue(formatSettingsNumber(weight)),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  // ---------- Язык ----------

  Widget _languagePanel(AppLocalizations l) {
    final profile = ref.watch(profileProvider).value;
    return SysPanel(
      title: l.setSectionLanguage,
      appearDelay: const Duration(milliseconds: 80),
      child: SysSegmented<String>(
        key: const Key('settings-language'),
        choices: [
          SysChoice('ru', l.setLangRu),
          SysChoice('tr', l.setLangTr),
          SysChoice(_systemLocale, l.setLangSystem),
        ],
        value: profile?.locale ?? _systemLocale,
        onChanged: (v) => ref
            .read(profileRepositoryProvider)
            .update(ProfilesCompanion(locale: Value(v == _systemLocale ? null : v))),
      ),
    );
  }

  // ---------- Данные ----------

  Widget _dataPanel(AppLocalizations l) => SysPanel(
        title: l.setSectionData,
        appearDelay: const Duration(milliseconds: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NavRow(
              key: const Key('settings-export'),
              glyph: SysGlyph.send,
              title: l.setExport,
              hint: l.setExportHint,
              onTap: _busy ? null : _export,
            ),
            if (kIsWeb)
              Padding(
                padding: const EdgeInsets.only(left: 32, bottom: 6),
                child: Text(l.setPhotosWebNote, style: SysText.caption),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: SysSwitchRow(
                  label: l.setIncludePhotos,
                  hint: l.setIncludePhotosHint,
                  value: _includePhotos,
                  onChanged: (v) => setState(() => _includePhotos = v),
                ),
              ),
            _NavRow(
              key: const Key('settings-import'),
              glyph: SysGlyph.arrowDown,
              title: l.setImport,
              hint: l.setImportHint,
              onTap: _busy ? null : _import,
            ),
            _NavRow(
              key: const Key('settings-restart'),
              glyph: SysGlyph.bolt,
              title: l.setRestart,
              hint: l.setRestartHint,
              onTap: _busy ? null : _restart,
            ),
          ],
        ),
      );

  Rect? _shareOrigin() {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _export() async {
    final l = AppLocalizations.of(context);
    final origin = _shareOrigin();
    setState(() => _busy = true);
    try {
      final service = ref.read(backupServiceProvider);
      final bytes = await service.exportBytes(includePhotos: _includePhotos && !kIsWeb);
      await ref.read(backupSaverProvider).save(service.suggestedFileName(), bytes, origin: origin);
    } on BackupUnavailableException {
      await _message(SystemWindowKind.failed, l.setErrorLabel, l.setShareUnavailable);
    } catch (e, st) {
      debugPrint('export failed: $e\n$st');
      await _message(SystemWindowKind.failed, l.setErrorLabel, l.setExportFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final service = ref.read(backupServiceProvider);
      final bytes = await ref.read(backupPickerProvider).pick();
      if (bytes == null || !mounted) return;

      final BackupPreview preview;
      try {
        preview = service.parse(bytes);
      } on BackupException catch (e) {
        await _message(SystemWindowKind.failed, l.setErrorLabel, _errorText(l, e.error));
        return;
      }
      if (!mounted) return;

      final confirmed = await showSystemWindow<bool>(
        context,
        window: SystemWindow(
          key: const Key('settings-import-preview'),
          kind: SystemWindowKind.warning,
          warningTone: PanelTone.danger,
          label: l.setWarningLabel,
          title: l.setImportPreviewTitle,
          message: _previewText(l, preview),
          actions: [
            Builder(
              builder: (ctx) => HoldButton(
                key: const Key('settings-import-confirm'),
                label: l.setImportReplace,
                duration: const Duration(seconds: 3),
                expand: true,
                semanticHint: l.setImportHoldHint,
                onCompleted: () => Navigator.of(ctx).pop(true),
              ),
            ),
            Builder(
              builder: (ctx) => SysButton.secondary(
                label: l.commonCancel,
                expand: true,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      try {
        await service.importData(preview);
      } catch (e, st) {
        debugPrint('import failed: $e\n$st');
        await _message(SystemWindowKind.failed, l.setErrorLabel, l.setImportFailed);
        return;
      }
      await _syncOnboarding();
      if (mounted) await _message(SystemWindowKind.notice, l.setNoticeLabel, l.setImportDone);
    } on BackupUnavailableException {
      await _message(SystemWindowKind.failed, l.setErrorLabel, l.setPickUnavailable);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// OnboardingProgress кэширует значения — перечитать импортированные (роутер сам уведёт на анкету, если нужно).
  Future<void> _syncOnboarding() async {
    final OnboardingProgress progress;
    try {
      progress = ref.read(onboardingProgressProvider);
    } catch (_) {
      return; // не переопределён (тесты)
    }
    await progress.reload();
  }

  String _previewText(AppLocalizations l, BackupPreview preview) {
    final lines = <String>[];
    final at = preview.exportedAt;
    if (at != null) {
      final tag = Localizations.localeOf(context).toLanguageTag();
      lines.add(l.setImportExportedAt(DateFormat.yMMMd(tag).add_Hm().format(at.toLocal())));
    }
    for (final e in preview.rowCounts.entries) {
      if (e.value > 0) lines.add(l.setImportRows(_tableLabel(l, e.key), e.value));
    }
    lines.add(preview.photoCount > 0 ? l.setImportPhotos(preview.photoCount) : l.setImportNoPhotos);
    lines.add('');
    lines.add(l.setImportWarning);
    return lines.join('\n');
  }

  static String _tableLabel(AppLocalizations l, String table) => switch (table) {
        'app_settings' => l.setTableAppSettings,
        'profiles' => l.setTableProfiles,
        'body_measurements' => l.setTableBodyMeasurements,
        'photos' => l.setTablePhotos,
        'goals' => l.setTableGoals,
        'schedule_settings' => l.setTableScheduleSettings,
        'schedule_items' => l.setTableScheduleItems,
        'plans' => l.setTablePlans,
        'questionnaire_sections' => l.setTableQuestionnaireSections,
        _ => table,
      };

  static String _errorText(AppLocalizations l, BackupError e) => switch (e) {
        BackupError.notJson => l.setErrNotJson,
        BackupError.wrongFormat => l.setErrWrongFormat,
        BackupError.unsupportedFormatVersion => l.setErrFormatVersion,
        BackupError.newerSchema => l.setErrNewerSchema,
        BackupError.invalid => l.setErrInvalid,
      };

  Future<void> _restart() async {
    final l = AppLocalizations.of(context);
    final ok = await showSystemWindow<bool>(
      context,
      window: SystemWindow(
        kind: SystemWindowKind.warning,
        label: l.setWarningLabel,
        title: l.setRestart,
        message: l.setRestartMessage,
        actions: [
          Builder(
            builder: (ctx) => SysButton.primary(
              key: const Key('settings-restart-confirm'),
              label: l.setRestartConfirm,
              expand: true,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ),
          Builder(
            builder: (ctx) => SysButton.secondary(
              label: l.commonCancel,
              expand: true,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted) await ref.read(onboardingProgressProvider).restart();
  }

  Future<void> _message(SystemWindowKind kind, String label, String message) async {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    await showSystemWindow<void>(
      context,
      window: SystemWindow(
        kind: kind,
        label: label,
        message: message,
        actions: [
          Builder(
            builder: (ctx) => SysButton.secondary(
              label: l.commonClose,
              expand: true,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- О приложении ----------

  Widget _aboutPanel(AppLocalizations l) {
    final caps = ref.watch(deviceCapabilitiesProvider).value;
    final expires = caps?.provisioningExpiresAt;
    final platform = switch (caps?.platform) {
      null => null,
      'ios' => 'iOS', // названия платформ не переводятся
      'android' => 'Android',
      _ => l.setPlatformOther,
    };
    final tag = Localizations.localeOf(context).toLanguageTag();
    return SysPanel(
      title: l.setSectionAbout,
      appearDelay: const Duration(milliseconds: 160),
      child: Column(
        children: [
          _InfoRow(label: l.setVersion, value: kAppVersion),
          if (platform != null) _InfoRow(label: l.setPlatform, value: platform),
          if (expires != null)
            _InfoRow(label: l.setCertExpires, value: DateFormat.yMMMd(tag).format(expires.toLocal())),
        ],
      ),
    );
  }
}

/// Строка-переход: иконка, название, подсказка, итог справа.
class _NavRow extends StatelessWidget {
  const _NavRow({super.key, required this.glyph, required this.title, required this.onTap, this.hint, this.trailing});

  final SysGlyph glyph;
  final String title;
  final String? hint;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final h = hint;
    final t = trailing;
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: SysDims.minTap),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SysIcon(glyph, size: 20, color: onTap == null ? SysColors.textInactive : SysColors.accentLight),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: SysText.body),
                        if (h != null) Text(h, style: SysText.caption),
                      ],
                    ),
                  ),
                  if (t != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        t,
                        style: SysText.monoSmall.copyWith(color: SysColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 20, color: SysColors.textInactive),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(label, style: SysText.secondary)),
            const SizedBox(width: 12),
            Flexible(child: Text(value, style: SysText.mono, textAlign: TextAlign.end)),
          ],
        ),
      );
}
