import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../providers/stats_provider.dart';

class StatsSleepAnalysis extends ConsumerWidget {
  const StatsSleepAnalysis({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(statsProvider);
    // Take last 7 days for the trend line
    final last7 =
        reports.length >= 7 ? reports.sublist(reports.length - 7) : reports;

    // Calculate averages
    final avgSleep = last7.fold<int>(0, (s, r) => s + r.sleep) / last7.length;
    final avgScore = last7.fold<int>(0, (s, r) => s + r.score) / last7.length;

    // Sleep quality rating
    String qualityLabel;
    Color qualityColor;
    String qualityEmoji;
    if (avgSleep >= 20) {
      qualityLabel = 'Sangat Baik';
      qualityColor = const Color(0xFF22C55E);
      qualityEmoji = '😴';
    } else if (avgSleep >= 15) {
      qualityLabel = 'Baik';
      qualityColor = const Color(0xFF3B82F6);
      qualityEmoji = '🙂';
    } else if (avgSleep >= 10) {
      qualityLabel = 'Cukup';
      qualityColor = AppColors.amber300;
      qualityEmoji = '😐';
    } else {
      qualityLabel = 'Kurang';
      qualityColor = AppColors.danger;
      qualityEmoji = '😟';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              const Text('🌙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Analisis Tidur',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B4B).withValues(alpha: .04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: .2),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top stats row
              Row(
                children: [
                  Expanded(
                    child: _SleepStatBubble(
                      emoji: qualityEmoji,
                      label: 'Kualitas Tidur',
                      value: qualityLabel,
                      valueColor: qualityColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SleepStatBubble(
                      emoji: '📊',
                      label: 'Skor Rata-rata',
                      value: '${avgSleep.toStringAsFixed(1)}/25',
                      valueColor: const Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SleepStatBubble(
                      emoji: '📈',
                      label: 'Tren 7 Hari',
                      value: '${avgScore.toStringAsFixed(0)}%',
                      valueColor: const Color(0xFF06B6D4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Trend chart
              Text(
                'Tren Skor Tidur (7 Hari)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8B5CF6),
                    ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: _buildSleepChart(context, last7),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSleepChart(BuildContext context, List reports) {
    final spots = <FlSpot>[];
    for (var i = 0; i < reports.length; i++) {
      spots.add(FlSpot(i.toDouble(), reports[i].sleep.toDouble()));
    }

    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFF8B5CF6).withValues(alpha: .1),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 9,
                      color: AppColors.textSecondary.withValues(alpha: .5),
                    ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= reports.length) return const SizedBox();
                final weekday = reports[idx].date.weekday;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    days[weekday - 1],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                          color: AppColors.textSecondary.withValues(alpha: .6),
                        ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: reports.length <= 1 ? 1 : (reports.length - 1).toDouble(),
        minY: 0,
        maxY: 25,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1E1B4B),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  'Tidur: ${spot.y.toInt()}/25',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF8B5CF6),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF8B5CF6),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: .3),
                  const Color(0xFF8B5CF6).withValues(alpha: .01),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
      duration: AppAnimations.normal,
    );
  }
}

class _SleepStatBubble extends StatelessWidget {
  const _SleepStatBubble({
    required this.emoji,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String emoji;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withValues(alpha: .7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
