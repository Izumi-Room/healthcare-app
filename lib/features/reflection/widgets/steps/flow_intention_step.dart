import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlowIntentionStep extends StatefulWidget {
  const FlowIntentionStep({
    super.key,
    required this.onSelected,
    this.selected,
  });

  final ValueChanged<String> onSelected;
  final String? selected;

  @override
  State<FlowIntentionStep> createState() => _FlowIntentionStepState();
}

class _FlowIntentionStepState extends State<FlowIntentionStep> {
  static const _intentions = [
    _Intention('🌙', 'Tidur Lebih Baik', Color(0xFF5C6BC0)),
    _Intention('🏃', 'Olahraga', Color(0xFF4CAF50)),
    _Intention('📖', 'Belajar', Color(0xFF7E57C2)),
    _Intention('💼', 'Kerja Produktif', Color(0xFF26A69A)),
    _Intention('📚', 'Membaca', Color(0xFFFF7043)),
    _Intention('🧘', 'Meditasi', Color(0xFF42A5F5)),
    _Intention('💧', 'Minum Air', Color(0xFF29B6F6)),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Niat untuk Besok',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Apa satu hal yang ingin kamu fokuskan?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _intentions.map((intention) {
                final isSelected = widget.selected == intention.label;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onSelected(intention.label);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? intention.color.withValues(alpha: .1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? intention.color
                            : Colors.grey[300]!,
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: intention.color.withValues(alpha: .2),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            intention.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          intention.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? intention.color
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _Intention {
  const _Intention(this.emoji, this.label, this.color);
  final String emoji;
  final String label;
  final Color color;
}
