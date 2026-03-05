import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

import 'services/tts_audio_handler.dart';
import 'providers/service_providers.dart';
import 'package:audio_service/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase FIRST
  await Firebase.initializeApp();

  // Initialize Audio Handler AFTER Firebase
  final handler = await AudioService.init(
    builder: () => TtsAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.pocketaudio.channel.audio',
      androidNotificationChannelName: 'PocketAudio Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        ttsHandlerProvider.overrideWithValue(handler),
      ],
      child: const PocketAudioApp(),
    ),
  );
}

class PocketAudioApp extends ConsumerWidget {
  const PocketAudioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'PocketAudio Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
