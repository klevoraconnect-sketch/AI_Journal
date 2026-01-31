import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentiment_dart/sentiment_dart.dart';
import '../data/journal_service.dart';
import '../models/journal_entry.dart';
import '../../auth/logic/auth_provider.dart';

final journalProvider =
    StateNotifierProvider<JournalNotifier, JournalState>((ref) {
  final authState = ref.watch(authProvider);
  final notifier = JournalNotifier(ref.watch(journalServiceProvider));

  // Reload entries whenever the user changes (e.g. login/logout)
  if (authState.user != null) {
    notifier.loadEntries();
  }

  return notifier;
});

class JournalState {
  final List<JournalEntry> entries;
  final bool isLoading;
  final String? errorMessage;

  JournalState({
    this.entries = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  JournalState copyWith({
    List<JournalEntry>? entries,
    bool? isLoading,
    String? errorMessage,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class JournalNotifier extends StateNotifier<JournalState> {
  final JournalService _journalService;

  JournalNotifier(this._journalService) : super(JournalState());

  Future<void> loadEntries() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final entries = await _journalService.fetchEntries();
      if (!mounted) return;
      state = state.copyWith(entries: entries, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<JournalEntry?> addEntry(JournalEntry entry) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Automatic Sentiment Analysis
      final cleanContent =
          entry.content.replaceAll(RegExp(r'\[\[image:(.*?)\]\]'), '');
      final analysis = Sentiment.analysis('${entry.title ?? ""} $cleanContent');
      final score = analysis.score;

      String mood;
      if (score > 1) {
        mood = 'Positive';
      } else if (score < -1) {
        mood = 'Negative';
      } else {
        mood = 'Neutral';
      }

      final entryWithMood = entry.copyWith(moodTag: mood);
      final newEntry = await _journalService.createEntry(entryWithMood);
      if (!mounted) return newEntry;
      state = state.copyWith(
        entries: [newEntry, ...state.entries],
        isLoading: false,
      );
      return newEntry;
    } catch (e) {
      if (!mounted) return null;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<JournalEntry?> updateEntry(JournalEntry entry) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Automatic Sentiment Analysis
      final cleanContent =
          entry.content.replaceAll(RegExp(r'\[\[image:(.*?)\]\]'), '');
      final analysis = Sentiment.analysis('${entry.title ?? ""} $cleanContent');
      final score = analysis.score;

      String mood;
      if (score > 1) {
        mood = 'Positive';
      } else if (score < -1) {
        mood = 'Negative';
      } else {
        mood = 'Neutral';
      }

      final entryWithMood = entry.copyWith(moodTag: mood);
      final updatedEntry = await _journalService.updateEntry(entryWithMood);
      if (!mounted) return updatedEntry;
      state = state.copyWith(
        entries: state.entries
            .map((e) => e.id == entry.id ? updatedEntry : e)
            .toList(),
        isLoading: false,
      );
      return updatedEntry;
    } catch (e) {
      if (!mounted) return null;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<void> deleteEntry(String entryId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _journalService.deleteEntry(entryId);
      if (!mounted) return;
      state = state.copyWith(
        entries: state.entries.where((e) => e.id != entryId).toList(),
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<String?> uploadImage(File file) async {
    try {
      return await _journalService.uploadImage(file);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }
}
