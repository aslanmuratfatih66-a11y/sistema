// Редактор награды: название, цена ◆, лимит частоты; архивирование.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../schedule/widgets/schedule_common.dart' show ScheduleSubPage;
import 'shop_providers.dart';
import 'shop_rules.dart';

/// Открыть редактор: [reward] — правка, иначе новая (с подсказкой названия [initialTitle]).
Future<void> openRewardEditor(BuildContext context, {Reward? reward, String? initialTitle, int? initialPrice}) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => RewardEditorScreen(reward: reward, initialTitle: initialTitle, initialPrice: initialPrice),
    ));

class RewardEditorScreen extends ConsumerStatefulWidget {
  const RewardEditorScreen({super.key, this.reward, this.initialTitle, this.initialPrice});

  final Reward? reward;
  final String? initialTitle;
  final int? initialPrice;

  @override
  ConsumerState<RewardEditorScreen> createState() => _RewardEditorScreenState();
}

class _RewardEditorScreenState extends ConsumerState<RewardEditorScreen> {
  late String _title = widget.reward?.title ?? widget.initialTitle ?? '';
  late int? _price = widget.reward?.price ?? widget.initialPrice;
  late RewardLimitPeriod? _period = widget.reward?.hasLimit ?? false ? widget.reward!.limitPeriod : null;
  late int? _count = widget.reward?.limitCount ?? 1;
  bool _tried = false;
  bool _busy = false;

  RewardDraft get _draft => RewardDraft(title: _title, price: _price ?? 0, limitCount: _count, limitPeriod: _period);

  Future<void> _save() async {
    setState(() => _tried = true);
    final d = _draft;
    if (!d.isValid || _busy) return;
    setState(() => _busy = true);
    final repo = ref.read(rewardRepositoryProvider);
    final r = widget.reward;
    if (r == null) {
      await repo.create(d);
    } else {
      await repo.update(r.id, d);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _archive() async {
    final r = widget.reward;
    if (r == null || _busy) return;
    setState(() => _busy = true);
    await ref.read(rewardRepositoryProvider).setArchived(r.id, true);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = _draft;
    final editing = widget.reward != null;
    return ScheduleSubPage(
      title: editing ? l.shpEditorEdit : l.shpEditorNew,
      onBack: () => Navigator.of(context).pop(),
      bottom: SysButton.primary(
        key: const Key('shp-editor-save'),
        label: l.commonSave,
        expand: true,
        onPressed: _busy ? null : _save,
      ),
      child: SysPanel(
        tone: PanelTone.gold,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SysFieldLabel(l.shpFieldTitle),
            SysTextField(
              key: const Key('shp-editor-title'),
              value: _title,
              hint: l.shpFieldTitleHint,
              errorText: _tried && !d.titleValid ? l.commonRequired : null,
              onChanged: (v) => setState(() => _title = v),
            ),
            const SysFieldGap(),
            SysFieldLabel(l.shpFieldPrice, hint: l.shpFieldPriceHint),
            SysNumberField(
              key: const Key('shp-editor-price'),
              value: _price,
              unit: '◆',
              decimal: false,
              min: RewardDraft.minPrice,
              max: RewardDraft.maxPrice,
              outOfRangeText: l.shpErrorPrice,
              onChanged: (v) => setState(() => _price = v?.round()),
            ),
            if (_tried && _price == null) ...[
              const SizedBox(height: 4),
              Text(l.shpErrorPrice, style: SysText.caption.copyWith(color: SysColors.dangerLight)),
            ],
            const SysFieldGap(),
            SysFieldLabel(l.shpFieldLimit),
            SysSegmented<RewardLimitPeriod?>(
              choices: [
                SysChoice(null, l.shpPeriodNone),
                SysChoice(RewardLimitPeriod.day, l.shpPeriodDay),
                SysChoice(RewardLimitPeriod.week, l.shpPeriodWeek),
                SysChoice(RewardLimitPeriod.month, l.shpPeriodMonth),
              ],
              value: _period,
              onChanged: (v) => setState(() => _period = v),
            ),
            if (_period != null) ...[
              const SizedBox(height: 12),
              SysNumberField(
                key: const Key('shp-editor-count'),
                value: _count,
                label: l.shpFieldLimitCount,
                decimal: false,
                min: RewardDraft.minCount,
                max: RewardDraft.maxCount,
                outOfRangeText: l.shpErrorCount,
                onChanged: (v) => setState(() => _count = v?.round()),
              ),
            ],
            if (editing) ...[
              const SizedBox(height: 24),
              SysButton.danger(
                key: const Key('shp-editor-archive'),
                label: l.shpToArchive,
                expand: true,
                onPressed: _busy ? null : _archive,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
