import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../ai_insights/services/gemini_service.dart';
import '../../ai_insights/logic/ai_provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final gemini = ref.watch(geminiServiceProvider);
  return ChatNotifier(gemini);
});

class ChatNotifier extends StateNotifier<ChatState> {
  final GeminiService _gemini;

  ChatNotifier(this._gemini) : super(ChatState()) {
    // Initial greeting
    _addMessage(
        'Hello! I am your AI Journal assistant. How can I help you reflect today?',
        false);
  }

  void _addMessage(String text, bool isUser) {
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(text: text, isUser: isUser, timestamp: DateTime.now()),
      ],
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _addMessage(text, true);
    state = state.copyWith(isLoading: true, error: null);

    try {
      final history = state.messages.map((m) {
        return m.isUser
            ? Content.text(m.text)
            : Content.model([TextPart(m.text)]);
      }).toList();

      // Remove the message we just added so Geminis getChatResponse history is correct
      history.removeLast();

      final response = await _gemini.getChatResponse(history, text);
      _addMessage(response, false);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      _addMessage('Sorry, I am having trouble connecting right now.', false);
    }
  }

  void clearChat() {
    state = ChatState();
    _addMessage(
        'Hello! I am your AI Journal assistant. How can I help you reflect today?',
        false);
  }
}
