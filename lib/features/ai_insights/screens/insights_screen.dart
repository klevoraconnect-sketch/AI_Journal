import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sentiment_chart.dart';
import '../widgets/memory_recap_carousel.dart';
import '../../journal/logic/journal_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalState = ref.watch(journalProvider);
    final entries = journalState.entries;

    // Extract sentiment scores for the chart
    final sentimentScores = entries
        .where((e) => e.sentimentScore != null)
        .map((e) => e.sentimentScore!)
        .toList()
        .reversed
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Memory Recap',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const MemoryRecapCarousel(),
            const SizedBox(height: 32),
            _buildSentimentSection(context, sentimentScores),
            const SizedBox(height: 32),
            _buildMoodSummary(context, entries),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentSection(BuildContext context, List<double> scores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sentiment Trend',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              height: 200,
              child: SentimentChart(sentimentValues: scores),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSummary(BuildContext context, dynamic entries) {
    // Basic placeholder for mood frequency
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Frequency',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MoodChip(label: 'Joyful', count: 12, color: Colors.yellow),
            _MoodChip(label: 'Anxious', count: 4, color: Colors.purple),
            _MoodChip(label: 'Grateful', count: 8, color: Colors.green),
            _MoodChip(label: 'Productive', count: 15, color: Colors.blue),
          ],
        ),
      ],
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _MoodChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label ($count)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
