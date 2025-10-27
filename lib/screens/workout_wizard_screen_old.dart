import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/theme/app_colors.dart';

// This file is part of the Veda AI app - integrated Workout Wizard

// ============================================================================
// DATA MODELS
// ============================================================================

class WorkoutProgram {
  final String programId;
  final String programTitle;
  final String programGoal;
  final String programNotes;
  final int programDurationWeeks;
  final List<DaySchedule> weeklySchedule;
  final Map<String, WorkoutBlock> workoutLibrary;

  WorkoutProgram({
    required this.programId,
    required this.programTitle,
    required this.programGoal,
    required this.programNotes,
    required this.programDurationWeeks,
    required this.weeklySchedule,
    required this.workoutLibrary,
  });

  factory WorkoutProgram.fromJson(Map<String, dynamic> json) {
    return WorkoutProgram(
      programId: json['programId'] ?? '',
      programTitle: json['programTitle'] ?? '',
      programGoal: json['programGoal'] ?? '',
      programNotes: json['programNotes'] ?? '',
      programDurationWeeks: json['programDurationWeeks'] ?? 0,
      weeklySchedule: (json['weeklySchedule'] as List? ?? [])
          .map((e) => DaySchedule.fromJson(e))
          .toList(),
      workoutLibrary: (json['workoutLibrary'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, WorkoutBlock.fromJson(value))),
    );
  }
}

class DaySchedule {
  final String dayOfWeek;
  final List<Session> sessions;

  DaySchedule({required this.dayOfWeek, required this.sessions});

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      dayOfWeek: json['dayOfWeek'] ?? '',
      sessions: (json['sessions'] as List? ?? [])
          .map((e) => Session.fromJson(e))
          .toList(),
    );
  }
}

class Session {
  final String sessionId;
  final String title;
  final int durationMinutes;
  final String timeOfDay;
  final String? notes;
  final List<Component> components;

  Session({
    required this.sessionId,
    required this.title,
    required this.durationMinutes,
    required this.timeOfDay,
    this.notes,
    required this.components,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['sessionId'] ?? '',
      title: json['title'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      timeOfDay: json['timeOfDay'] ?? '',
      notes: json['notes'],
      components: (json['components'] as List? ?? [])
          .map((e) => Component.fromJson(e))
          .toList(),
    );
  }
}

class Component {
  final String componentType;
  final String blockId;
  final int rounds;
  final String? notes;

  Component({
    required this.componentType,
    required this.blockId,
    required this.rounds,
    this.notes,
  });

  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      componentType: json['componentType'] ?? '',
      blockId: json['blockId'] ?? '',
      rounds: json['rounds'] ?? 1,
      notes: json['notes'],
    );
  }
}

class WorkoutBlock {
  final String blockId;
  final String title;
  final String blockType;
  final int? estimatedDurationMinutes;
  final List<Exercise> exercises;

  WorkoutBlock({
    required this.blockId,
    required this.title,
    required this.blockType,
    this.estimatedDurationMinutes,
    required this.exercises,
  });

  factory WorkoutBlock.fromJson(Map<String, dynamic> json) {
    return WorkoutBlock(
      blockId: json['blockId'] ?? '',
      title: json['title'] ?? '',
      blockType: json['blockType'] ?? '',
      estimatedDurationMinutes: json['estimatedDurationMinutes'],
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => Exercise.fromJson(e))
          .toList(),
    );
  }
}

class Exercise {
  final String exerciseId;
  final String name;
  final Execution? execution;
  final List<Progression>? progression;

  Exercise({
    required this.exerciseId,
    required this.name,
    this.execution,
    this.progression,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exerciseId'] ?? '',
      name: json['name'] ?? '',
      execution: json['execution'] != null
          ? Execution.fromJson(json['execution'])
          : null,
      progression: json['progression'] != null
          ? (json['progression'] as List)
              .map((e) => Progression.fromJson(e))
              .toList()
          : null,
    );
  }
}

class Execution {
  final String type;
  final int? durationSeconds;
  final int? reps;
  final int? minReps;
  final int? maxReps;
  final int? minSeconds;
  final int? maxSeconds;
  final String? description;

  Execution({
    required this.type,
    this.durationSeconds,
    this.reps,
    this.minReps,
    this.maxReps,
    this.minSeconds,
    this.maxSeconds,
    this.description,
  });

  factory Execution.fromJson(Map<String, dynamic> json) {
    return Execution(
      type: json['type'] ?? '',
      durationSeconds: json['durationSeconds'],
      reps: json['reps'],
      minReps: json['minReps'],
      maxReps: json['maxReps'],
      minSeconds: json['minSeconds'],
      maxSeconds: json['maxSeconds'],
      description: json['description'],
    );
  }

  String toDisplayString() {
    switch (type) {
      case 'DURATION':
        return '${durationSeconds}s${description != null ? ' ($description)' : ''}';
      case 'REPS':
        return '$reps Reps';
      case 'REP_RANGE':
        return '$minReps-$maxReps Reps';
      case 'DURATION_RANGE':
        return '${minSeconds}-${maxSeconds}s';
      case 'AMRAP':
        return 'As Many Reps As Possible';
      default:
        return 'Complete Exercise';
    }
  }
}

class Progression {
  final WeekRange weekRange;
  final int sets;
  final Execution execution;
  final Load? load;
  final Rest? rest;

  Progression({
    required this.weekRange,
    required this.sets,
    required this.execution,
    this.load,
    this.rest,
  });

  factory Progression.fromJson(Map<String, dynamic> json) {
    return Progression(
      weekRange: WeekRange.fromJson(json['weekRange'] ?? {}),
      sets: json['sets'] ?? 1,
      execution: Execution.fromJson(json['execution'] ?? {}),
      load: json['load'] != null ? Load.fromJson(json['load']) : null,
      rest: json['rest'] != null ? Rest.fromJson(json['rest']) : null,
    );
  }
}

class WeekRange {
  final int start;
  final int end;

  WeekRange({required this.start, required this.end});

  factory WeekRange.fromJson(Map<String, dynamic> json) {
    return WeekRange(
      start: json['start'] ?? 1,
      end: json['end'] ?? 1,
    );
  }

  bool contains(int week) => week >= start && week <= end;
}

class Load {
  final String description;

  Load({required this.description});

  factory Load.fromJson(Map<String, dynamic> json) {
    return Load(description: json['description'] ?? '');
  }
}

class Rest {
  final String type;
  final int? durationSeconds;

  Rest({required this.type, this.durationSeconds});

  factory Rest.fromJson(Map<String, dynamic> json) {
    return Rest(
      type: json['type'] ?? '',
      durationSeconds: json['durationSeconds'],
    );
  }
}

// ============================================================================
// WORKOUT STEP MODELS
// ============================================================================

enum WorkoutStepType {
  summary,
  exercise,
  rest,
  finished,
}

class WorkoutStep {
  final WorkoutStepType type;
  final String? title;
  final String? subtitle;
  final String? exerciseName;
  final String? executionDetails;
  final String? lottieAsset;
  final int? restDurationSeconds;
  final int? setNumber;
  final int? totalSets;
  final String? loadDescription;
  final String? phaseName;
  final int? exerciseNumber;
  final int? totalExercises;
  final int? exerciseDurationSeconds; // For duration-based exercises
  final bool isDurationBased; // Flag to indicate if exercise needs countdown timer
  final int? phaseNumber; // Which phase we're in (1, 2, 3, etc.)
  final int? totalPhases; // Total number of phases

  WorkoutStep({
    required this.type,
    this.title,
    this.subtitle,
    this.exerciseName,
    this.executionDetails,
    this.lottieAsset,
    this.restDurationSeconds,
    this.setNumber,
    this.totalSets,
    this.loadDescription,
    this.phaseName,
    this.exerciseNumber,
    this.totalExercises,
    this.exerciseDurationSeconds,
    this.isDurationBased = false,
    this.phaseNumber,
    this.totalPhases,
  });
}

// ============================================================================
// WORKOUT FLATTENER LOGIC
// ============================================================================

List<WorkoutStep> flattenWorkout(
  WorkoutProgram program,
  String dayOfWeek,
  int currentWeek,
) {
  final steps = <WorkoutStep>[];

  final daySchedule = program.weeklySchedule.firstWhere(
    (d) => d.dayOfWeek == dayOfWeek,
    orElse: () => DaySchedule(dayOfWeek: dayOfWeek, sessions: []),
  );

  if (daySchedule.sessions.isEmpty) {
    steps.add(WorkoutStep(
      type: WorkoutStepType.summary,
      title: 'No Workout',
      subtitle: 'No session scheduled for $dayOfWeek',
    ));
    steps.add(WorkoutStep(type: WorkoutStepType.finished));
    return steps;
  }

  final session = daySchedule.sessions.first;

  steps.add(WorkoutStep(
    type: WorkoutStepType.summary,
    title: session.title,
    subtitle:
        '${session.durationMinutes} min • ${session.timeOfDay}\n${session.notes ?? ''}',
  ));

  int totalExerciseSteps = 0;
  final totalPhases = session.components.length;
  
  // First pass: count total exercise steps
  for (final component in session.components) {
    final block = program.workoutLibrary[component.blockId];
    if (block == null) continue;

    for (final exercise in block.exercises) {
      if (exercise.execution != null) {
        // Simple execution exercises are NOT repeated by rounds
        totalExerciseSteps++;
      } else if (exercise.progression != null) {
        final progression = exercise.progression!.firstWhere(
          (p) => p.weekRange.contains(currentWeek),
          orElse: () => exercise.progression!.first,
        );
        // Progression exercises count all sets
        totalExerciseSteps += progression.sets;
      }
    }
  }

  int currentExerciseNumber = 0;
  int phaseNumber = 0;

  for (final component in session.components) {
    final block = program.workoutLibrary[component.blockId];
    if (block == null) continue;
    
    phaseNumber++;

    steps.add(WorkoutStep(
      type: WorkoutStepType.summary,
      title: block.title,
      subtitle: '${component.rounds} round${component.rounds > 1 ? 's' : ''}',
      phaseNumber: phaseNumber,
      totalPhases: totalPhases,
    ));

    // Process exercises based on their type
    for (final exercise in block.exercises) {
      if (exercise.execution != null) {
        // Simple execution exercises (warm-up, cool-down)
        // These are NOT repeated for each round - they're done once
        currentExerciseNumber++;
        
        // Check if this is a duration-based exercise
        final isDuration = exercise.execution!.type == 'DURATION' || 
                          exercise.execution!.type == 'DURATION_RANGE';
        final durationSecs = exercise.execution!.durationSeconds ?? 
                            exercise.execution!.maxSeconds;
        
        steps.add(WorkoutStep(
          type: WorkoutStepType.exercise,
          exerciseName: exercise.name,
          executionDetails: exercise.execution!.toDisplayString(),
          lottieAsset: _getLottieAsset(exercise.exerciseId),
          phaseName: block.title,
          exerciseNumber: currentExerciseNumber,
          totalExercises: totalExerciseSteps,
          isDurationBased: isDuration,
          exerciseDurationSeconds: durationSecs,
          phaseNumber: phaseNumber,
          totalPhases: totalPhases,
        ));

        if (block.blockType != 'COOL_DOWN') {
          steps.add(WorkoutStep(
            type: WorkoutStepType.rest,
            restDurationSeconds: 30,
          ));
        }
      } else if (exercise.progression != null) {
        // Progression exercises (strength training)
        // The rounds field is already built into the sets count
        final progression = exercise.progression!.firstWhere(
          (p) => p.weekRange.contains(currentWeek),
          orElse: () => exercise.progression!.first,
        );

        for (int set = 1; set <= progression.sets; set++) {
          currentExerciseNumber++;
          
          // Check if this is a duration-based progression
          final isDuration = progression.execution.type == 'DURATION' || 
                            progression.execution.type == 'DURATION_RANGE';
          final durationSecs = progression.execution.durationSeconds ?? 
                              progression.execution.maxSeconds;
          
          steps.add(WorkoutStep(
            type: WorkoutStepType.exercise,
            exerciseName: exercise.name,
            executionDetails: progression.execution.toDisplayString(),
            lottieAsset: _getLottieAsset(exercise.exerciseId),
            setNumber: set,
            totalSets: progression.sets,
            loadDescription: progression.load?.description,
            phaseName: block.title,
            exerciseNumber: currentExerciseNumber,
            totalExercises: totalExerciseSteps,
            isDurationBased: isDuration,
            exerciseDurationSeconds: durationSecs,
            phaseNumber: phaseNumber,
            totalPhases: totalPhases,
          ));

          // Add rest after each set except the last one
          if (set < progression.sets && progression.rest != null) {
            steps.add(WorkoutStep(
              type: WorkoutStepType.rest,
              restDurationSeconds: progression.rest!.durationSeconds ?? 60,
            ));
          }
        }
        
        // Add rest between different exercises
        if (progression.rest != null) {
          steps.add(WorkoutStep(
            type: WorkoutStepType.rest,
            restDurationSeconds: progression.rest!.durationSeconds ?? 60,
          ));
        }
      }
    }
  }

  steps.add(WorkoutStep(type: WorkoutStepType.finished));

  return steps;
}

String _getLottieAsset(String exerciseId) {
  final assetMap = {
    'ex_goblet_squat': 'assets/lottie/squat.json',
    'ex_pushups': 'assets/lottie/pushup.json',
    'ex_plank': 'assets/lottie/plank.json',
    'ex_leg_raises': 'assets/lottie/default.json',
    'ex_arm_circles': 'assets/lottie/default.json',
    'ex_torso_twists': 'assets/lottie/default.json',
    'ex_high_knees_warmup': 'assets/lottie/default.json',
    'ex_bw_squats_warmup': 'assets/lottie/squat.json',
    'ex_quad_stretch': 'assets/lottie/default.json',
    'ex_hamstring_stretch': 'assets/lottie/default.json',
  };

  return assetMap[exerciseId] ?? 'assets/lottie/default.json';
}

// ============================================================================
// WORKOUT WIZARD SCREEN
// ============================================================================

class WorkoutWizardScreen extends StatefulWidget {
  const WorkoutWizardScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutWizardScreen> createState() => _WorkoutWizardScreenState();
}

class _WorkoutWizardScreenState extends State<WorkoutWizardScreen> {
  late List<WorkoutStep> _steps;
  int _currentStepIndex = 0;
  bool _isLoading = true;
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Countdown and exercise timer state
  bool _isCountingDown = false;
  int _countdownSeconds = 3;
  bool _isExerciseTimerRunning = false;
  int _exerciseSecondsRemaining = 0;
  Timer? _exerciseTimer;
  
  // Track completed exercises
  Set<int> _completedExercises = {};

  @override
  void initState() {
    super.initState();
    _loadWorkout();
  }

  Future<void> _loadWorkout() async {
    try {
      // Load the workout JSON from assets
      final String jsonString = await rootBundle.loadString('bdata/DailyWorkout.json');
      final jsonData = json.decode(jsonString);
      final program = WorkoutProgram.fromJson(jsonData);
      final flattenedWorkout = flattenWorkout(program, 'Monday', 1);

      setState(() {
        _steps = flattenedWorkout;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading workout: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToNextStep({bool markComplete = true}) {
    _restTimer?.cancel();
    _exerciseTimer?.cancel();
    _audioPlayer.stop();
    
    // Mark current step as complete if it's an exercise
    if (markComplete && _currentStepIndex < _steps.length) {
      final currentStep = _steps[_currentStepIndex];
      if (currentStep.type == WorkoutStepType.exercise && currentStep.exerciseNumber != null) {
        _completedExercises.add(currentStep.exerciseNumber!);
      }
    }

    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _isCountingDown = false;
        _isExerciseTimerRunning = false;
      });

      final currentStep = _steps[_currentStepIndex];
      if (currentStep.type == WorkoutStepType.rest) {
        _startRestTimer(currentStep.restDurationSeconds ?? 60);
      }
    }
  }
  
  void _goToPreviousStep() {
    _restTimer?.cancel();
    _exerciseTimer?.cancel();
    _audioPlayer.stop();

    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _isCountingDown = false;
        _isExerciseTimerRunning = false;
      });

      final currentStep = _steps[_currentStepIndex];
      if (currentStep.type == WorkoutStepType.rest) {
        _startRestTimer(currentStep.restDurationSeconds ?? 60);
      }
    }
  }
  
  void _skipExercise() {
    // Skip without marking as complete
    _exerciseTimer?.cancel();
    _audioPlayer.stop();
    setState(() {
      _isCountingDown = false;
      _isExerciseTimerRunning = false;
    });
    _goToNextStep(markComplete: false);
  }
  
  void _startCountdownAndExercise(int exerciseDurationSeconds) {
    setState(() {
      _isCountingDown = true;
      _countdownSeconds = 3;
    });

    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else if (!_isExerciseTimerRunning) {
        // Countdown finished, start exercise timer
        setState(() {
          _isCountingDown = false;
          _isExerciseTimerRunning = true;
          _exerciseSecondsRemaining = exerciseDurationSeconds;
        });
      } else {
        // Exercise timer running
        setState(() {
          _exerciseSecondsRemaining--;
        });

        if (_exerciseSecondsRemaining <= 0) {
          timer.cancel();
          _playAlarm();
          // Mark as complete when timer finishes
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _goToNextStep(markComplete: true);
            }
          });
        }
      }
    });
  }

  void _startRestTimer(int durationSeconds) {
    setState(() {
      _restSecondsRemaining = durationSeconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restSecondsRemaining--;
      });

      if (_restSecondsRemaining <= 0) {
        timer.cancel();
        _playAlarm();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _goToNextStep();
          }
        });
      }
    });
  }

  void _playAlarm() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      print('Error playing alarm: $e');
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _exerciseTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Workout Wizard'),
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Workout Wizard'),
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No workout steps available'),
        ),
      );
    }

    final step = _steps[_currentStepIndex];
    final progress = (_currentStepIndex + 1) / _steps.length;

    return Scaffold(
      appBar: AppBar(
        leading: _currentStepIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goToPreviousStep,
                tooltip: 'Previous Step',
              )
            : null,
        title: Text('Workout (${_currentStepIndex + 1}/${_steps.length})'),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: SafeArea(
        child: _buildStepUI(step),
      ),
    );
  }

  Widget _buildStepUI(WorkoutStep step) {
    switch (step.type) {
      case WorkoutStepType.summary:
        return _buildSummaryStep(step);
      case WorkoutStepType.exercise:
        return _buildExerciseStep(step);
      case WorkoutStepType.rest:
        return _buildRestStep(step);
      case WorkoutStepType.finished:
        return _buildFinishedStep();
    }
  }

  Widget _buildSummaryStep(WorkoutStep step) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 100,
            color: AppColors.primaryLight,
          ),
          const SizedBox(height: 32),
          Text(
            step.title ?? 'Workout',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          if (step.subtitle != null) ...[
            const SizedBox(height: 16),
            Text(
              step.subtitle!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _goToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStepIndex == 0 ? 'START WORKOUT' : 'CONTINUE',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build phase header
  Widget _buildPhaseHeader(WorkoutStep step) {
    if (step.phaseName == null || step.phaseNumber == null || step.totalPhases == null) {
      return const SizedBox.shrink();
    }
    
    // Determine if exercise is completed
    final isCompleted = step.exerciseNumber != null && 
                       _completedExercises.contains(step.exerciseNumber!);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.08),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryLight.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fitness_center,
                size: 18,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Phase: ${step.phaseName} (${step.phaseNumber}/${step.totalPhases})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'DONE',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseStep(WorkoutStep step) {
    // Show countdown overlay if counting down
    if (_isCountingDown && step.isDurationBased) {
      return Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GET READY',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 40),
              Text(
                _countdownSeconds.toString(),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.secondaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 120,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Show timer if exercise is running
    if (_isExerciseTimerRunning && step.isDurationBased) {
      final percent = step.exerciseDurationSeconds != null
          ? _exerciseSecondsRemaining / step.exerciseDurationSeconds!
          : 0.0;

      return Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            _buildPhaseHeader(step),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    step.exerciseName ?? 'Exercise',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  CircularPercentIndicator(
                    radius: 120.0,
                    lineWidth: 16.0,
                    percent: percent.clamp(0.0, 1.0),
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_exerciseSecondsRemaining',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 72,
                                color: AppColors.primaryLight,
                            ),
                        ),
                        Text(
                          'seconds',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                    progressColor: AppColors.secondaryLight,
                    backgroundColor: Colors.grey[300]!,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const Spacer(),
                  if (step.loadDescription != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          step.loadDescription!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[700],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Skip button during timer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: OutlinedButton(
                      onPressed: _skipExercise,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: Text(
                        'SKIP EXERCISE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Show initial exercise screen with "START" button
    return Column(
      children: [
        _buildPhaseHeader(step),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: Lottie.asset(
                        step.lottieAsset ?? 'assets/lottie/default.json',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.fitness_center,
                            size: 200,
                            color: AppColors.primaryLight.withOpacity(0.5),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  step.exerciseName ?? 'Exercise',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (step.setNumber != null) ...[
            Text(
              'SET ${step.setNumber} OF ${step.totalSets}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              step.executionDetails ?? '',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          if (step.loadDescription != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                step.loadDescription!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (step.isDurationBased && step.exerciseDurationSeconds != null) {
                  _startCountdownAndExercise(step.exerciseDurationSeconds!);
                } else {
                  _goToNextStep();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                step.isDurationBased ? 'START EXERCISE' : 'DONE • NEXT',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestStep(WorkoutStep step) {
    final percent = step.restDurationSeconds != null
        ? _restSecondsRemaining / step.restDurationSeconds!
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryLight.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.secondaryLight.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.self_improvement,
                    color: AppColors.secondaryLight,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'RECOVERY TIME',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryLight,
                          letterSpacing: 1.2,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            CircularPercentIndicator(
              radius: 130.0,
              lineWidth: 12.0,
              percent: percent.clamp(0.0, 1.0),
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_restSecondsRemaining',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 80,
                          color: AppColors.primaryLight,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'seconds',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              progressColor: AppColors.secondaryLight,
              backgroundColor: Colors.grey[200]!,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 48),
            Text(
              'Take deep breaths and stay hydrated',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: _goToNextStep,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryLight,
                side: BorderSide(color: AppColors.primaryLight, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'SKIP REST',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishedStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            size: 120,
            color: AppColors.secondaryLight,
          ),
          const SizedBox(height: 32),
          Text(
            'Workout Complete!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Excellent work! You\'ve successfully completed your workout session.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'FINISH',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
