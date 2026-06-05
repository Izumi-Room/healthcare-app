import 'package:flutter/material.dart';

class SleepInputSheet extends StatefulWidget {
  const SleepInputSheet({super.key, required this.onSave});

  final Future<void> Function(TimeOfDay sleep, TimeOfDay wake) onSave;

  @override
  State<SleepInputSheet> createState() => _SleepInputSheetState();
}

class _SleepInputSheetState extends State<SleepInputSheet> {
  TimeOfDay _sleep = const TimeOfDay(hour: 22, minute: 00);
  TimeOfDay _wake = const TimeOfDay(hour: 6, minute: 00);
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Dark slate navy
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Log Sleep Record',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Icon(Icons.bedtime_outlined, color: Color(0xFFC084FC), size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your garden growing by logging your rest.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 28),

          // Bedtime Picker Input
          _TimeSelectRow(
            label: 'Mulai tidur (Bedtime)',
            value: _sleep,
            emoji: '🛌',
            accentColor: const Color(0xFF8B5CF6),
            onTap: () => _pickTime(true),
          ),
          const SizedBox(height: 14),

          // Wake Up Picker Input
          _TimeSelectRow(
            label: 'Bangun (Wake Up)',
            value: _wake,
            emoji: '⏰',
            accentColor: const Color(0xFFFEF08A),
            onTap: () => _pickTime(false),
          ),
          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: _saving
                  ? null
                  : () async {
                      setState(() => _saving = true);
                      await widget.onSave(_sleep, _wake);
                      if (context.mounted) Navigator.of(context).pop();
                    },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline, size: 20),
              label: Text(
                _saving ? 'Saving...' : 'Confirm Sleep Record',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(bool pickSleep) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: pickSleep ? _sleep : _wake,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8B5CF6),
              onPrimary: Colors.white,
              surface: Color(0xFF0F172A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (pickSleep) {
        _sleep = picked;
      } else {
        _wake = picked;
      }
    });
  }
}

class _TimeSelectRow extends StatelessWidget {
  const _TimeSelectRow({
    required this.label,
    required this.value,
    required this.emoji,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final TimeOfDay value;
  final String emoji;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.format(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
