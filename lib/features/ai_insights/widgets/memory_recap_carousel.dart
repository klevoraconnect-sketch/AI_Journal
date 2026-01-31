import 'package:flutter/material.dart';

class MemoryRecapCarousel extends StatelessWidget {
  const MemoryRecapCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView(
        controller: PageController(viewportFraction: 0.9),
        children: const [
          _RecapCard(
            title: 'Last Week',
            content:
                'You focused on "Growth" and completed 5 entries. You are becoming more reflective!',
            color: Colors.blueAccent,
          ),
          _RecapCard(
            title: 'Monthly Theme',
            content:
                'Gratitude is your most common mindset this month. Your overall sentiment is up by 15%.',
            color: Colors.orangeAccent,
          ),
          _RecapCard(
            title: 'Memory Lane',
            content:
                'On this day last year, you were starting your fitness journey. Look how far you have come!',
            color: Colors.greenAccent,
          ),
        ],
      ),
    );
  }
}

class _RecapCard extends StatelessWidget {
  final String title;
  final String content;
  final Color color;

  const _RecapCard(
      {required this.title, required this.content, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            const Align(
              alignment: Alignment.bottomRight,
              child:
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}
