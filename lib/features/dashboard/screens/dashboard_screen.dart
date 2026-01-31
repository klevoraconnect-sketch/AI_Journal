import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../logic/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights Dashboard')),
      body: RefreshIndicator(
        onRefresh: () => Future.value(true), // Handled by Riverpod watchers
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStreakCard(context, stats.currentStreak),
              const SizedBox(height: 24),
              const Text(
                'Your Growth',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatBox(context, 'Total Notes',
                      stats.totalEntries.toString(), Icons.edit_note),
                  const SizedBox(width: 16),
                  _buildStatBox(
                      context, 'Avg. Mood', 'Reflective', Icons.auto_awesome),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Activities',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (stats.recentActivities.isEmpty)
                const Center(
                    child:
                        Text('Begin your journey by writing your first entry!'))
              else
                ...stats.recentActivities
                    .map((e) => _buildActivityItem(context, e)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, int streak) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Colors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department,
              color: Colors.orange, size: 56),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak Day Streak!',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              const Text(
                'You are building a great habit.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(
      BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(value,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, dynamic entry) {
    final date = DateFormat('MMM d').format(entry.createdAt);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.history_outlined,
            color: Theme.of(context).primaryColor, size: 18),
      ),
      title:
          Text(entry.title?.isEmpty == false ? entry.title! : 'Untitled Entry'),
      subtitle: Text('Written on $date'),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: () {},
    );
  }
}
