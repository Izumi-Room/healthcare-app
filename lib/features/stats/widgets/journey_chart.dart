import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../models/health_report.dart';
import '../providers/stats_provider.dart';

class JourneyChart extends ConsumerWidget {
  const JourneyChart({super.key, this.isEmptyState = false});

  final bool isEmptyState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    
    // Get correct data based on period
    final List<HealthDayReport> rawData;
    if (isEmptyState) {
      rawData = [];
    } else {
      switch (period) {
        case ReportPeriod.daily:
          rawData = ref.watch(statsProvider);
          break;
        case ReportPeriod.weekly:
          rawData = ref.watch(weeklyStatsProvider);
          break;
        case ReportPeriod.monthly:
          rawData = ref.watch(monthlyStatsProvider);
          break;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perkembangan Kesehatan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEmptyState ? 'Belum ada data' : _subtitleFor(period),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: SegmentedButton<ReportPeriod>(
                segments: const [
                  ButtonSegment(
                    value: ReportPeriod.daily,
                    label: Text('Harian', style: TextStyle(fontSize: 12)),
                  ),
                  ButtonSegment(
                    value: ReportPeriod.weekly,
                    label: Text('Mingguan', style: TextStyle(fontSize: 12)),
                  ),
                  ButtonSegment(
                    value: ReportPeriod.monthly,
                    label: Text('Bulanan', style: TextStyle(fontSize: 12)),
                  ),
                ],
                selected: {period},
                onSelectionChanged: (val) {
                  ref.read(reportPeriodProvider.notifier).state = val.first;
                },
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: isEmptyState || rawData.isEmpty
                  ? _buildEmptyStateChart(context)
                  : _buildLineChart(context, rawData, period),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitleFor(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.daily:
        return '30 hari terakhir';
      case ReportPeriod.weekly:
        return '5 minggu terakhir';
      case ReportPeriod.monthly:
        return '6 bulan terakhir';
    }
  }

  Widget _buildEmptyStateChart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 48, color: AppColors.textSecondary.withValues(alpha: .3)),
          const SizedBox(height: 8),
          Text(
            'Grafik akan muncul setelah Anda mencatat aktivitas.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(
    BuildContext context,
    List<HealthDayReport> reports,
    ReportPeriod period,
  ) {
    // Determine step size and format
    final points = <FlSpot>[];
    for (var i = 0; i < reports.length; i++) {
      points.add(FlSpot(i.toDouble(), reports[i].score.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => const FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: period == ReportPeriod.daily ? 6 : 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= reports.length) return const SizedBox();
                final date = reports[idx].date;
                
                String label;
                if (period == ReportPeriod.daily) {
                  label = DateFormat.d().format(date);
                } else if (period == ReportPeriod.weekly) {
                  label = 'W${idx + 1}';
                } else {
                  label = DateFormat.MMM().format(date);
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (reports.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => AppColors.textPrimary,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final idx = spot.x.toInt();
                if (idx >= 0 && idx < reports.length) {
                  final date = reports[idx].date;
                  final formattedDate = period == ReportPeriod.daily
                      ? DateFormat.MMMd().format(date)
                      : period == ReportPeriod.weekly
                          ? 'Minggu ke-${idx + 1}'
                          : DateFormat.yMMM().format(date);
                  return LineTooltipItem(
                    '$formattedDate\nScore: ${spot.y.toInt()}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: points,
            isCurved: true,
            color: AppColors.green400,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.green400.withValues(alpha: .35),
                  AppColors.green400.withValues(alpha: .01),
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
