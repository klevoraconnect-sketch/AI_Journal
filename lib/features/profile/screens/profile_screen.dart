import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/logic/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user?.email ?? 'Unknown User',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          _buildOption(context, 'Personal Details', Icons.person_outline),
          _buildOption(context, 'Encryption Settings', Icons.lock_outline),
          _buildOption(context, 'Subscription', Icons.star_outline),
          const Divider(),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
