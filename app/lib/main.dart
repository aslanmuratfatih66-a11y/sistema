import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/capabilities/capability_service.dart';
import 'core/capabilities/platform_capability_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(
    overrides: [
      capabilityServiceProvider.overrideWithValue(PlatformCapabilityService()),
    ],
    child: const SistemaApp(),
  ));
}
