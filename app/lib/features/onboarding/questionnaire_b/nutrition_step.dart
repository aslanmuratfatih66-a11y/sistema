import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../step_scope.dart';
import 'common/section_state.dart';

/// Ключи магазинов (стабильные, хранятся в `stores`). Свой вариант хранится как текст.
const nutritionStoreKeys = [
  'pyaterochka',
  'magnit',
  'perekrestok',
  'vkusvill',
  'lenta',
  'auchan',
  'market',
  'delivery',
];

const nutritionWaterPresets = [500, 1000, 1500, 2000];

/// Этап 8 — питание (раздел nutrition).
class NutritionStep extends ConsumerStatefulWidget {
  const NutritionStep({super.key});

  @override
  ConsumerState<NutritionStep> createState() => _NutritionStepState();
}

class _NutritionStepState extends SectionStepState<NutritionStep> {
  @override
  QuestionnaireSection get section => QuestionnaireSection.nutrition;

  String _storeLabel(AppLocalizations l, String key) => switch (key) {
        'pyaterochka' => l.qbStorePyaterochka,
        'magnit' => l.qbStoreMagnit,
        'perekrestok' => l.qbStorePerekrestok,
        'vkusvill' => l.qbStoreVkusvill,
        'lenta' => l.qbStoreLenta,
        'auchan' => l.qbStoreAuchan,
        'market' => l.qbStoreMarket,
        'delivery' => l.qbStoreDelivery,
        _ => key,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final editing = StepScope.maybeOf(context)?.editing ?? false;
    if (!loaded) return const SectionLoading();

    final stores = strList('stores');
    final knownStores = stores.where(nutritionStoreKeys.contains).toSet();
    final customStores = stores.where((s) => !nutritionStoreKeys.contains(s)).join(', ');
    final water = intOf('waterNowMl');
    final canCook = data['canCook'] is String ? data['canCook']! as String : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!editing) StepIntro(l.qbNutritionIntro, style: SysText.secondary),
        SysFieldLabel(l.qbMealsPerDay),
        SysChoiceChips<int>(
          choices: [for (var i = 2; i <= 6; i++) SysChoice(i, '$i')],
          selected: {?intOf('mealsPerDay')},
          allowEmpty: false,
          onChanged: (s) => setValue('mealsPerDay', s.isEmpty ? null : s.first),
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qbPreferences, optional: true, optionalLabel: l.commonOptional),
        SysTextField(
          value: str('preferences'),
          hint: l.qbPreferencesHint,
          maxLines: 3,
          onChanged: (v) => setValue('preferences', v.trim().isEmpty ? null : v),
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qbExcluded, optional: true, optionalLabel: l.commonOptional),
        SysTextField(
          value: str('excluded'),
          hint: l.qbExcludedHint,
          maxLines: 3,
          onChanged: (v) => setValue('excluded', v.trim().isEmpty ? null : v),
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qbFoodBudget, optional: true, optionalLabel: l.commonOptional),
        SysNumberField(
          value: numOf('foodBudgetRubPerWeek'),
          unit: l.qbRubPerWeek,
          decimal: false,
          min: 0,
          max: 1000000,
          outOfRangeText: l.commonOutOfRange,
          onChanged: (v) => setValue('foodBudgetRubPerWeek', v),
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qbCanCook),
        SysSegmented<String>(
          choices: [
            SysChoice('no', l.qbCookNo),
            SysChoice('basic', l.qbCookBasic),
            SysChoice('good', l.qbCookGood),
          ],
          value: canCook,
          onChanged: (v) => setValue('canCook', v),
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qbStores, hint: l.qbStoresHint),
        SysChoiceChips<String>(
          multi: true,
          choices: [for (final k in nutritionStoreKeys) SysChoice(k, _storeLabel(l, k))],
          selected: knownStores,
          onChanged: (s) => setValue('stores', [
            for (final k in nutritionStoreKeys) if (s.contains(k)) k,
            ...stores.where((x) => !nutritionStoreKeys.contains(x)),
          ]),
        ),
        const SizedBox(height: 8),
        SysTextField(
          value: customStores,
          label: l.qbStoreOther,
          onChanged: (v) {
            final custom = [
              for (final part in v.split(',')) if (part.trim().isNotEmpty) part.trim(),
            ];
            setValue('stores', [...stores.where(nutritionStoreKeys.contains), ...custom]);
          },
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qbWaterNow, hint: l.qbWaterNowHint),
        SysChoiceChips<int>(
          choices: [
            for (final ml in nutritionWaterPresets)
              SysChoice(ml, ml == nutritionWaterPresets.last ? '$ml+' : '$ml'),
          ],
          selected: {if (water != null && nutritionWaterPresets.contains(water)) water},
          onChanged: (s) => setValue('waterNowMl', s.isEmpty ? null : s.first),
        ),
        const SizedBox(height: 8),
        SysNumberField(
          value: water,
          label: l.qbWaterExact,
          unit: l.qbMlPerDay,
          decimal: false,
          min: 0,
          max: 10000,
          outOfRangeText: l.commonOutOfRange,
          onChanged: (v) => setValue('waterNowMl', v?.round()),
        ),
      ],
    );
  }
}
