import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'config/theme_config.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'AI Journal',
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const PlaceholderHomeScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const PlaceholderHomeScreen();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}

// Placeholder home screen for Phase 1
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Authentication Successful!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Text(
                  'Welcome, ${authProvider.currentUser?.displayName ?? authProvider.currentUser?.email ?? "User"}!',
                  style: Theme.of(context).textTheme.bodyLarge,
                );
              },
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Phase 1 (Authentication & Foundation) is complete!\n\n'
                'Next: Phase 2 will implement the core journaling features.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
