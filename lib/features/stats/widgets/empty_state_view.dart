import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key, this.onExploreDataTap});

  final VoidCallback? onExploreDataTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mascot / illustration
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.border.withValues(alpha: .5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/mascot/think.png', // The thoughtful leaf mascot
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Mulai Perjalanan Anda',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Catat aktivitas kesehatan harian Anda untuk melihat visualisasi dan pertumbuhan statistik kebun VitaTree Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go('/quests'),
              icon: const Icon(Icons.task_alt, size: 18),
              label: const Text('Selesaikan Quest Hari Ini', style: TextStyle(fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green600,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/sleep'),
                  icon: const Icon(Icons.bedtime, size: 16),
                  label: const Text('Catat Tidur'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: const Color(0xFF8B5CF6),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // simulate logging water
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('💧 Berhasil mencatat 250ml Air!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.water_drop, size: 16),
                  label: const Text('Minum Air'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: AppColors.cyan700,
                  ),
                ),
              ),
            ],
          ),
          if (onExploreDataTap != null) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: onExploreDataTap,
              child: const Text(
                'Lihat Contoh Data Demo 📊',
                style: TextStyle(
                  color: AppColors.green600,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
