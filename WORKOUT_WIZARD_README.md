# Workout Wizard POC

A complete, single-file Flutter Proof-of-Concept app that guides users step-by-step through a pre-defined workout.

## Overview

The Workout Wizard is a UI-only POC with NO database, NO auth, and NO live AI. All data comes from a hard-coded JSON string embedded in the code.

## File Location

**Main POC File**: `lib/workout_wizard_poc.dart`

This is a complete, standalone Flutter application in a single file (~1000+ lines).

## Features

### 1. **Smart Workout Flattening**
- Takes complex, nested JSON workout structure
- "Flattens" it into a simple linear sequence of steps
- Automatically "unrolls" sets (e.g., 3 sets of squats → 6 steps: exercise, rest, exercise, rest, exercise, rest)
- Handles progression-based workouts (chooses correct week's parameters)

### 2. **Step Types**

#### Summary Steps
- Shows workout overview
- Displays block titles (Warm-up, Strength, Core, Cool-down)
- "Start Workout" / "Continue" buttons

#### Exercise Steps
- Displays Lottie animation (or fallback icon)
- Shows exercise name in large font
- Shows execution details (e.g., "10-12 REPS", "30-45s", "AMRAP")
- Displays set information (e.g., "SET 2 OF 3")
- Shows load description (e.g., "Hold one 5kg dumbbell")
- "DONE • START REST" button

#### Rest Steps
- Large circular progress indicator
- Real-time countdown timer
- Shows remaining seconds in large font
- Auto-advances when timer hits 0
- Plays alarm sound (if asset exists)
- "SKIP REST" button for immediate advancement

#### Finished Step
- Celebration icon
- "Workout Complete!" message
- "FINISH" button to exit

### 3. **Progress Tracking**
- Linear progress bar in AppBar
- Step counter (e.g., "15/47")
- Visual feedback throughout workout

### 4. **Dependencies**

All dependencies are installed in `pubspec.yaml`:
- `lottie: ^3.1.2` - For exercise animations
- `percent_indicator: ^4.2.5` - For rest timer circular UI
- `audioplayers: ^6.0.0` - For rest timer alarm

## How to Run

### Option 1: Standalone App

Run the Workout Wizard POC as a standalone app:

```bash
flutter run -t lib/workout_wizard_poc.dart
```

### Option 2: Add to Existing App

You can also add a button in your existing app to navigate to the Workout Wizard:

```dart
import 'package:veda_ai/workout_wizard_poc.dart';

// In your widget:
FilledButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WorkoutWizardHomeScreen(),
      ),
    );
  },
  child: const Text('Workout Wizard POC'),
)
```

## Data Structure

### Hard-Coded JSON
The workout data is embedded as a const String at the top of the file. It includes:

- **Program Info**: Title, goals, duration, notes
- **Weekly Schedule**: Day-by-day session planning
- **Workout Library**: Reusable workout blocks (warm-up, strength, core, cool-down)
- **Exercises**: With progressions based on week ranges
- **Execution Types**: REPS, REP_RANGE, DURATION, DURATION_RANGE, AMRAP

### Data Models

The app includes complete Dart classes to parse the JSON:
- `WorkoutProgram`
- `DaySchedule`, `Session`, `Component`
- `WorkoutBlock`, `Exercise`
- `Progression`, `Execution`, `WeekRange`, `Load`, `Rest`

## Workout Flattener Logic

The core brain of the wizard is the `flattenWorkout()` function:

```dart
List<WorkoutStep> flattenWorkout(
  WorkoutProgram program,
  String dayOfWeek,
  int currentWeek,
)
```

**What it does:**
1. Finds the correct day's session (e.g., "Monday")
2. Adds a summary step
3. Iterates through components (Warm-up, Strength, Core, Cool-down)
4. For each workout block:
   - Adds a block title summary
   - Processes each round
   - For each exercise:
     - Finds the correct progression for the current week
     - **Unrolls sets**: If 3 sets → creates 6 steps (exercise + rest for each set)
5. Adds a finished step

## Assets

### Lottie Animations

**Location**: `assets/lottie/`

The app includes placeholder Lottie files:
- `squat.json` - Blue rectangle (placeholder)
- `pushup.json` - Red rectangle (placeholder)
- `plank.json` - Green rectangle (placeholder)
- `default.json` - Gray circle (fallback)

**For production**, replace with proper animations from:
- LottieFiles: https://lottiefiles.com/
- Search for: "exercise", "workout", "fitness"

### Alarm Sound

**Location**: `assets/sounds/alarm.mp3`

**Status**: Not included (optional)

The app handles the missing file gracefully. To add:
1. Download a short alarm sound (1-2 seconds)
2. Save as `alarm.mp3` in `assets/sounds/`
3. Rebuild the app

**Free sources**:
- Pixabay: https://pixabay.com/sound-effects/
- Freesound: https://freesound.org/

## Testing the POC

### Current Setup
- **Day**: Monday
- **Week**: 1
- **Session**: "Full Body Strength A + Core A (Foundation)"

### Expected Flow
1. **Summary**: Workout title and duration
2. **Warm-up Summary**: "Strength Warm-Up, 1 round"
3. **Warm-up Exercises**: Arm Circles (60s) → Rest (30s) → Torso Twists (45s) → Rest → High Knees → Rest → Squats
4. **Strength A Summary**: "Full Body Strength A, 3 rounds"
5. **Strength Exercises**: Goblet Squats (Set 1) → Rest (60s) → Set 2 → Rest → Set 3 → Rest → Push-ups (Set 1) → Rest → ...
6. **Core A Summary**: "Core A, 3 rounds"
7. **Core Exercises**: Plank (Set 1) → Rest (45s) → ...
8. **Cool-down Summary**: "General Cool-Down, 1 round"
9. **Cool-down Exercises**: Stretches
10. **Finished**: Celebration screen

### Total Steps
Approximately **40-50 steps** depending on the workout structure.

## Code Architecture

### 1. **Data Layer** (Lines 1-450)
- Hard-coded JSON string
- Complete Dart data models
- JSON parsing logic

### 2. **Domain Layer** (Lines 451-580)
- `WorkoutStep` enum and class
- `flattenWorkout()` function (the core algorithm)
- Exercise-to-Lottie mapping

### 3. **UI Layer** (Lines 581-1050)
- `WorkoutWizardScreen` (StatefulWidget)
- Step state management
- Timer logic
- Audio player integration
- Four step UI builders:
  - `_buildSummaryStep()`
  - `_buildExerciseStep()`
  - `_buildRestStep()`
  - `_buildFinishedStep()`

### 4. **Entry Point** (Lines 1051-1100)
- `WorkoutWizardHomeScreen`
- Material App wrapper
- Navigation setup

## Customization

### Change the Workout
Edit the `workoutJsonString` constant at the top of the file. The JSON structure supports:
- Multiple days of the week
- Multiple sessions per day
- Custom blocks and exercises
- Week-based progressions

### Change the Day/Week
In the `_loadWorkout()` method:

```dart
final flattenedWorkout = flattenWorkout(program, 'Monday', 1);
```

Change `'Monday'` to any day or `1` to any week (1-12).

### Add More Lottie Animations
Update the `_getLottieAsset()` function:

```dart
final assetMap = {
  'ex_goblet_squat': 'assets/lottie/squat.json',
  'ex_pushups': 'assets/lottie/pushup.json',
  // Add more mappings here
};
```

### Customize Rest Durations
Rest durations come from the JSON:

```json
"rest": { "type": "DURATION", "durationSeconds": 60 }
```

Change `60` to any number of seconds.

## Known Limitations (POC)

1. **No persistence**: Workout progress is lost if app is closed
2. **No real animations**: Placeholder Lottie files only
3. **No alarm sound**: Optional, not included
4. **Single workout**: Hard-coded to Monday, Week 1
5. **No workout history**: No tracking of completed workouts
6. **No customization UI**: All changes require code edits

## Future Enhancements (Post-POC)

- Firebase integration for workout storage
- User authentication
- Workout history and statistics
- Custom workout builder UI
- Real exercise animations
- Video demonstrations
- Form check AI (using camera)
- Social features (share workouts)
- Wearable device integration
- Voice commands

## License

This is a POC for demonstration purposes.

## Contact

For questions about the Workout Wizard POC, refer to the code comments and this README.
