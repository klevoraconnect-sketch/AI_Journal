import 'package:go_router/go_router.dart';
import '../../../features/auth/screens/login_screen.dart';
import '../../../features/auth/screens/signup_screen.dart';
import '../../../features/auth/screens/onboarding_screen.dart';
import '../../../features/auth/screens/forgot_password_screen.dart';
import '../../main.dart'; // For PlaceholderHomeScreen and AuthWrapper

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
      builder: (context, state) => const PlaceholderHomeScreen(),
    ),
  ],
);
