import 'package:flutter/material.dart';

class FlowQuestionStep extends StatefulWidget {
  const FlowQuestionStep({
    super.key,
    required this.question,
    required this.controller,
  });

  final String question;
  final TextEditingController controller;

  @override
  State<FlowQuestionStep> createState() => _FlowQuestionStepState();
}

class _FlowQuestionStepState extends State<FlowQuestionStep> {
  static const _maxChars = 500;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final charCount = widget.controller.text.length;
    final progress = (charCount / _maxChars).clamp(0.0, 1.0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Refleksi Hari Ini',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF3E5F5).withValues(alpha: .6),
                  const Color(0xFFE8EAF6).withValues(alpha: .6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF9C27B0).withValues(alpha: .15),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                const Text('✨', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 12),
                Text(
                  widget.question,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        fontSize: 17,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Text field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: charCount > 0
                    ? const Color(0xFF4CAF50).withValues(alpha: .4)
                    : Colors.grey[300]!,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              maxLines: 6,
              maxLength: _maxChars,
              decoration: InputDecoration(
                hintText: 'Tulis jawabanmu di sini...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
                counterText: '',
              ),
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Progress indicator
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    color: progress > 0.8
                        ? const Color(0xFFF44336)
                        : const Color(0xFF4CAF50),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$charCount / $_maxChars',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
