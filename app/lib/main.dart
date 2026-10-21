import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/capabilities/capability_service.dart';
import 'core/capabilities/platform_capability_service.dart';
import 'core/db/database.dart';
import 'core/voice/tts_service.dart';
import 'features/character/voice/flutter_tts_service.dart';
import 'features/onboarding/onboarding_progress.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  final onboarding = await OnboardingProgress.load(db);
  runApp(ProviderScope(
    overrides: [
      capabilityServiceProvider.overrideWithValue(PlatformCapabilityService()),
      databaseProvider.overrideWithValue(db),
      onboardingProgressProvider.overrideWithValue(onboarding),
      ttsServiceProvider.overrideWithValue(FlutterTtsService()),
    ],
    child: const SistemaApp(),
  ));
}
