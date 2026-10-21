import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_repository.dart';

/// Язык интерфейса из профиля (Profiles.locale). null — язык системы.
/// Шаг «Профиль» и настройки меняют язык через ProfileRepository.update(locale: …) — приложение подхватит само.
final appLocaleProvider = Provider<Locale?>((ref) {
  final code = ref.watch(profileProvider).value?.locale;
  return code == null || code.isEmpty ? null : Locale(code);
});
