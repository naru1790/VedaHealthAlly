import 'dart:convert';

class DailyRoutinePlan {
  final String programId;
  final String programTitle;
  final int programDurationDays;
  final List<String> programGoals;
  final DailySchedule dailySchedule;
  final List<WeeklyOverride> weeklyOverrides;
  final MealLibrary mealLibrary;

  DailyRoutinePlan({
    required this.programId,
    required this.programTitle,
    required this.programDurationDays,
    required this.programGoals,
    required this.dailySchedule,
    required this.weeklyOverrides,
    required this.mealLibrary,
  });

  factory DailyRoutinePlan.fromJson(Map<String, dynamic> json) {
    return DailyRoutinePlan(
      programId: json['programId'] as String,
      programTitle: json['programTitle'] as String,
      programDurationDays: json['programDurationDays'] as int,
      programGoals: (json['programGoals'] as List).cast<String>(),
      dailySchedule: DailySchedule.fromJson(json['dailySchedule']),
      weeklyOverrides: (json['weeklyOverrides'] as List)
          .map((e) => WeeklyOverride.fromJson(e))
          .toList(),
      mealLibrary: MealLibrary.fromJson(json['mealLibrary']),
    );
  }

  static DailyRoutinePlan fromJsonString(String jsonString) {
    return DailyRoutinePlan.fromJson(jsonDecode(jsonString));
  }
}

class DailySchedule {
  final ScheduleTemplates scheduleTemplates;

  DailySchedule({required this.scheduleTemplates});

  factory DailySchedule.fromJson(Map<String, dynamic> json) {
    return DailySchedule(
      scheduleTemplates: ScheduleTemplates.fromJson(json['scheduleTemplates']),
    );
  }
}

class ScheduleTemplates {
  final ScheduleTemplate defaultTemplate;

  ScheduleTemplates({required this.defaultTemplate});

  factory ScheduleTemplates.fromJson(Map<String, dynamic> json) {
    return ScheduleTemplates(
      defaultTemplate: ScheduleTemplate.fromJson(json['default']),
    );
  }
}

class ScheduleTemplate {
  final String templateName;
  final List<TimelineEvent> timelineEvents;

  ScheduleTemplate({
    required this.templateName,
    required this.timelineEvents,
  });

  factory ScheduleTemplate.fromJson(Map<String, dynamic> json) {
    return ScheduleTemplate(
      templateName: json['templateName'] as String,
      timelineEvents: (json['timelineEvents'] as List)
          .map((e) => TimelineEvent.fromJson(e))
          .toList(),
    );
  }
}

class TimelineEvent {
  final String eventId;
  final String startTime;
  final String? endTime;
  final String title;
  final String eventType;
  final String? description;
  final List<String>? tasks;
  final String? mealReferenceId;
  final String? workoutReferenceId;

  TimelineEvent({
    required this.eventId,
    required this.startTime,
    this.endTime,
    required this.title,
    required this.eventType,
    this.description,
    this.tasks,
    this.mealReferenceId,
    this.workoutReferenceId,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      eventId: json['eventId'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String?,
      title: json['title'] as String,
      eventType: json['eventType'] as String,
      description: json['description'] as String?,
      tasks: json['tasks'] != null ? (json['tasks'] as List).cast<String>() : null,
      mealReferenceId: json['mealReferenceId'] as String?,
      workoutReferenceId: json['workoutReferenceId'] as String?,
    );
  }
}

class WeeklyOverride {
  final String dayOfWeek;
  final String eventIdToOverride;
  final TimelineEvent newEvent;

  WeeklyOverride({
    required this.dayOfWeek,
    required this.eventIdToOverride,
    required this.newEvent,
  });

  factory WeeklyOverride.fromJson(Map<String, dynamic> json) {
    return WeeklyOverride(
      dayOfWeek: json['dayOfWeek'] as String,
      eventIdToOverride: json['eventIdToOverride'] as String,
      newEvent: TimelineEvent.fromJson(json['newEvent']),
    );
  }
}

class MealLibrary {
  final MealCategory breakfastMealOptions;
  final MealCategory lunchOptions;
  final MealCategory snackOptions;
  final MealCategory dinnerOptions;

  MealLibrary({
    required this.breakfastMealOptions,
    required this.lunchOptions,
    required this.snackOptions,
    required this.dinnerOptions,
  });

  factory MealLibrary.fromJson(Map<String, dynamic> json) {
    return MealLibrary(
      breakfastMealOptions: MealCategory.fromJson(json['breakfastMealOptions']),
      lunchOptions: MealCategory.fromJson(json['lunchOptions']),
      snackOptions: MealCategory.fromJson(json['snackOptions']),
      dinnerOptions: MealCategory.fromJson(json['dinnerOptions']),
    );
  }

  MealCategory? getCategoryByReferenceId(String referenceId) {
    switch (referenceId) {
      case 'breakfastMealOptions':
        return breakfastMealOptions;
      case 'lunchOptions':
        return lunchOptions;
      case 'snackOptions':
        return snackOptions;
      case 'dinnerOptions':
        return dinnerOptions;
      default:
        return null;
    }
  }
}

class MealCategory {
  final String title;
  final List<MealOption>? options;
  final List<String>? formula;

  MealCategory({
    required this.title,
    this.options,
    this.formula,
  });

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      title: json['title'] as String,
      options: json['options'] != null
          ? (json['options'] as List).map((e) => MealOption.fromJson(e)).toList()
          : null,
      formula: json['formula'] != null
          ? (json['formula'] as List).cast<String>()
          : null,
    );
  }
}

class MealOption {
  final String name;
  final String description;
  final List<String>? tags;

  MealOption({
    required this.name,
    required this.description,
    this.tags,
  });

  factory MealOption.fromJson(Map<String, dynamic> json) {
    return MealOption(
      name: json['name'] as String,
      description: json['description'] as String,
      tags: json['tags'] != null ? (json['tags'] as List).cast<String>() : null,
    );
  }
}
