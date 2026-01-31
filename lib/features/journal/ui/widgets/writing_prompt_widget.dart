import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_insights/logic/ai_provider.dart';

class WritingPromptWidget extends ConsumerWidget {
  const WritingPromptWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptAsync = ref.watch(dailyPromptProvider);

    return Card(
      elevation: 0,
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'AI Writing Prompt',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh,
                      size: 18, color: Theme.of(context).primaryColor),
                  onPressed: () => ref.refresh(dailyPromptProvider),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            promptAsync.when(
              data: (prompt) => Text(
                prompt,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => const Text('Ready for today\'s entry?'),
            ),
          ],
        ),
      ),
    );
  }
}
