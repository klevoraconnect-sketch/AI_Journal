import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SentimentChart extends StatelessWidget {
  final List<double> sentimentValues;

  const SentimentChart({super.key, required this.sentimentValues});

  @override
  Widget build(BuildContext context) {
    if (sentimentValues.isEmpty) {
      return const Center(child: Text('Not enough data for sentiment trends.'));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: sentimentValues.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
