import 'package:flutter/material.dart';

class FlowSummaryStep extends StatelessWidget {
  const FlowSummaryStep({
    super.key,
    required this.mood,
    required this.emotions,
    required this.highlight,
    required this.gratitudes,
    required this.intention,
    required this.summary,
  });

  final String mood;
  final List<String> emotions;
  final String highlight;
  final List<String> gratitudes;
  final String intention;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Ringkasan Refleksimu',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 24),
            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE8F5E9).withValues(alpha: .8),
                    const Color(0xFFF1F8E9).withValues(alpha: .6),
                    const Color(0xFFFFF8E1).withValues(alpha: .5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: .2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: .08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI-style summary text
                  const Text('📝', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 12),
                  Text(
                    summary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Detail chips
            _DetailRow(
              icon: '😊',
              label: 'Mood',
              value: mood,
            ),
            const SizedBox(height: 10),
            if (emotions.isNotEmpty)
              _DetailRow(
                icon: '💭',
                label: 'Emosi',
                value: emotions.join(', '),
              ),
            if (emotions.isNotEmpty) const SizedBox(height: 10),
            if (highlight.isNotEmpty)
              _DetailRow(
                icon: '⭐',
                label: 'Highlight',
                value: highlight,
              ),
            if (highlight.isNotEmpty) const SizedBox(height: 10),
            if (gratitudes.where((g) => g.isNotEmpty).isNotEmpty) ...[
              _DetailRow(
                icon: '🙏',
                label: 'Syukur',
                value: gratitudes.where((g) => g.isNotEmpty).join(', '),
              ),
              const SizedBox(height: 10),
            ],
            if (intention.isNotEmpty)
              _DetailRow(
                icon: '🎯',
                label: 'Niat Besok',
                value: intention,
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
