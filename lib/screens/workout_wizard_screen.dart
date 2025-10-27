import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';

// ============================================================================
// PHASE STATE MODELS
// ============================================================================

// Represents the current phase of the workout
enum WorkoutPhase { summary, warmup, mainWorkout, cooldown, finished }

// Represents the current user action state within a phase
enum ActivityState { exercise, rest }

// Holds the complete state of the user's progress
class WorkoutProgressState {
  final WorkoutPhase currentPhase;
  final ActivityState currentActivityState;
  final int currentComponentIndex;
  final int currentRound;
  final int totalRoundsInComponent;
  final int currentExerciseIndexInBlock;
  final int totalExercisesInBlock;
  final int currentSet;
  final int totalSetsForExercise;

  WorkoutProgressState.initial()
      : currentPhase = WorkoutPhase.summary,
        currentActivityState = ActivityState.exercise,
        currentComponentIndex = -1,
        currentRound = 0,
        totalRoundsInComponent = 0,
        currentExerciseIndexInBlock = 0,
        totalExercisesInBlock = 0,
        currentSet = 1,
        totalSetsForExercise = 0;

  WorkoutProgressState._internal({
    required this.currentPhase,
    required this.currentActivityState,
    required this.currentComponentIndex,
    required this.currentRound,
    required this.totalRoundsInComponent,
    required this.currentExerciseIndexInBlock,
    required this.totalExercisesInBlock,
    required this.currentSet,
    required this.totalSetsForExercise,
  });

  WorkoutProgressState copyWith({
    WorkoutPhase? currentPhase,
    ActivityState? currentActivityState,
    int? currentComponentIndex,
    int? currentRound,
    int? totalRoundsInComponent,
    int? currentExerciseIndexInBlock,
    int? totalExercisesInBlock,
    int? currentSet,
    int? totalSetsForExercise,
  }) {
    return WorkoutProgressState._internal(
      currentPhase: currentPhase ?? this.currentPhase,
      currentActivityState: currentActivityState ?? this.currentActivityState,
      currentComponentIndex: currentComponentIndex ?? this.currentComponentIndex,
      currentRound: currentRound ?? this.currentRound,
      totalRoundsInComponent: totalRoundsInComponent ?? this.totalRoundsInComponent,
      currentExerciseIndexInBlock: currentExerciseIndexInBlock ?? this.currentExerciseIndexInBlock,
      totalExercisesInBlock: totalExercisesInBlock ?? this.totalExercisesInBlock,
      currentSet: currentSet ?? this.currentSet,
      totalSetsForExercise: totalSetsForExercise ?? this.totalSetsForExercise,
    );
  }
}

// ============================================================================
// DATA MODELS (from original JSON structure)
// ============================================================================

class WorkoutProgram {
  final String programId;
  final String programTitle;
  final List<DaySchedule> weeklySchedule;
  final Map<String, WorkoutBlock> workoutLibrary;

  WorkoutProgram({
    required this.programId,
    required this.programTitle,
    required this.weeklySchedule,
    required this.workoutLibrary,
  });

  factory WorkoutProgram.fromJson(Map<String, dynamic> json) {
    return WorkoutProgram(
      programId: json['programId'] ?? '',
      programTitle: json['programTitle'] ?? '',
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
  final List<Component> components;

  Session({
    required this.sessionId,
    required this.title,
    required this.components,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['sessionId'] ?? '',
      title: json['title'] ?? '',
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

  Component({
    required this.componentType,
    required this.blockId,
    required this.rounds,
  });

  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      componentType: json['componentType'] ?? '',
      blockId: json['blockId'] ?? '',
      rounds: json['rounds'] ?? 1,
    );
  }
}

class WorkoutBlock {
  final String blockId;
  final String title;
  final String blockType;
  final List<Exercise> exercises;
  final int? estimatedDurationMinutes;

  WorkoutBlock({
    required this.blockId,
    required this.title,
    required this.blockType,
    required this.exercises,
    this.estimatedDurationMinutes,
  });

  factory WorkoutBlock.fromJson(Map<String, dynamic> json) {
    return WorkoutBlock(
      blockId: json['blockId'] ?? '',
      title: json['title'] ?? '',
      blockType: json['blockType'] ?? '',
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => Exercise.fromJson(e))
          .toList(),
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int?,
    );
  }
}

class Exercise {
  final String exerciseId;
  final String name;
  final List<Progression>? progression;
  final Execution? execution;

  Exercise({
    required this.exerciseId,
    required this.name,
    this.progression,
    this.execution,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exerciseId'] ?? '',
      name: json['name'] ?? '',
      progression: json['progression'] != null
          ? (json['progression'] as List).map((e) => Progression.fromJson(e)).toList()
          : null,
      execution: json['execution'] != null
          ? Execution.fromJson(json['execution'])
          : null,
    );
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
      weekRange: WeekRange.fromJson(json['weekRange']),
      sets: json['sets'] ?? 1,
      execution: Execution.fromJson(json['execution']),
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

class Execution {
  final String type;
  final int? reps;
  final int? minReps;
  final int? maxReps;
  final int? durationSeconds;
  final int? minSeconds;
  final int? maxSeconds;
  final String? description;

  Execution({
    required this.type,
    this.reps,
    this.minReps,
    this.maxReps,
    this.durationSeconds,
    this.minSeconds,
    this.maxSeconds,
    this.description,
  });

  factory Execution.fromJson(Map<String, dynamic> json) {
    return Execution(
      type: json['type'] ?? '',
      reps: json['reps'],
      minReps: json['minReps'],
      maxReps: json['maxReps'],
      durationSeconds: json['durationSeconds'],
      minSeconds: json['minSeconds'],
      maxSeconds: json['maxSeconds'],
      description: json['description'],
    );
  }

  String toDisplayString() {
    switch (type) {
      case 'REPS':
        return '$reps reps${description != null ? ' ($description)' : ''}';
      case 'REP_RANGE':
        return '$minReps-$maxReps reps${description != null ? ' ($description)' : ''}';
      case 'DURATION':
        return '${durationSeconds}s${description != null ? ' ($description)' : ''}';
      case 'DURATION_RANGE':
        return '${minSeconds}-${maxSeconds}s${description != null ? ' ($description)' : ''}';
      case 'AMRAP':
        return 'As Many Reps As Possible';
      default:
        return type;
    }
  }

  bool get isDurationBased =>
      type == 'DURATION' || type == 'DURATION_RANGE';
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
  final int? minSeconds;
  final int? maxSeconds;

  Rest({
    required this.type,
    this.durationSeconds,
    this.minSeconds,
    this.maxSeconds,
  });

  factory Rest.fromJson(Map<String, dynamic> json) {
    return Rest(
      type: json['type'] ?? '',
      durationSeconds: json['durationSeconds'],
      minSeconds: json['minSeconds'],
      maxSeconds: json['maxSeconds'],
    );
  }

  int getMinRestSeconds() {
    // Return minimum rest time (alarm sounds here)
    if (minSeconds != null) return minSeconds!;
    if (durationSeconds != null) return durationSeconds!;
    return 30; // Default minimum
  }

  int getMaxRestSeconds() {
    // Return maximum rest time (auto-advance here)
    if (maxSeconds != null) return maxSeconds!;
    if (durationSeconds != null) return durationSeconds!;
    return 45; // Default maximum
  }

  int getRestSeconds() {
    // Backward compatibility - returns average
    if (durationSeconds != null) return durationSeconds!;
    if (minSeconds != null && maxSeconds != null) {
      return ((minSeconds! + maxSeconds!) / 2).round();
    }
    return 60; // Default 60s
  }
}

// Helper class to hold time allocation data for a block
class _BlockTimeData {
  final int timePerRepSet;
  
  _BlockTimeData({required this.timePerRepSet});
}


// ============================================================================
// WORKOUT WIZARD SCREEN
// ============================================================================

class WorkoutWizardScreen extends StatefulWidget {
  const WorkoutWizardScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutWizardScreen> createState() => _WorkoutWizardScreenState();
}

class _WorkoutWizardScreenState extends State<WorkoutWizardScreen> with WidgetsBindingObserver {
  WorkoutProgram? _program;
  Session? _currentSession;
  WorkoutProgressState _progressState = WorkoutProgressState.initial();
  
  // Timer for rest periods
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  bool _restAlarmSounded = false;
  
  // Timer for duration-based exercises
  Timer? _exerciseTimer;
  int _exerciseSecondsRemaining = 0;
  bool _isCountingDown = false;
  int _countdownSeconds = 3;
  
  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Current week (hardcoded to week 1 for this example)
  final int _currentWeek = 1;

  // Time tracking for progress calculation
  int _totalEstimatedSeconds = 0;

  // Flag to track if user explicitly exited (should not save state)
  bool _shouldSaveOnDispose = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadWorkoutData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Only save state if user didn't explicitly exit
    if (_shouldSaveOnDispose) {
      _saveWorkoutState();
    }
    _restTimer?.cancel();
    _exerciseTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App going to background - pause timers and save state
      _pauseTimers();
      _saveWorkoutState();
    } else if (state == AppLifecycleState.resumed) {
      // App coming back to foreground - resume timers if in exercise or rest
      _resumeTimersIfNeeded();
    }
  }

  void _pauseTimers() {
    _restTimer?.cancel();
    _exerciseTimer?.cancel();
    _restTimer = null;
    _exerciseTimer = null;
  }

  void _resumeTimersIfNeeded() {
    // Only resume if we're actually in an active workout (not summary or finished)
    if (_progressState.currentPhase == WorkoutPhase.summary || 
        _progressState.currentPhase == WorkoutPhase.finished) {
      return;
    }

    // Resume rest timer if in rest state
    if (_progressState.currentActivityState == ActivityState.rest) {
      _startRestTimer();
    }
    // Note: Exercise timer is handled by duration-based exercises which auto-start
  }

  Future<void> _saveWorkoutState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Only save if workout is in progress (not in summary or finished)
      if (_progressState.currentPhase == WorkoutPhase.summary || 
          _progressState.currentPhase == WorkoutPhase.finished) {
        return;
      }

      await prefs.setInt('currentPhase', _progressState.currentPhase.index);
      await prefs.setInt('currentActivityState', _progressState.currentActivityState.index);
      await prefs.setInt('currentComponentIndex', _progressState.currentComponentIndex);
      await prefs.setInt('currentRound', _progressState.currentRound);
      await prefs.setInt('totalRoundsInComponent', _progressState.totalRoundsInComponent);
      await prefs.setInt('currentExerciseIndexInBlock', _progressState.currentExerciseIndexInBlock);
      await prefs.setInt('totalExercisesInBlock', _progressState.totalExercisesInBlock);
      await prefs.setInt('currentSet', _progressState.currentSet);
      await prefs.setInt('totalSetsForExercise', _progressState.totalSetsForExercise);
      await prefs.setInt('restSecondsRemaining', _restSecondsRemaining);
      await prefs.setBool('restAlarmSounded', _restAlarmSounded);
      await prefs.setBool('hasWorkoutInProgress', true);
      
      print('Workout state saved successfully');
    } catch (e) {
      print('Error saving workout state: $e');
    }
  }

  Future<bool> _hasSavedWorkoutState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('hasWorkoutInProgress') ?? false;
    } catch (e) {
      print('Error checking saved state: $e');
      return false;
    }
  }

  Future<void> _restoreWorkoutState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final phaseIndex = prefs.getInt('currentPhase') ?? 0;
      final activityStateIndex = prefs.getInt('currentActivityState') ?? 0;
      final componentIndex = prefs.getInt('currentComponentIndex') ?? -1;
      final round = prefs.getInt('currentRound') ?? 0;
      final totalRounds = prefs.getInt('totalRoundsInComponent') ?? 0;
      final exerciseIndex = prefs.getInt('currentExerciseIndexInBlock') ?? 0;
      final totalExercises = prefs.getInt('totalExercisesInBlock') ?? 0;
      final currentSet = prefs.getInt('currentSet') ?? 1;
      final totalSets = prefs.getInt('totalSetsForExercise') ?? 0;
      final restSecondsRemaining = prefs.getInt('restSecondsRemaining') ?? 0;
      final restAlarmSounded = prefs.getBool('restAlarmSounded') ?? false;

      setState(() {
        _progressState = WorkoutProgressState._internal(
          currentPhase: WorkoutPhase.values[phaseIndex],
          currentActivityState: ActivityState.values[activityStateIndex],
          currentComponentIndex: componentIndex,
          currentRound: round,
          totalRoundsInComponent: totalRounds,
          currentExerciseIndexInBlock: exerciseIndex,
          totalExercisesInBlock: totalExercises,
          currentSet: currentSet,
          totalSetsForExercise: totalSets,
        );
        _restSecondsRemaining = restSecondsRemaining;
        _restAlarmSounded = restAlarmSounded;
      });
      
      // Resume timers if we were in an active workout state
      _resumeTimersIfNeeded();
      
      print('Workout state restored successfully');
    } catch (e) {
      print('Error restoring workout state: $e');
    }
  }

  Future<void> _clearWorkoutState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentPhase');
      await prefs.remove('currentActivityState');
      await prefs.remove('currentComponentIndex');
      await prefs.remove('currentRound');
      await prefs.remove('totalRoundsInComponent');
      await prefs.remove('currentExerciseIndexInBlock');
      await prefs.remove('totalExercisesInBlock');
      await prefs.remove('currentSet');
      await prefs.remove('totalSetsForExercise');
      await prefs.remove('restSecondsRemaining');
      await prefs.remove('restAlarmSounded');
      await prefs.setBool('hasWorkoutInProgress', false);
      
      print('Workout state cleared');
    } catch (e) {
      print('Error clearing workout state: $e');
    }
  }

  Future<void> _loadWorkoutData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('bdata/DailyWorkout.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final program = WorkoutProgram.fromJson(jsonData);

      // Get today's day of week
      final now = DateTime.now();
      final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final todayName = daysOfWeek[now.weekday - 1]; // weekday is 1-7, Monday is 1
      
      // Find today's session
      final todaySchedule = program.weeklySchedule.firstWhere(
        (day) => day.dayOfWeek == todayName,
        orElse: () => program.weeklySchedule.first,
      );

      setState(() {
        _program = program;
        _currentSession = todaySchedule.sessions.first;
        _totalEstimatedSeconds = _calculateTotalEstimatedTime();
      });

      // Check if there's a saved workout state
      final hasSavedState = await _hasSavedWorkoutState();
      if (hasSavedState && mounted) {
        _showResumeWorkoutDialog();
      }
    } catch (e) {
      print('Error loading workout data: $e');
    }
  }

  Future<void> _showResumeWorkoutDialog() async {
    final shouldResume = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_circle_outline,
                color: AppColors.primaryLight,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Resume Workout?'),
          ],
        ),
        content: const Text(
          'You have a workout in progress. Would you like to continue where you left off?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Start Fresh',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Resume'),
          ),
        ],
      ),
    );

    if (shouldResume == true) {
      await _restoreWorkoutState();
    } else {
      await _clearWorkoutState();
    }
  }

  // ============================================================================
  // HELPER FUNCTIONS TO GET CURRENT DATA
  // ============================================================================

  Component? _getCurrentComponent() {
    if (_currentSession == null || _progressState.currentComponentIndex < 0) {
      return null;
    }
    if (_progressState.currentComponentIndex >= _currentSession!.components.length) {
      return null;
    }
    return _currentSession!.components[_progressState.currentComponentIndex];
  }

  WorkoutBlock? _getCurrentBlock() {
    final component = _getCurrentComponent();
    if (component == null || _program == null) return null;
    return _program!.workoutLibrary[component.blockId];
  }

  Exercise? _getCurrentExercise() {
    final block = _getCurrentBlock();
    if (block == null) return null;
    if (_progressState.currentExerciseIndexInBlock >= block.exercises.length) {
      return null;
    }
    return block.exercises[_progressState.currentExerciseIndexInBlock];
  }

  Progression? _getCurrentProgression() {
    final exercise = _getCurrentExercise();
    if (exercise == null) return null;
    
    // If exercise has direct execution (like warmup), wrap it in a Progression
    if (exercise.execution != null && exercise.progression == null) {
      return Progression(
        weekRange: WeekRange(start: 1, end: 12),
        sets: 1,
        execution: exercise.execution!,
        rest: null,
        load: null,
      );
    }
    
    // Find progression for current week
    if (exercise.progression != null) {
      for (var prog in exercise.progression!) {
        if (prog.weekRange.contains(_currentWeek)) {
          return prog;
        }
      }
    }
    
    return null;
  }

  // ============================================================================
  // TIME CALCULATION & PROGRESS TRACKING
  // ============================================================================

  /// Calculate total estimated time for the entire workout session
  int _calculateTotalEstimatedTime() {
    if (_currentSession == null || _program == null) return 0;

    int totalSeconds = 0;

    for (var component in _currentSession!.components) {
      totalSeconds += _calculateComponentTime(component);
    }

    return totalSeconds;
  }

  /// Calculate time completed so far
  int _calculateCompletedTime() {
    if (_currentSession == null || _program == null) return 0;
    if (_progressState.currentPhase == WorkoutPhase.summary) return 0;

    int completedSeconds = 0;

    // Calculate time for all completed components
    for (int compIdx = 0; compIdx < _progressState.currentComponentIndex; compIdx++) {
      final component = _currentSession!.components[compIdx];
      completedSeconds += _calculateComponentTime(component);
    }

    // Add time for current component progress
    final currentComponent = _getCurrentComponent();
    if (currentComponent != null) {
      completedSeconds += _calculateCurrentComponentProgress();
    }

    return completedSeconds;
  }

  /// Calculate progress within the current component
  int _calculateCurrentComponentProgress() {
    final block = _getCurrentBlock();
    if (block == null) return 0;

    // Get per-set time allocation for this block
    final timeData = _getBlockTimeData(block);
    int completedSeconds = 0;

    // Add time for completed exercises
    for (int exIdx = 0; exIdx < _progressState.currentExerciseIndexInBlock; exIdx++) {
      final exercise = block.exercises[exIdx];
      final progression = _getProgressionForExercise(exercise);
      if (progression == null) continue;

      final sets = progression.sets;
      
      if (progression.execution.isDurationBased) {
        final duration = progression.execution.durationSeconds ??
            progression.execution.minSeconds ??
            45;
        completedSeconds += (duration + 3) * sets; // duration + countdown
      } else {
        completedSeconds += (timeData.timePerRepSet * sets);
      }

      // Add rest time between sets (using max rest time from JSON)
      if (sets > 1) {
        final maxRestTime = progression.rest?.getMaxRestSeconds() ?? 45;
        completedSeconds += maxRestTime * (sets - 1);
      }

      // Add transition time
      if (exIdx < block.exercises.length - 1) {
        completedSeconds += 10;
      }
    }

    // Add time for completed sets in current exercise
    final currentExercise = _getCurrentExercise();
    final currentProgression = _getCurrentProgression();
    if (currentExercise != null && currentProgression != null) {
      final completedSets = _progressState.currentSet - 1;

      if (completedSets > 0) {
        if (currentProgression.execution.isDurationBased) {
          final duration = currentProgression.execution.durationSeconds ??
              currentProgression.execution.minSeconds ??
              45;
          completedSeconds += (duration + 3) * completedSets;
        } else {
          completedSeconds += (timeData.timePerRepSet * completedSets);
        }

        // Add rest time for completed sets (using max rest time)
        final maxRestTime = currentProgression.rest?.getMaxRestSeconds() ?? 45;
        completedSeconds += maxRestTime * completedSets;
      }

      // If currently resting, add time spent in rest
      if (_progressState.currentActivityState == ActivityState.rest) {
        final maxRestTime = currentProgression.rest?.getMaxRestSeconds() ?? 45;
        final restElapsed = maxRestTime - _restSecondsRemaining;
        completedSeconds += restElapsed;
      }

      // If currently exercising a duration-based exercise, add elapsed time
      if (_progressState.currentActivityState == ActivityState.exercise &&
          currentProgression.execution.isDurationBased &&
          _exerciseSecondsRemaining > 0) {
        final totalDuration = currentProgression.execution.durationSeconds ??
            currentProgression.execution.minSeconds ??
            45;
        final elapsed = totalDuration - _exerciseSecondsRemaining;
        completedSeconds += elapsed;
      }
    }

    return completedSeconds;
  }

  /// Calculate time data for a block based on estimatedDurationMinutes
  _BlockTimeData _getBlockTimeData(WorkoutBlock block) {
    // Use estimated duration from JSON if available
    final estimatedMinutes = block.estimatedDurationMinutes ?? 20;
    final totalAvailableSeconds = estimatedMinutes * 60;

    int timedExerciseSeconds = 0;
    int totalTransitionSeconds = 0;
    int totalRestSeconds = 0;

    // Calculate time used by duration-based exercises and rest times
    for (int exIdx = 0; exIdx < block.exercises.length; exIdx++) {
      final exercise = block.exercises[exIdx];
      final progression = _getProgressionForExercise(exercise);
      if (progression == null) continue;

      final sets = progression.sets;

      if (progression.execution.isDurationBased) {
        final duration = progression.execution.durationSeconds ??
            progression.execution.minSeconds ??
            45;
        timedExerciseSeconds += (duration + 3) * sets; // duration + countdown per set
      }

      // Add rest time between sets within this exercise (use max rest for time estimation)
      if (sets > 1) {
        final maxRestPerSet = progression.rest?.getMaxRestSeconds() ?? 45;
        totalRestSeconds += maxRestPerSet * (sets - 1);
      }

      // Add transition time between exercises
      if (exIdx < block.exercises.length - 1) {
        totalTransitionSeconds += 10;
      }
    }

    // Calculate remaining time for rep-based exercises
    final usedTime = timedExerciseSeconds + totalRestSeconds + totalTransitionSeconds;
    final remainingTime = totalAvailableSeconds - usedTime;

    // Count only rep-based sets for time distribution
    int totalRepSets = 0;
    for (final exercise in block.exercises) {
      final progression = _getProgressionForExercise(exercise);
      if (progression != null && !progression.execution.isDurationBased) {
        totalRepSets += progression.sets;
      }
    }

    // Distribute remaining time equally across all rep-based sets
    final timePerRepSet = totalRepSets > 0 ? (remainingTime / totalRepSets).floor() : 0;

    return _BlockTimeData(
      timePerRepSet: timePerRepSet.clamp(5, 120), // Min 5 sec, max 2 min per set
    );
  }

  double _calculateProgress() {
    if (_totalEstimatedSeconds == 0) return 0.0;
    final completed = _calculateCompletedTime();
    return (completed / _totalEstimatedSeconds).clamp(0.0, 1.0);
  }

  /// Calculate estimated time for a specific component
  int _calculateComponentTime(Component component) {
    final block = _program?.workoutLibrary[component.blockId];
    if (block == null) return 0;

    // Use estimatedDurationMinutes from the block if available
    if (block.estimatedDurationMinutes != null) {
      return block.estimatedDurationMinutes! * 60;
    }

    // Fallback to calculation if no estimated duration provided
    int totalSeconds = 0;
    const int avgRepTimeSeconds = 3;
    const int avgSetupTimeSeconds = 5;
    const int transitionBetweenExercises = 10;

    for (int exIdx = 0; exIdx < block.exercises.length; exIdx++) {
      final exercise = block.exercises[exIdx];
      final progression = _getProgressionForExercise(exercise);
      if (progression == null) continue;

      final sets = progression.sets;

      if (progression.execution.isDurationBased) {
        final duration = progression.execution.durationSeconds ??
            progression.execution.minSeconds ??
            45;
        totalSeconds += duration * sets;
        totalSeconds += 3 * sets;
      } else {
        final reps = progression.execution.reps ??
            progression.execution.maxReps ??
            12;
        totalSeconds += (reps * avgRepTimeSeconds + avgSetupTimeSeconds) * sets;
      }

      if (sets > 1) {
        final restTime = progression.rest?.getMaxRestSeconds() ?? 60;
        totalSeconds += restTime * (sets - 1);
      }

      if (exIdx < block.exercises.length - 1) {
        totalSeconds += transitionBetweenExercises;
      }
    }

    return totalSeconds;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }

  // ============================================================================
  // STATE TRANSITION LOGIC
  // ============================================================================

  void _moveToNextStep() {
    _restTimer?.cancel();
    _exerciseTimer?.cancel();

    final currentPhase = _progressState.currentPhase;
    final currentActivity = _progressState.currentActivityState;

    // SUMMARY -> Start first component
    if (currentPhase == WorkoutPhase.summary) {
      _startFirstComponent();
      _saveWorkoutState(); // Save state when starting workout
      return;
    }

    // FINISHED -> Do nothing
    if (currentPhase == WorkoutPhase.finished) {
      _clearWorkoutState(); // Clear state when workout finishes
      return;
    }

    // EXERCISE -> REST
    if (currentActivity == ActivityState.exercise) {
      _moveToRest();
      _saveWorkoutState(); // Save after each exercise
      return;
    }

    // REST -> Next state logic
    if (currentActivity == ActivityState.rest) {
      _moveFromRest();
      _saveWorkoutState(); // Save after rest
      return;
    }
  }

  void _startFirstComponent() {
    if (_currentSession == null || _currentSession!.components.isEmpty) {
      return;
    }

    final firstComponent = _currentSession!.components[0];
    final firstBlock = _program!.workoutLibrary[firstComponent.blockId];
    if (firstBlock == null || firstBlock.exercises.isEmpty) return;

    final firstExercise = firstBlock.exercises[0];
    final firstProgression = _getProgressionForExercise(firstExercise);
    
    final phase = _determinePhase(firstBlock.blockType);

    setState(() {
      _progressState = _progressState.copyWith(
        currentPhase: phase,
        currentActivityState: ActivityState.exercise,
        currentComponentIndex: 0,
        currentRound: 1, // Not used in Standard Sets, kept for state compatibility
        totalRoundsInComponent: 1, // Not used in Standard Sets
        currentExerciseIndexInBlock: 0,
        totalExercisesInBlock: firstBlock.exercises.length,
        currentSet: 1,
        totalSetsForExercise: firstProgression?.sets ?? 1,
      );
    });
  }

  void _moveToRest() {
    final progression = _getCurrentProgression();
    if (progression == null) return;

    // Use max rest time from exercise JSON (includes grace period)
    final maxRestSeconds = progression.rest?.getMaxRestSeconds() ?? 45;

    setState(() {
      _progressState = _progressState.copyWith(
        currentActivityState: ActivityState.rest,
      );
      _restSecondsRemaining = maxRestSeconds;
      _restAlarmSounded = false; // Reset alarm flag
    });

    _startRestTimer();
  }

  void _moveFromRest() {
    final nextSet = _progressState.currentSet + 1;

    // More sets in current exercise? (STANDARD SETS MODEL)
    if (nextSet <= _progressState.totalSetsForExercise) {
      setState(() {
        _progressState = _progressState.copyWith(
          currentActivityState: ActivityState.exercise,
          currentSet: nextSet,
        );
      });
      return;
    }

    // All sets completed for current exercise -> Move to next exercise
    final nextExerciseIndex = _progressState.currentExerciseIndexInBlock + 1;

    // More exercises in current block?
    if (nextExerciseIndex < _progressState.totalExercisesInBlock) {
      final block = _getCurrentBlock()!;
      final nextExercise = block.exercises[nextExerciseIndex];
      final nextProgression = _getProgressionForExercise(nextExercise);

      setState(() {
        _progressState = _progressState.copyWith(
          currentActivityState: ActivityState.exercise,
          currentExerciseIndexInBlock: nextExerciseIndex,
          currentSet: 1,
          totalSetsForExercise: nextProgression?.sets ?? 1,
        );
      });
      return;
    }

    // All exercises completed in current block -> Move to next component
    _moveToNextComponent();
  }

  void _moveToNextComponent() {
    final nextComponentIndex = _progressState.currentComponentIndex + 1;

    // More components?
    if (nextComponentIndex < _currentSession!.components.length) {
      final nextComponent = _currentSession!.components[nextComponentIndex];
      final nextBlock = _program!.workoutLibrary[nextComponent.blockId];
      if (nextBlock == null || nextBlock.exercises.isEmpty) return;

      final firstExercise = nextBlock.exercises[0];
      final firstProgression = _getProgressionForExercise(firstExercise);
      final nextPhase = _determinePhase(nextBlock.blockType);

      setState(() {
        _progressState = _progressState.copyWith(
          currentPhase: nextPhase,
          currentActivityState: ActivityState.exercise,
          currentComponentIndex: nextComponentIndex,
          currentRound: 1, // Not used in Standard Sets
          totalRoundsInComponent: 1, // Not used in Standard Sets
          currentExerciseIndexInBlock: 0,
          totalExercisesInBlock: nextBlock.exercises.length,
          currentSet: 1,
          totalSetsForExercise: firstProgression?.sets ?? 1,
        );
      });
      return;
    }

    // No more components -> Finished
    setState(() {
      _progressState = _progressState.copyWith(
        currentPhase: WorkoutPhase.finished,
      );
    });
  }

  WorkoutPhase _determinePhase(String blockType) {
    switch (blockType.toUpperCase()) {
      case 'WARM_UP':
        return WorkoutPhase.warmup;
      case 'COOL_DOWN':
        return WorkoutPhase.cooldown;
      default:
        return WorkoutPhase.mainWorkout;
    }
  }

  Progression? _getProgressionForExercise(Exercise exercise) {
    if (exercise.execution != null && exercise.progression == null) {
      return Progression(
        weekRange: WeekRange(start: 1, end: 12),
        sets: 1,
        execution: exercise.execution!,
        rest: null,
        load: null,
      );
    }
    
    if (exercise.progression != null) {
      for (var prog in exercise.progression!) {
        if (prog.weekRange.contains(_currentWeek)) {
          return prog;
        }
      }
    }
    
    return null;
  }

  void _startRestTimer() {
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_restSecondsRemaining > 0) {
          _restSecondsRemaining--;
          
          // Get current progression for alarm timing
          final progression = _getCurrentProgression();
          if (progression != null) {
            // Sound alarm at minimum rest time
            final minRestTime = progression.rest?.getMinRestSeconds() ?? 30;
            final maxRestTime = progression.rest?.getMaxRestSeconds() ?? 45;
            final timeElapsed = maxRestTime - _restSecondsRemaining;
            
            if (!_restAlarmSounded && timeElapsed >= minRestTime) {
              _restAlarmSounded = true;
              _playSound();
            }
          }
        } else {
          // Auto-advance when max rest time reached
          timer.cancel();
          _moveToNextStep();
        }
      });
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    _moveToNextStep();
  }

  Future<void> _playSound() async {
    try {
      // Try to play alarm sound
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      // Fallback to haptic feedback if audio file is missing
      debugPrint('Audio playback failed, using haptic feedback: $e');
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.heavyImpact();
    }
  }

  // ============================================================================
  // Duration-based exercise logic
  // ============================================================================

  void _startCountdownAndExercise(int exerciseSeconds) {
    setState(() {
      _isCountingDown = true;
      _countdownSeconds = 3;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 1) {
        setState(() => _countdownSeconds--);
      } else {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
          _exerciseSecondsRemaining = exerciseSeconds;
        });
        _startExerciseTimer();
      }
    });
  }

  void _startExerciseTimer() {
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_exerciseSecondsRemaining > 0) {
          _exerciseSecondsRemaining--;
        } else {
          timer.cancel();
          _playSound();
          _moveToNextStep();
        }
      });
    });
  }

  void _skipExercise() {
    _exerciseTimer?.cancel();
    setState(() {
      _exerciseSecondsRemaining = 0;
    });
    _moveToNextStep();
  }

  // ============================================================================
  // BACK NAVIGATION
  // ============================================================================

  void _goToPreviousStep() {
    // Stop any active timers first
    _restTimer?.cancel();
    _exerciseTimer?.cancel();

    // If in rest, go back to the exercise we just completed
    if (_progressState.currentActivityState == ActivityState.rest) {
      setState(() {
        _progressState = _progressState.copyWith(
          currentActivityState: ActivityState.exercise,
        );
        _isCountingDown = false;
        _exerciseSecondsRemaining = 0;
      });
      return;
    }

    // If on first set of an exercise, go to previous exercise
    if (_progressState.currentSet == 1) {
      // If first exercise in block, go to previous component
      if (_progressState.currentExerciseIndexInBlock == 0) {
        // If first component, can't go back further - go to summary
        if (_progressState.currentComponentIndex == 0) {
          setState(() {
            _progressState = _progressState.copyWith(
              currentPhase: WorkoutPhase.summary,
            );
          });
          return;
        }

        // Go to last exercise of previous component
        final prevComponentIndex = _progressState.currentComponentIndex - 1;
        final prevComponent = _currentSession!.components[prevComponentIndex];
        final prevBlock = _program!.workoutLibrary[prevComponent.blockId];
        if (prevBlock == null) return;

        final lastExerciseIndex = prevBlock.exercises.length - 1;
        final lastExercise = prevBlock.exercises[lastExerciseIndex];
        final lastProgression = _getProgressionForExercise(lastExercise);
        final prevPhase = _determinePhase(prevBlock.blockType);

        setState(() {
          _progressState = _progressState.copyWith(
            currentPhase: prevPhase,
            currentComponentIndex: prevComponentIndex,
            currentExerciseIndexInBlock: lastExerciseIndex,
            currentActivityState: ActivityState.exercise,
            currentSet: lastProgression?.sets ?? 1,
            totalSetsForExercise: lastProgression?.sets ?? 1,
            currentRound: 1,
            totalRoundsInComponent: 1,
            totalExercisesInBlock: prevBlock.exercises.length,
          );
          _isCountingDown = false;
          _exerciseSecondsRemaining = 0;
        });
        return;
      }

      // Go to previous exercise in same block
      final prevExerciseIndex = _progressState.currentExerciseIndexInBlock - 1;
      final block = _getCurrentBlock()!;
      final prevExercise = block.exercises[prevExerciseIndex];
      final prevProgression = _getProgressionForExercise(prevExercise);

      setState(() {
        _progressState = _progressState.copyWith(
          currentExerciseIndexInBlock: prevExerciseIndex,
          currentActivityState: ActivityState.exercise,
          currentSet: prevProgression?.sets ?? 1,
          totalSetsForExercise: prevProgression?.sets ?? 1,
        );
        _isCountingDown = false;
        _exerciseSecondsRemaining = 0;
      });
      return;
    }

    // Go to previous set of same exercise
    setState(() {
      _progressState = _progressState.copyWith(
        currentSet: _progressState.currentSet - 1,
        currentActivityState: ActivityState.exercise,
      );
      _isCountingDown = false;
      _exerciseSecondsRemaining = 0;
    });
  }

  // ============================================================================
  // BUILD UI
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    if (_program == null || _currentSession == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    final showProgress = _progressState.currentPhase != WorkoutPhase.summary &&
        _progressState.currentPhase != WorkoutPhase.finished;
    
    return AppBar(
      leading: showProgress
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goToPreviousStep,
            )
          : IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => Navigator.of(context).pop(),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_getAppBarTitle()),
          Row(
            children: [
              Text(
                _getCurrentDayName(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              if (showProgress && _totalEstimatedSeconds > 0) ...[
                const Text(
                  ' • ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
                Text(
                  '${_formatTime(_totalEstimatedSeconds - _calculateCompletedTime())} remaining',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ],
          ),
        ],
      ),
      actions: [
        if (showProgress)
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Home',
            onPressed: () {
              _showExitConfirmDialog(context, isHomeButton: true);
            },
          ),
        if (showProgress)
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Exit Workout',
            onPressed: () {
              _showExitConfirmDialog(context, isHomeButton: false);
            },
          ),
      ],
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      bottom: showProgress && _totalEstimatedSeconds > 0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: LinearProgressIndicator(
                value: _calculateProgress(),
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : null,
    );
  }

  void _showExitConfirmDialog(BuildContext context, {required bool isHomeButton}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                isHomeButton ? Icons.home : Icons.exit_to_app,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              Text(isHomeButton ? 'Return Home?' : 'Exit Workout?'),
            ],
          ),
          content: Text(
            isHomeButton
                ? 'Your workout progress will be saved and you can resume later.'
                : 'Are you sure you want to exit? This will clear your workout progress.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'CANCEL',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Close dialog first
                Navigator.of(dialogContext).pop();
                
                if (isHomeButton) {
                  // Going home - save state
                  await _saveWorkoutState();
                } else {
                  // Exiting - clear state and prevent saving on dispose
                  _shouldSaveOnDispose = false;
                  await _clearWorkoutState();
                }
                
                // Exit workout screen
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isHomeButton ? AppColors.primaryLight : Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(isHomeButton ? 'GO HOME' : 'EXIT'),
            ),
          ],
        );
      },
    );
  }

  String _getAppBarTitle() {
    switch (_progressState.currentPhase) {
      case WorkoutPhase.summary:
        return 'Workout Summary';
      case WorkoutPhase.warmup:
        return 'Warm-up';
      case WorkoutPhase.mainWorkout:
        return 'Main Workout';
      case WorkoutPhase.cooldown:
        return 'Cool-down';
      case WorkoutPhase.finished:
        return 'Workout Complete!';
    }
  }

  String _getCurrentDayName() {
    final now = DateTime.now();
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return daysOfWeek[now.weekday - 1];
  }

  Widget _buildBody() {
    switch (_progressState.currentPhase) {
      case WorkoutPhase.summary:
        return _buildSummaryScreen();
      case WorkoutPhase.finished:
        return _buildFinishedScreen();
      default:
        return _buildWorkoutScreen();
    }
  }

  Widget _buildSummaryScreen() {
    final totalTime = _formatTime(_totalEstimatedSeconds);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentSession!.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondaryLight.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppColors.secondaryLight, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Total Time: $totalTime',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryLight,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Workout Components:',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _currentSession!.components.length,
              itemBuilder: (context, index) {
                final component = _currentSession!.components[index];
                final block = _program!.workoutLibrary[component.blockId];
                if (block == null) return const SizedBox.shrink();
                
                final componentTime = _formatTime(_calculateComponentTime(component));
                final exerciseCount = block.exercises.length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    title: Text(
                      block.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '$exerciseCount exercise${exerciseCount != 1 ? 's' : ''} • $componentTime',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...block.exercises.map((exercise) {
                              final progression = _getProgressionForExercise(exercise);
                              final sets = progression?.sets ?? 1;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryLight,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        exercise.name,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      '$sets set${sets != 1 ? 's' : ''}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _moveToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'START WORKOUT',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutScreen() {
    if (_progressState.currentActivityState == ActivityState.rest) {
      return _buildRestScreen();
    } else {
      return _buildExerciseScreen();
    }
  }

  Widget _buildExerciseScreen() {
    final exercise = _getCurrentExercise();
    final progression = _getCurrentProgression();
    final block = _getCurrentBlock();

    if (exercise == null || progression == null || block == null) {
      return const Center(child: Text('Error loading exercise'));
    }

    // Check if countdown or timer is active for duration exercises
    if (progression.execution.isDurationBased) {
      if (_isCountingDown) {
        return _buildCountdownOverlay();
      }
      if (_exerciseSecondsRemaining > 0) {
        return _buildExerciseTimerScreen(exercise, progression);
      }
    }

    return Column(
      children: [
        _buildPhaseHeader(block),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Icon(
                      Icons.fitness_center,
                      size: 200,
                      color: AppColors.primaryLight.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Exercise Name with Set indicator
                Column(
                  children: [
                    // Exercise name with subtle gradient background
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryLight,
                              letterSpacing: 0.3,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Modern set indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            color: AppColors.primaryLight,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SET ${_progressState.currentSet} OF ${_progressState.totalSetsForExercise}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryLight,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Exercise Details with subtle styling
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryLight.withOpacity(0.15),
                        AppColors.primaryLight.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    progression.execution.toDisplayString(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          letterSpacing: 0.3,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (progression.load != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.scale,
                          color: AppColors.primaryLight,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            progression.load!.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.onSurfaceLight,
                                  fontWeight: FontWeight.w600,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                // Action button with mellower styling
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (progression.execution.isDurationBased) {
                        final duration = progression.execution.durationSeconds ??
                            progression.execution.minSeconds ??
                            30;
                        _startCountdownAndExercise(duration);
                      } else {
                        _moveToNextStep();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: AppColors.secondaryLight.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          progression.execution.isDurationBased ? Icons.play_arrow_rounded : Icons.check_circle_outline,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          progression.execution.isDurationBased ? 'START EXERCISE' : 'COMPLETE SET',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
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

  Widget _buildPhaseHeader(WorkoutBlock block) {
    String phaseText = '';
    String phaseTitle = '';
    
    switch (_progressState.currentPhase) {
      case WorkoutPhase.warmup:
        phaseTitle = 'WARM-UP';
        phaseText = 'Exercise ${_progressState.currentExerciseIndexInBlock + 1}/${_progressState.totalExercisesInBlock}';
        break;
      case WorkoutPhase.mainWorkout:
        // STANDARD SETS: Show exercise progress, not rounds
        phaseTitle = 'MAIN WORKOUT';
        phaseText = '${block.title} • Exercise ${_progressState.currentExerciseIndexInBlock + 1}/${_progressState.totalExercisesInBlock}';
        break;
      case WorkoutPhase.cooldown:
        phaseTitle = 'COOL-DOWN';
        phaseText = 'Exercise ${_progressState.currentExerciseIndexInBlock + 1}/${_progressState.totalExercisesInBlock}';
        break;
      default:
        phaseTitle = block.title.toUpperCase();
        phaseText = '';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight,
            AppColors.primaryLight.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phaseTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.fitness_center,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  phaseText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
              const SizedBox(height: 60),
              SizedBox(
                width: 220,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Skip countdown and start exercise immediately
                    setState(() {
                      _isCountingDown = false;
                      final progression = _getCurrentProgression();
                      if (progression != null) {
                        _exerciseSecondsRemaining = progression.execution.durationSeconds ??
                            progression.execution.minSeconds ??
                            30;
                      }
                    });
                    _startExerciseTimer();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: const Text(
                    'START NOW',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseTimerScreen(Exercise exercise, Progression progression) {
    final totalSeconds = progression.execution.durationSeconds ??
        progression.execution.minSeconds ??
        30;
    final percent = _exerciseSecondsRemaining / totalSeconds;

    return Column(
      children: [
        _buildPhaseHeader(_getCurrentBlock()!),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                exercise.name,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Center(
                child: CircularPercentIndicator(
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
              ),
              const Spacer(),
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
                  child: const Text(
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
    );
  }

  Widget _buildRestScreen() {
    final percent = _restSecondsRemaining / 60.0;
    final exercise = _getCurrentExercise();
    final isLastSet = _progressState.currentSet >= _progressState.totalSetsForExercise;

    // Determine what's coming up next
    String upNextText = '';
    if (!isLastSet) {
      upNextText = 'Set ${_progressState.currentSet + 1} of ${exercise?.name ?? ''}';
    } else {
      // Check if there's a next exercise
      final block = _getCurrentBlock();
      if (block != null && _progressState.currentExerciseIndexInBlock + 1 < block.exercises.length) {
        final nextExercise = block.exercises[_progressState.currentExerciseIndexInBlock + 1];
        final nextProgression = _getProgressionForExercise(nextExercise);
        upNextText = '${nextExercise.name} (${nextProgression?.sets ?? 1} sets)';
      } else {
        // Check if there's a next component
        final nextComponentIndex = _progressState.currentComponentIndex + 1;
        if (nextComponentIndex < _currentSession!.components.length) {
          final nextComponent = _currentSession!.components[nextComponentIndex];
          final nextBlock = _program!.workoutLibrary[nextComponent.blockId];
          upNextText = nextBlock?.title ?? 'Next Phase';
        } else {
          upNextText = 'Workout Complete!';
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withOpacity(0.08),
            AppColors.backgroundLight,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Exercise and Set Info with cohesive design
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: AppColors.primaryLight,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise?.name ?? '',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryLight,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.primaryLight.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  'SET ${_progressState.currentSet}/${_progressState.totalSetsForExercise} ✓',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryLight,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (upNextText.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primaryLight.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'UP NEXT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryLight,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                upNextText,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurfaceLight,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: AppColors.primaryLight,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.self_improvement,
                      color: AppColors.primaryLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'RECOVERY TIME',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              CircularPercentIndicator(
                radius: 125.0,
                lineWidth: 14.0,
                percent: percent.clamp(0.0, 1.0),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_restSecondsRemaining',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 68,
                            color: AppColors.primaryLight,
                          ),
                    ),
                    Text(
                      'seconds',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: AppColors.primaryLight.withOpacity(0.15),
                progressColor: AppColors.secondaryLight,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '💧 Take deep breaths and stay hydrated',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.home, size: 20),
                        label: Text(
                          'HOME',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryLight,
                          side: BorderSide(
                            color: AppColors.primaryLight.withOpacity(0.5),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _skipRest,
                        icon: Icon(Icons.skip_next, size: 22),
                        label: Text(
                          'SKIP REST',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryLight,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: AppColors.secondaryLight.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinishedScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryLight.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
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
              'Great job! You\'ve completed today\'s workout.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
      ),
    );
  }
}
