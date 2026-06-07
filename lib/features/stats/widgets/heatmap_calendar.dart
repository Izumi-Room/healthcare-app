import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../models/health_report.dart';

class HeatmapCalendar extends StatelessWidget {
  const HeatmapCalendar({super.key, required this.reports});

  final List<HealthDayReport> reports;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              const Text('🗓️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Kalender Konsistensi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '30 Hari',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reports.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return _HeatmapCell(report: report);
                },
              ),
              const SizedBox(height: 14),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Rendah',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary.withValues(alpha: .6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ..._buildLegendDots(),
                  const SizedBox(width: 8),
                  Text(
                    'Tinggi',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary.withValues(alpha: .6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLegendDots() {
    final levels = [
      AppColors.danger.withValues(alpha: .5),
      const Color(0xFFF97316).withValues(alpha: .55),
      AppColors.amber300.withValues(alpha: .6),
      const Color(0xFF84CC16).withValues(alpha: .65),
      const Color(0xFF22C55E).withValues(alpha: .8),
    ];
    return levels.map((color) {
      return Container(
        width: 14,
        height: 14,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }).toList();
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({required this.report});

  final HealthDayReport report;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${DateFormat.MMMd().format(report.date)}: Skor ${report.score}',
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _colorFor(report.score),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${report.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              title: Text(
                DateFormat.yMMMd('id').format(report.date),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DetailRow('🌙 Tidur', '${report.sleep}/25'),
                  _DetailRow('⚡ Quest', '${report.quest}/25'),
                  _DetailRow('😊 Mood', '${report.mood}/25'),
                  _DetailRow('🏃 Aktivitas', '${report.activity}/25'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Tutup',
                      style: TextStyle(color: AppColors.green600)),
                ),
              ],
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: _colorFor(report.score),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              DateFormat.d().format(report.date),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: report.score >= 60
                    ? Colors.white.withValues(alpha: .9)
                    : Colors.white.withValues(alpha: .75),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

Color _colorFor(int score) {
  if (score < 35) return AppColors.danger.withValues(alpha: .55);
  if (score < 50) return const Color(0xFFF97316).withValues(alpha: .6);
  if (score < 65) return AppColors.amber300.withValues(alpha: .65);
  if (score < 80) return const Color(0xFF84CC16).withValues(alpha: .7);
  return const Color(0xFF22C55E).withValues(alpha: .85);
}
