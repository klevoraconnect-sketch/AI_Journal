import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../journal/models/journal_entry.dart';
import '../../../config/ai_config.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: AIConfig.defaultModel,
      apiKey: AIConfig.geminiApiKey,
    );
  }

  /// Analyzes a journal entry and returns sentiment, mood, and insights.
  Future<Map<String, dynamic>> analyzeEntry(JournalEntry entry) async {
    final prompt = '''
    Analyze the following journal entry for an AI journaling app. 
    Provide:
    1. A sentiment score between -1.0 (extremely negative) and 1.0 (extremely positive).
    2. A primary mood tag (e.g., Joyful, Anxious, Grateful, Productive, Reflective).
    3. A short, empathetic AI reflection/insight (1-2 sentences) that encourages self-growth.

    Entry Title: ${entry.title ?? 'Untitled'}
    Entry Content: ${entry.content}

    Respond ONLY in JSON format:
    {
      "sentiment_score": 0.5,
      "mood_tag": "Productive",
      "ai_reflection": "Great job focusing on your goals today! Recognizing your wins builds momentum for tomorrow."
    }
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return _parseAIResponse(response.text ?? '{}');
    } catch (e) {
      return {
        "sentiment_score": 0.0,
        "mood_tag": "Neutral",
        "ai_reflection": "Could not generate reflection at this time."
      };
    }
  }

  /// Generates a unique journaling prompt for the user.
  Future<String> generateDailyPrompt() async {
    final prompt =
        'Generate a short, thought-provoking journaling prompt for a user today. Be concise.';
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text?.trim() ?? 'What are you grateful for today?';
    } catch (e) {
      return 'What made you smile today?';
    }
  }

  Map<String, dynamic> _parseAIResponse(String text) {
    try {
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}') + 1;
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonStr = text.substring(jsonStart, jsonEnd);
        return json.decode(jsonStr) as Map<String, dynamic>;
      }
      return json.decode(text) as Map<String, dynamic>;
    } catch (e) {
      return {
        "sentiment_score": 0.0,
        "mood_tag": "Neutral",
        "ai_reflection": "Error parsing AI response."
      };
    }
  }

  Future<String> getChatResponse(List<Content> history, String message) async {
    try {
      final chat = _model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(message));
      return response.text ?? 'I am sorry, I could not generate a response.';
    } catch (e) {
      throw Exception('Chat failed: $e');
    }
  }
}
