import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme.dart';
import '../providers/reflection_trigger_provider.dart';
import 'steps/flow_welcome_step.dart';
import 'steps/flow_mood_step.dart';
import 'steps/flow_emotion_step.dart';
import 'steps/flow_question_step.dart';
import 'steps/flow_highlight_step.dart';
import 'steps/flow_gratitude_step.dart';
import 'steps/flow_intention_step.dart';
import 'steps/flow_summary_step.dart';
import 'steps/flow_completion_step.dart';

class ReflectionFlowScreen extends ConsumerStatefulWidget {
  const ReflectionFlowScreen({super.key});

  @override
  ConsumerState<ReflectionFlowScreen> createState() =>
      _ReflectionFlowScreenState();
}

class _ReflectionFlowScreenState extends ConsumerState<ReflectionFlowScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const _totalSteps = 9;

  // Flow state
  String _mood = '';
  List<String> _emotions = [];
  String _question = '';
  final _answerController = TextEditingController();
  String _highlight = '';
  final _gratitudeControllers = List.generate(3, (_) => TextEditingController());
  String _intention = '';
  bool _saved = false;
  bool _loadingDraft = true;

  @override
  void initState() {
    super.initState();
    _answerController.addListener(_onAnswerChanged);
    _loadDraft();
  }

  @override
  void dispose() {
    _answerController.removeListener(_onAnswerChanged);
    _pageController.dispose();
    _answerController.dispose();
    for (final c in _gratitudeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onAnswerChanged() {
    // Rebuild parent on text changes so next button updates correctly
    if (_currentStep == 3) {
      setState(() {});
    }
  }

  Future<void> _loadDraft() async {
    try {
      final box = await Hive.openBox('reflection_draft');
      
      // 1. Check if we already completed a reflection today
      final entries = ref.read(reflectionProvider);
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEntryIndex = entries.indexWhere((e) {
        final entryDay = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
        return entryDay == todayStart;
      });

      if (todayEntryIndex != -1) {
        final todayEntry = entries[todayEntryIndex];
        setState(() {
          _mood = todayEntry.mood;
          _emotions = List<String>.from(todayEntry.emotions);
          _question = todayEntry.question;
          _answerController.text = todayEntry.answer;
          _highlight = todayEntry.highlight;
          for (var i = 0; i < 3; i++) {
            if (i < todayEntry.gratitudes.length) {
              _gratitudeControllers[i].text = todayEntry.gratitudes[i];
            } else {
              _gratitudeControllers[i].text = '';
            }
          }
          _intention = todayEntry.tomorrowIntention;
          _currentStep = 0;
          _loadingDraft = false;
        });
      } else {
        // 2. Load draft if no entry completed today
        setState(() {
          _mood = box.get('mood', defaultValue: '') as String;
          _emotions = (box.get('emotions') as List?)?.cast<String>() ?? const [];
          _question = box.get('question', defaultValue: '') as String;
          if (_question.isEmpty) {
            final random = Random();
            _question = reflectionQuestions[random.nextInt(reflectionQuestions.length)];
          }
          _answerController.text = box.get('answer', defaultValue: '') as String;
          _highlight = box.get('highlight', defaultValue: '') as String;
          
          final grats = box.get('gratitudes') as List?;
          if (grats != null) {
            for (var i = 0; i < 3; i++) {
              if (i < grats.length) {
                _gratitudeControllers[i].text = grats[i] as String;
              }
            }
          }
          _intention = box.get('intention', defaultValue: '') as String;
          _currentStep = box.get('currentStep', defaultValue: 0) as int;
          _loadingDraft = false;
        });

        if (_currentStep > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(_currentStep);
            }
          });
        }
      }
    } catch (_) {
      // Fallback in case of Hive errors
      setState(() {
        final random = Random();
        _question = reflectionQuestions[random.nextInt(reflectionQuestions.length)];
        _loadingDraft = false;
      });
    }
  }

  Future<void> _saveDraft() async {
    try {
      final box = await Hive.openBox('reflection_draft');
      await box.put('mood', _mood);
      await box.put('emotions', _emotions);
      await box.put('question', _question);
      await box.put('answer', _answerController.text);
      await box.put('highlight', _highlight);
      await box.put('gratitudes', _gratitudeControllers.map((c) => c.text).toList());
      await box.put('intention', _intention);
      await box.put('currentStep', _currentStep);
    } catch (_) {
      // Silently ignore draft saving failures
    }
  }

  Future<void> _clearDraft() async {
    try {
      final box = await Hive.openBox('reflection_draft');
      await box.clear();
    } catch (_) {}
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
    _saveDraft();
  }

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      if (_currentStep == 6) {
        // Generate summary before transitioning to summary step
        _goToStep(_currentStep + 1);
      } else if (_currentStep == 7 && !_saved) {
        // Save reflection when moving from summary to completion step
        _saveReflection();
        _goToStep(_currentStep + 1);
      } else {
        _goToStep(_currentStep + 1);
      }
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  String _generateSummary() {
    final moodText = _mood.isNotEmpty ? _mood.toLowerCase() : 'biasa';
    final emotionText =
        _emotions.isNotEmpty ? _emotions.join(' dan ').toLowerCase() : '';
    final highlightText = _highlight.isNotEmpty ? _highlight.toLowerCase() : '';

    final buffer = StringBuffer();
    buffer.write('Hari ini kamu merasa $moodText');
    if (emotionText.isNotEmpty) {
      buffer.write(', dengan perasaan $emotionText');
    }
    buffer.write('. ');
    if (highlightText.isNotEmpty) {
      buffer.write(
          'Momen terbaik harimu berhubungan dengan $highlightText. ');
    }
    final filledGratitudes =
        _gratitudeControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty);
    if (filledGratitudes.isNotEmpty) {
      buffer.write(
          'Kamu bersyukur untuk ${filledGratitudes.length} hal istimewa. ');
    }
    if (_intention.isNotEmpty) {
      buffer.write('Besok, kamu ingin fokus pada ${_intention.toLowerCase()}. ');
    }
    buffer.write('Tetap semangat! 🌟');
    return buffer.toString();
  }

  Future<void> _saveReflection() async {
    if (_saved) return;
    _saved = true;
    final gratitudes = _gratitudeControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
        
    await ref.read(reflectionProvider.notifier).addFullReflection(
          mood: _mood,
          emotions: _emotions,
          question: _question,
          answer: _answerController.text.trim(),
          highlight: _highlight,
          gratitudes: gratitudes,
          tomorrowIntention: _intention,
          summary: _generateSummary(),
        );

    await _clearDraft();
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return true; // Welcome
      case 1:
        return _mood.isNotEmpty; // Mood
      case 2:
        return _emotions.isNotEmpty; // Emotions
      case 3:
        return _answerController.text.trim().isNotEmpty; // Reflection answer (validated text input)
      case 4:
        return _highlight.isNotEmpty; // Highlight
      case 5:
        return true; // Gratitude (optional)
      case 6:
        return true; // Intention (optional)
      case 7:
        return true; // Summary
      case 8:
        return true; // Completion
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingDraft) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4CAF50),
          ),
        ),
      );
    }

    const progressSteps = _totalSteps - 2;
    final progressValue =
        _currentStep <= 0 ? 0.0 : ((_currentStep - 1) / (progressSteps - 1)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentStep > 0 && _currentStep < _totalSteps - 1
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _back,
              ),
              title: Text(
                '$_currentStep dari $progressSteps',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              centerTitle: true,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            if (_currentStep > 0 && _currentStep < _totalSteps - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progressValue),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.grey[200],
                        color: const Color(0xFF4CAF50),
                        minHeight: 6,
                      );
                    },
                  ),
                ),
              ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Step 0: Welcome
                  FlowWelcomeStep(onNext: _next),
                  // Step 1: Mood
                  FlowMoodStep(
                    selected: _mood.isNotEmpty ? _mood : null,
                    onSelected: (mood) {
                      setState(() => _mood = mood);
                      _saveDraft();
                    },
                  ),
                  // Step 2: Emotions
                  FlowEmotionStep(
                    selected: _emotions,
                    onChanged: (emotions) {
                      setState(() => _emotions = emotions);
                      _saveDraft();
                    },
                  ),
                  // Step 3: Question
                  FlowQuestionStep(
                    question: _question,
                    controller: _answerController,
                  ),
                  // Step 4: Highlight
                  FlowHighlightStep(
                    selected: _highlight.isNotEmpty ? _highlight : null,
                    onSelected: (h) {
                      setState(() => _highlight = h);
                      _saveDraft();
                    },
                  ),
                  // Step 5: Gratitude
                  FlowGratitudeStep(controllers: _gratitudeControllers),
                  // Step 6: Intention
                  FlowIntentionStep(
                    selected: _intention.isNotEmpty ? _intention : null,
                    onSelected: (i) {
                      setState(() => _intention = i);
                      _saveDraft();
                    },
                  ),
                  // Step 7: Summary
                  FlowSummaryStep(
                    mood: _mood,
                    emotions: _emotions,
                    highlight: _highlight,
                    gratitudes: _gratitudeControllers
                        .map((c) => c.text.trim())
                        .toList(),
                    intention: _intention,
                    summary: _generateSummary(),
                  ),
                  // Step 8: Completion
                  FlowCompletionStep(
                    onFinish: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Bottom navigation
            if (_currentStep > 0 && _currentStep < _totalSteps - 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _canProceed ? _next : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Text(
                      _currentStep == 7 ? 'Simpan & Selesai' : 'Lanjut',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
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
