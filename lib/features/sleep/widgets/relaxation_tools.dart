import 'dart:math' as math;
import 'package:flutter/material.dart';

class RelaxationTools extends StatefulWidget {
  const RelaxationTools({super.key});

  @override
  State<RelaxationTools> createState() => _RelaxationToolsState();
}

class _RelaxationToolsState extends State<RelaxationTools>
    with SingleTickerProviderStateMixin {
  String? _activeSound;
  bool _isPlaying = false;
  late final AnimationController _waveController;
  double _playbackProgress = 0.35;

  final List<_SoundItem> _sounds = [
    const _SoundItem('Sleep Sounds', '🎵', 'Ambient melodies for deep rest', Color(0xFF8B5CF6)),
    const _SoundItem('Meditation', '🧘', 'Guided breathing & mindfulness', Color(0xFFEC4899)),
    const _SoundItem('Rain Sounds', '🌧', 'Cosy rain on a window pane', Color(0xFF3B82F6)),
    const _SoundItem('Bedtime Stories', '📖', 'Calming tales to drift away', Color(0xFFFBBF24)),
    const _SoundItem('White Noise', '🎼', 'Steady static for distraction-free sleep', Color(0xFF10B981)),
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addListener(() {
        if (_isPlaying) {
          setState(() {
            _playbackProgress = (_playbackProgress + 0.001) % 1.0;
          });
        }
      });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _togglePlay(String soundName) {
    setState(() {
      if (_activeSound == soundName) {
        _isPlaying = !_isPlaying;
      } else {
        _activeSound = soundName;
        _isPlaying = true;
        _playbackProgress = 0.0;
      }

      if (_isPlaying) {
        _waveController.repeat();
      } else {
        _waveController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relaxation Tools',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Drift off peacefully with audio helpers.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
              ),
        ),
        const SizedBox(height: 16),

        // Grid of Sound Cards
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemCount: _sounds.length,
          itemBuilder: (context, index) {
            final sound = _sounds[index];
            final isActive = _activeSound == sound.name;
            final isPlayingThis = isActive && _isPlaying;

            return InkWell(
              onTap: () => _togglePlay(sound.name),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: isActive
                        ? [sound.themeColor.withValues(alpha: 0.8), sound.themeColor.withValues(alpha: 0.3)]
                        : [const Color(0xFF0F172A), const Color(0xFF1E293B).withValues(alpha: 0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: isActive ? sound.themeColor.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.08),
                    width: isActive ? 2 : 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: sound.themeColor.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Text(sound.emoji, style: const TextStyle(fontSize: 18)),
                        ),
                        if (isPlayingThis)
                          AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: _EqualizerPainter(
                                  progress: _waveController.value,
                                  color: Colors.white,
                                ),
                                size: const Size(20, 16),
                              );
                            },
                          )
                        else if (isActive)
                          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sound.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sound.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),

        // Now Playing Player Panel
        if (_activeSound != null) ...[
          const SizedBox(height: 16),
          _buildPlayerPanel(),
        ],
      ],
    );
  }

  Widget _buildPlayerPanel() {
    final activeItem = _sounds.firstWhere((s) => s.name == _activeSound);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: activeItem.themeColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: activeItem.themeColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(activeItem.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeItem.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Pseudo progress slider
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _playbackProgress,
                    minHeight: 3,
                    color: activeItem.themeColor,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Player Controls
          IconButton(
            onPressed: () {
              setState(() {
                _isPlaying = !_isPlaying;
                if (_isPlaying) {
                  _waveController.repeat();
                } else {
                  _waveController.stop();
                }
              });
            },
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.white,
              size: 32,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              setState(() {
                _activeSound = null;
                _isPlaying = false;
                _waveController.stop();
              });
            },
            icon: const Icon(Icons.close, color: Colors.white38, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _SoundItem {
  const _SoundItem(this.name, this.emoji, this.description, this.themeColor);

  final String name;
  final String emoji;
  final String description;
  final Color themeColor;
}

class _EqualizerPainter extends CustomPainter {
  _EqualizerPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final widthStep = size.width / 3;

    for (var i = 0; i < 3; i++) {
      // Calculate bouncing heights based on phase shift
      final x = i * widthStep + widthStep / 2;
      final speedFactor = 1.0 + (i * 0.3);
      final phaseShift = i * math.pi / 4;
      final heightFactor = 0.2 + 0.8 * (0.5 + 0.5 * math.sin(progress * 2 * math.pi * speedFactor + phaseShift));

      final barHeight = size.height * heightFactor;
      final yStart = size.height - barHeight;

      canvas.drawLine(Offset(x, yStart), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EqualizerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
