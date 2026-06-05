import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../shared/widgets/mascot_helper.dart';
import 'providers/reflection_trigger_provider.dart';
import 'widgets/reflection_flow_screen.dart';
import 'widgets/reflection_journal.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  @override
  Widget build(BuildContext context) {
    final shouldTrigger = ref.watch(reflectionTriggerProvider);
    final promptHandled = ref.watch(reflectionPromptHandledProvider);
    final entries = ref.watch(reflectionProvider);
    final streak = ref.watch(reflectionStreakProvider);

    if (shouldTrigger && !promptHandled) {
      ref.read(reflectionPromptHandledProvider.notifier).state = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ReflectionFlowScreen(),
            ),
          );
        }
      });
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        // Title & Description Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jurnal Refleksi',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            const MascotBubble(
              message: 'Catat perjalanan mental dan emosionalmu untuk membangun kesadaran diri yang lebih baik. Aku siap menemanimu!',
              mood: MascotMood.wink,
              bubbleColor: Color(0xFFF1F5F9),
              textColor: Colors.black87,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Gamified Streak Card & CTA Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFEAF3DE), // Light green tint
                Color(0xFFD3E7BD), // Medium green tint
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFC0DD97).withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B6D11).withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B6D11).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFEF9F27), // Amber streak color
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          streak > 0 ? '$streak Hari Beruntun!' : 'Mulai Kebiasaan Baru',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        Text(
                          streak > 0
                              ? 'Hebat! Kamu rajin merawat pikiranmu.'
                              : 'Refleksikan harimu hari ini untuk memulai streak-mu!',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Inside Container CTA button to start flow
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ReflectionFlowScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.spa_rounded, size: 20),
                  label: const Text(
                    'Mulai Refleksi Terpandu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    shadowColor: AppColors.green600.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // History Label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Jurnal',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (entries.isNotEmpty)
              Text(
                '${entries.length} Catatan',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Journal List View
        ReflectionJournal(entries: entries),
      ],
    );
  }
}
