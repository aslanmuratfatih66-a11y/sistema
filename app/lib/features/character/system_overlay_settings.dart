// Переключатель «Персонаж поверх приложений» (только Android; на других платформах — пусто).
// Включение запрашивает разрешение «Поверх других приложений» и сохраняет
// CharacterSystemOverlay.settingKey = 'true'.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'character_system_overlay.dart';

class SystemOverlaySettingsTile extends ConsumerStatefulWidget {
  const SystemOverlaySettingsTile({super.key});

  @override
  ConsumerState<SystemOverlaySettingsTile> createState() => _SystemOverlaySettingsTileState();
}

class _SystemOverlaySettingsTileState extends ConsumerState<SystemOverlaySettingsTile> {
  bool? _enabled;
  bool _denied = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final overlay = ref.read(characterSystemOverlayProvider);
    if (!overlay.isSupported) return;
    var on = false;
    try {
      on = await ref.read(databaseProvider).getSetting(CharacterSystemOverlay.settingKey) == 'true';
      // Разрешение отозвали в настройках системы — показываем выключенным.
      if (on && !await overlay.hasPermission()) on = false;
    } catch (_) {
      on = false;
    }
    if (mounted) setState(() => _enabled = on);
  }

  Future<void> _toggle(bool v) async {
    if (_busy) return;
    setState(() => _busy = true);
    final overlay = ref.read(characterSystemOverlayProvider);
    var next = v;
    var denied = false;
    if (v && !await overlay.hasPermission()) {
      next = await overlay.requestPermission();
      denied = !next;
    }
    if (!next) unawaited(overlay.hide());
    try {
      await ref.read(databaseProvider).setSetting(CharacterSystemOverlay.settingKey, '$next');
    } catch (e) {
      debugPrint('SystemOverlaySettingsTile: $e');
    }
    if (mounted) {
      setState(() {
        _enabled = next;
        _denied = denied;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlay = ref.watch(characterSystemOverlayProvider);
    final enabled = _enabled;
    if (!overlay.isSupported || enabled == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SysSwitchRow(
          key: const Key('settings-character-system-overlay'),
          label: l.ovlSettingTitle,
          hint: l.ovlSettingHint,
          value: enabled,
          onChanged: _busy ? (_) {} : (v) => unawaited(_toggle(v)),
        ),
        if (_denied)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(l.ovlPermissionDenied, style: SysText.caption.copyWith(color: SysColors.dangerLight)),
          ),
      ],
    );
  }
}
