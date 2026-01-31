import 'package:go_router/go_router.dart';
import '../../../features/auth/screens/login_screen.dart';
import '../../../features/auth/screens/signup_screen.dart';
import '../../../features/auth/screens/onboarding_screen.dart';
import '../../../features/auth/screens/forgot_password_screen.dart';
import '../../../features/journal/ui/timeline_screen.dart';
import '../../../features/journal/ui/entry_editor_screen.dart';
import '../../../features/journal/models/journal_entry.dart';
import '../../main.dart'; // For AuthWrapper

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const TimelineScreen(),
    ),
    GoRoute(
      path: '/editor',
      builder: (context, state) {
        final entry = state.extra as JournalEntry?;
        return EntryEditorScreen(entry: entry);
      },
    ),
  ],
);
