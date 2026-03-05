import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/studio/screens/studio_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/library/screens/library_screen.dart';
import '../../features/debate/screens/debate_screen.dart';
import '../../features/audiobook/screens/pdf_upload_screen.dart';
import '../../features/audiobook/screens/audiobook_player_screen.dart';
import '../../features/podcast/screens/podcast_screen.dart';
import '../../features/voice_chat/screens/voice_chat_screen.dart';
import '../../../core/widgets/shell_scaffold.dart';
import '../../models/persona_model.dart';

// Route names
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const studio = '/studio';
  static const library = '/library';
  static const debate = '/debate';
  static const settings = '/settings';
  static const audiobook = '/audiobook';
  static const pdfUpload = '/pdf-upload';
  static const podcast = '/podcast';
  static const persona = '/persona';
  static const voiceChat = '/voice-chat';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash;

      // Always allow splash screen to handle its own navigation
      if (state.matchedLocation == AppRoutes.splash) return null;

      // Redirect unauthenticated users to login (except from auth routes)
      if (!isAuthenticated && !isAuthRoute) return AppRoutes.login;
      
      // Redirect authenticated users away from login/register (but NOT splash)
      if (isAuthenticated && (state.matchedLocation == AppRoutes.login || state.matchedLocation == AppRoutes.register)) {
        return AppRoutes.studio;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.studio,
            builder: (context, state) => const StudioScreen(),
          ),
          GoRoute(
            path: AppRoutes.library,
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: AppRoutes.debate,
            builder: (context, state) => const DebateScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.audiobook,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return AudiobookPlayerScreen(
            title: extras?['title'] ?? 'Unknown',
            text: extras?['text'] ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.pdfUpload,
        builder: (context, state) => const PdfUploadScreen(),
      ),
      GoRoute(
        path: AppRoutes.podcast,
        builder: (context, state) => const PodcastScreen(),
      ),
      GoRoute(
        path: AppRoutes.voiceChat,
        builder: (context, state) {
          final persona = state.extra as PersonaModel;
          return VoiceChatScreen(persona: persona);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.error}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
});
