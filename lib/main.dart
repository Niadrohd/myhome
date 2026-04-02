import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'provider_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ProviderScope(
      parent: kProviderContainer,
      child: EasyDynamicThemeWidget(
        initialThemeMode: ThemeMode.light,
        child: const MyHomeApp(),
      ),
    ),
  );
}
