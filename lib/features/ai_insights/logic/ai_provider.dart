import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';
import '../../journal/models/journal_entry.dart';
import '../../journal/data/journal_service.dart';

final geminiServiceProvider = Provider((ref) => GeminiService());

final aiAnalysisProvider =
    StateNotifierProvider<AINotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return AINotifier(
      ref.watch(geminiServiceProvider), ref.watch(journalServiceProvider));
});

class AINotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final GeminiService _aiService;
  final JournalService _journalService;

  AINotifier(this._aiService, this._journalService)
      : super(const AsyncValue.data({}));

  /// Analyzes an entry and saves results to Supabase
  Future<void> analyzeAndSave(JournalEntry entry) async {
    state = const AsyncValue.loading();
    try {
      final results = await _aiService.analyzeEntry(entry);

      final updatedEntry = entry.copyWith(
        sentimentScore: results['sentiment_score'],
        aiReflection: results['ai_reflection'],
        moodTag: results['mood_tag'] ?? entry.moodTag,
      );

      await _journalService.updateEntry(updatedEntry);

      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final dailyPromptProvider = FutureProvider<String>((ref) async {
  final aiService = ref.watch(geminiServiceProvider);
  return await aiService.generateDailyPrompt();
});
