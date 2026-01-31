import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/chat_provider.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, size: 20, color: Colors.amber),
            SizedBox(width: 8),
            Text('AI Assistant'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => ref.read(chatProvider.notifier).clearChat(),
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? const Center(
                    child: Text('Start a conversation with your AI guide.'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      return _ChatBubble(message: message);
                    },
                  ),
          ),
          if (chatState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Ask about your entries or self-growth...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                onSubmitted: (value) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.blue),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 0),
            bottomRight: Radius.circular(message.isUser ? 0 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : null,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
