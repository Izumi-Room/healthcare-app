import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../models/reflection_entry.dart';

class ReflectionJournal extends StatelessWidget {
  const ReflectionJournal({super.key, required this.entries});

  final List<ReflectionEntry> entries;

  // Mood mappings
  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Luar Biasa': return '😁';
      case 'Senang': return '😊';
      case 'Damai': return '😌';
      case 'Biasa': return '😐';
      case 'Sedih': return '😔';
      case 'Lelah': return '😫';
      default: return '📝';
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Luar Biasa': return const Color(0xFF4CAF50);
      case 'Senang': return const Color(0xFF66BB6A);
      case 'Damai': return const Color(0xFF42A5F5);
      case 'Biasa': return const Color(0xFFFFCA28);
      case 'Sedih': return const Color(0xFF7E57C2);
      case 'Lelah': return const Color(0xFFEF5350);
      default: return AppColors.textSecondary;
    }
  }

  // Highlight mappings
  String _getHighlightEmoji(String label) {
    switch (label) {
      case 'Pencapaian': return '🌟';
      case 'Keluarga': return '❤️';
      case 'Teman': return '👥';
      case 'Belajar': return '📚';
      case 'Kerja': return '💼';
      case 'Hiburan': return '🎮';
      case 'Istirahat': return '🌙';
      default: return '📍';
    }
  }

  Color _getHighlightColor(String label) {
    switch (label) {
      case 'Pencapaian': return const Color(0xFFFFB300);
      case 'Keluarga': return const Color(0xFFE91E63);
      case 'Teman': return const Color(0xFF42A5F5);
      case 'Belajar': return const Color(0xFF7E57C2);
      case 'Kerja': return const Color(0xFF26A69A);
      case 'Hiburan': return const Color(0xFFFF7043);
      case 'Istirahat': return const Color(0xFF5C6BC0);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.green50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_stories_outlined,
                  color: AppColors.green600,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum Ada Jurnal Refleksi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tuliskan refleksi harianmu untuk melacak kesehatan emosi, momen istimewa, dan rasa syukur.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Grid layout for tablets, single list for phones
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 600 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: columns == 1 ? 1.05 : 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final entry = entries[index];
            if (!entry.isFullReflection) {
              return _buildLegacyCard(context, entry);
            }
            return _buildFullReflectionCard(context, entry);
          },
        );
      },
    );
  }

  // Render method for new immersive reflections
  Widget _buildFullReflectionCard(BuildContext context, ReflectionEntry entry) {
    final moodColor = _getMoodColor(entry.mood);
    final moodEmoji = _getMoodEmoji(entry.mood);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Mood, Date, and Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: moodColor.withValues(alpha: 0.08),
            child: Row(
              children: [
                Text(
                  moodEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.mood,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: moodColor,
                        ),
                      ),
                      Text(
                        DateFormat.yMMMd().format(entry.timestamp),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_rounded, size: 12, color: AppColors.green600),
                      const SizedBox(width: 4),
                      Text(
                        'Skor ${entry.scoreAtEntry}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.green600,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(),
                children: [
                  // Emotions chips
                  if (entry.emotions.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: entry.emotions.map((emo) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Text(
                            emo,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Highlights
                  if (entry.highlight.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          _getHighlightEmoji(entry.highlight),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Highlight: ',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        Text(
                          entry.highlight,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getHighlightColor(entry.highlight),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Question & Answer
                  if (entry.question.isNotEmpty && entry.answer.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.question,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.answer,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Gratitudes
                  if (entry.gratitudes.isNotEmpty) ...[
                    Text(
                      'Rasa Syukur:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    ...entry.gratitudes.map((gratitude) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                gratitude,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 13,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],

                  // Tomorrow Intention
                  if (entry.tomorrowIntention.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.outlined_flag_rounded,
                          size: 16,
                          color: AppColors.pink400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Fokus Besok: ',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        Expanded(
                          child: Text(
                            entry.tomorrowIntention,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.pink400,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Backward compatible render method for old question+answer reflections
  Widget _buildLegacyCard(BuildContext context, ReflectionEntry entry) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMd().format(entry.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Skor ${entry.scoreAtEntry}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entry.question,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Text(
                  entry.answer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
