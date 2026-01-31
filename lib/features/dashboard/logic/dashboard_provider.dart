import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../journal/logic/journal_provider.dart';
import '../../journal/models/journal_entry.dart';

class DashboardStats {
  final int currentStreak;
  final int totalEntries;
  final Map<DateTime, int> entryDensity;
  final List<JournalEntry> recentActivities;

  DashboardStats({
    this.currentStreak = 0,
    this.totalEntries = 0,
    this.entryDensity = const {},
    this.recentActivities = const [],
  });
}

final dashboardProvider = Provider<DashboardStats>((ref) {
  final journalState = ref.watch(journalProvider);
  final entries = journalState.entries;

  if (entries.isEmpty) return DashboardStats();

  // Sort entries by date desc
  final sortedEntries = List<JournalEntry>.from(entries)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // Calculate Streak
  int streak = 0;
  DateTime today = DateTime.now();
  DateTime checkDate = DateTime(today.year, today.month, today.day);

  // Simple streak logic: check consecutive days
  for (var i = 0; i < sortedEntries.length; i++) {
    final entryDate = DateTime(
      sortedEntries[i].createdAt.year,
      sortedEntries[i].createdAt.month,
      sortedEntries[i].createdAt.day,
    );

    if (entryDate == checkDate) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else if (entryDate.isBefore(checkDate)) {
      // Streak broken
      break;
    }
  }

  // Entry density for calendar
  final Map<DateTime, int> density = {};
  for (final entry in entries) {
    final date = DateTime(
        entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
    density[date] = (density[date] ?? 0) + 1;
  }

  return DashboardStats(
    currentStreak: streak,
    totalEntries: entries.length,
    entryDensity: density,
    recentActivities: sortedEntries.take(5).toList(),
  );
});
