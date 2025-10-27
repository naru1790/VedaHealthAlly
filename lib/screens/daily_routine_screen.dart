import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/daily_routine_models.dart';
import '../services/notification_service.dart';
import '../core/theme/app_colors.dart';

const String dailyRoutineJson = '''
{
  "programId": "plan_phase1_gold_001",
  "programTitle": "Phase 1 (Gold): Accelerated Recovery Nutrition Plan",
  "programDurationDays": 28,
  "programGoals": [
    "Dramatically reduce Triglycerides (240.4) and LDL Cholesterol (194.12).",
    "Allow liver to heal (reduce GGT 185.6 and ALT 60.7).",
    "Reduce 41-inch waist size by targeting visceral (belly) fat.",
    "Correct B12 (106) and Vit D (10.7) deficiencies.",
    "Improve gut health and nutrient absorption."
  ],
  "dailySchedule": {
    "scheduleTemplates": {
      "default": {
        "templateName": "Default Weekday",
        "timelineEvents": [
          {
            "eventId": "evt_wake",
            "startTime": "06:00",
            "title": "Wake, Hydrate & Supplement",
            "eventType": "HABIT",
            "tasks": [
              "Drink 500-750ml of water immediately.",
              "Take your Vitamin B12 supplement (on an empty stomach)."
            ]
          },
          {
            "eventId": "evt_workout",
            "startTime": "06:30",
            "endTime": "07:30",
            "title": "Daily Workout",
            "eventType": "WORKOUT",
            "description": "Perform your 60-minute workout session as scheduled in your workout plan.",
            "workoutReferenceId": "phase1_daily_workout"
          },
          {
            "eventId": "evt_breakfast",
            "startTime": "07:45",
            "title": "Breakfast: Your Super-Meal",
            "eventType": "MEAL",
            "description": "This is your most important meal for recovery and cholesterol. Choose one option.",
            "mealReferenceId": "breakfastMealOptions"
          },
          {
            "eventId": "evt_hydration_1",
            "startTime": "10:30",
            "title": "Hydration Check",
            "eventType": "HYDRATION",
            "tasks": [
              "Drink 500ml water."
            ]
          },
          {
            "eventId": "evt_lunch",
            "startTime": "13:00",
            "endTime": "14:00",
            "title": "Lunch",
            "eventType": "MEAL",
            "description": "This is your main carb meal. Follow the 'Lunch Formula'.",
            "mealReferenceId": "lunchOptions"
          },
          {
            "eventId": "evt_hydration_2",
            "startTime": "16:00",
            "title": "Hydration Check",
            "eventType": "HYDRATION",
            "tasks": [
              "Drink 500ml water."
            ]
          },
          {
            "eventId": "evt_snack",
            "startTime": "16:30",
            "endTime": "17:00",
            "title": "Crucial Snack",
            "eventType": "MEAL",
            "description": "This is the 'bridge' that stops you from being starving at dinner. It is mandatory. Choose one option.",
            "mealReferenceId": "snackOptions"
          },
          {
            "eventId": "evt_habit_swap",
            "startTime": "18:00",
            "title": "Habit Swap",
            "eventType": "HABIT",
            "description": "Swap your evening milk tea for Green Tea or a Black Coffee (no sugar). Milk/sugar will make you hungrier right before dinner."
          },
          {
            "eventId": "evt_dinner",
            "startTime": "20:00",
            "endTime": "20:30",
            "title": "Dinner (Carb Curfew) & Supplement",
            "eventType": "MEAL",
            "description": "This is your most important meal for fat loss. Follow the rule: NO RICE, NO ROTI. Your meal is 'Protein + Vegetables'.",
            "tasks": [
              "Take your Omega-3 (Fish Oil) capsule *with* this meal."
            ],
            "mealReferenceId": "dinnerOptions"
          },
          {
            "eventId": "evt_wind_down",
            "startTime": "22:00",
            "title": "Wind-Down Routine",
            "eventType": "HABIT",
            "description": "This replaces your 10 PM rice. It helps you manage stress (smoking trigger) and helps your cholesterol.",
            "tasks": [
              "Take 1 tbsp Psyllium Husk (Ispaghol) in a full glass of water.",
              "NO phone/TV for 15 minutes. Read a book, listen to music, or do light stretches. This will help you sleep."
            ]
          },
          {
            "eventId": "evt_sleep",
            "startTime": "22:30",
            "title": "Sleep",
            "eventType": "SLEEP",
            "tasks": [
              "Lights out. Aim for 7-8 hours of quality sleep."
            ]
          }
        ]
      }
    }
  },
  "weeklyOverrides": [
    {
      "dayOfWeek": "Sunday",
      "eventIdToOverride": "evt_breakfast",
      "newEvent": {
        "eventId": "evt_breakfast_sun",
        "startTime": "07:45",
        "title": "Breakfast: Super-Meal & Vitamin D",
        "eventType": "MEAL",
        "description": "Today is your Vitamin D day. You MUST take it with your breakfast, as it needs fat (from nuts, eggs, etc.) for absorption.",
        "tasks": [
          "Take your Vitamin D 60,000 IU sachet WITH this meal."
        ],
        "mealReferenceId": "breakfastMealOptions"
      }
    }
  ],
  "mealLibrary": {
    "breakfastMealOptions": {
      "title": "Breakfast 'Super-Meal' Options (Choose 1)",
      "options": [
        {
          "name": "Savory Protein Plate",
          "description": "4 Boiled Egg Whites + 1 Whole Yolk. Side of 1 Apple. Plus a small handful (20g) of 'Mixed Nuts' (Almonds, Walnuts, Kaju).",
          "tags": ["High Protein", "Low Carb"]
        },
        {
          "name": "Cholesterol-Fighter Bowl (Oats)",
          "description": "1 bowl Oats (cooked in water or milk) + 1 tbsp ground Flaxseed + 1 chopped Anjeer (Fig) + 5 Almonds + 5 Kaju (Cashews) + 1/2 cup Pomegranate/Berries.",
          "tags": ["High Fiber", "Heart Healthy"]
        },
        {
          "name": "Probiotic Power Bowl",
          "description": "1 large bowl Curd (Dahi) + 1 scoop Whey Protein (optional, but good) + 1 tbsp ground Flaxseed + 1 cup mixed seasonal Fruit (Apple, Pomegranate, Papaya).",
          "tags": ["High Protein", "Gut Health"]
        },
        {
          "name": "Easy Protein Salad",
          "description": "1 bowl Sprouts Salad + 150g Paneer (cubed, raw or sautéed) + 10 Almonds + 10 Walnuts.",
          "tags": ["High Protein", "Veg"]
        }
      ]
    },
    "lunchOptions": {
      "title": "Lunch Formula (Protein + Veg + Fiber + Carb)",
      "formula": [
        "1 Large katori Protein (Dal, Chickpeas, Rajma, 150g Chicken, 150g Paneer).",
        "1 katori Sabji (any home-cooked vegetable, try to include greens).",
        "1 small katori Rice (Control this portion!).",
        "1 side of Curd (Dahi) or 1/2 cup Easy Raw Veg (Cucumber, Tomato, Onion)."
      ]
    },
    "snackOptions": {
      "title": "Crucial Snack Options (Choose 1)",
      "options": [
        {
          "name": "Probiotic Snack",
          "description": "1 glass Buttermilk (chaas) + 1 tbsp ground Flaxseed.",
          "tags": ["Quick", "Gut Health"]
        },
        {
          "name": "Simple & Savory",
          "description": "1 large handful (about 1 cup) of Roasted Chana.",
          "tags": ["Quick", "High Fiber"]
        },
        {
          "name":"Fruit & Fat",
          "description": "1 Apple + 10-15 Almonds.",
          "tags": ["Quick", "Heart Healthy"]
        },
        {
          "name": "Antioxidant Snack",
          "description": "1 cup Pomegranate + 10 Walnuts.",
          "tags": ["Quick", "Heart Healthy"]
        },
        {
          "name": "Quick Energy",
          "description": "2-3 Dates + 10 Almonds.",
          "tags": ["Quick", "Energy"]
        }
      ]
    },
    "dinnerOptions": {
      "title": "Dinner Options (Protein + Veg. NO RICE/ROTI/BIRYANI)",
      "options": [
        {
          "name": "Home: Paneer Dinner",
          "description": "200g Paneer (sautéed/Tikka style) + 1 large bowl Sabji.",
          "tags": ["Home", "Veg", "High Protein"]
        },
        {
          "name": "Home: Soup Dinner",
          "description": "Large bowl of Dal Soup or Chicken Soup (with 150g chicken pieces) + 1 bowl Sautéed Vegetables.",
          "tags": ["Home", "Light"]
        },
        {
          "name": "Home: Chicken Dinner",
          "description": "150g home-cooked Chicken + 1 large bowl Sabji.",
          "tags": ["Home", "High Protein"]
        },
        {
          "name": "Ordering Out: Tandoori",
          "description": "Tandoori Chicken (4-5 pieces) + 1 side of Green Salad (No Naan/Roti).",
          "tags": ["External", "High Protein"]
        },
        {
          "name": "Ordering Out: Tikka",
          "description": "Paneer Tikka (1 plate) + Mint Chutney (No Naan/Roti).",
          "tags": ["External", "Veg", "High Protein"]
        }
      ]
    }
  }
}
''';

class DailyRoutineScreen extends StatefulWidget {
  const DailyRoutineScreen({super.key});

  @override
  State<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends State<DailyRoutineScreen> {
  late DailyRoutinePlan routinePlan;
  bool isLoading = true;
  final NotificationService _notificationService = NotificationService();
  List<TimelineEvent> todayEvents = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      routinePlan = DailyRoutinePlan.fromJsonString(dailyRoutineJson);
      
      // Get today's day of week
      final now = DateTime.now();
      final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final todayName = daysOfWeek[now.weekday - 1]; // weekday is 1-7, Monday is 1
      
      // Start with default template events
      todayEvents = List.from(routinePlan.dailySchedule.scheduleTemplates.defaultTemplate.timelineEvents);
      
      // Apply today's overrides if any
      final todayOverrides = routinePlan.weeklyOverrides
          .where((override) => override.dayOfWeek == todayName)
          .toList();
      
      for (final override in todayOverrides) {
        final index = todayEvents.indexWhere((e) => e.eventId == override.eventIdToOverride);
        if (index != -1) {
          todayEvents[index] = override.newEvent;
        }
      }
      
      await _scheduleAllNotifications();
      setState(() {
        isLoading = false;
      });
      
      // Scroll to current/next event after a short delay to ensure list is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentEvent();
      });
    } catch (e) {
      debugPrint('Error loading daily routine data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  int _findCurrentOrNextEventIndex() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    for (int i = 0; i < todayEvents.length; i++) {
      final event = todayEvents[i];
      final timeParts = event.startTime.split(':');
      final eventMinutes = int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);
      
      // If event is in the future, return it
      if (eventMinutes > currentMinutes) {
        return i;
      }
      
      // If event has an end time, check if we're currently in it
      if (event.endTime != null) {
        final endTimeParts = event.endTime!.split(':');
        final endMinutes = int.parse(endTimeParts[0]) * 60 + int.parse(endTimeParts[1]);
        if (currentMinutes >= eventMinutes && currentMinutes <= endMinutes) {
          return i;
        }
      }
    }
    
    // If all events are in the past, return the last one
    return todayEvents.length - 1;
  }

  bool _isEventCurrent(TimelineEvent event) {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    final timeParts = event.startTime.split(':');
    final eventMinutes = int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);
    
    // Check if we're within 15 minutes before or after the event start time
    if ((currentMinutes >= eventMinutes - 15) && (currentMinutes <= eventMinutes + 15)) {
      return true;
    }
    
    // If event has an end time, check if we're currently in it
    if (event.endTime != null) {
      final endTimeParts = event.endTime!.split(':');
      final endMinutes = int.parse(endTimeParts[0]) * 60 + int.parse(endTimeParts[1]);
      if (currentMinutes >= eventMinutes && currentMinutes <= endMinutes) {
        return true;
      }
    }
    
    return false;
  }

  void _scrollToCurrentEvent() {
    if (todayEvents.isEmpty || !_scrollController.hasClients) return;
    
    final currentIndex = _findCurrentOrNextEventIndex();
    
    // Each item height is approximately 150 pixels (card + timeline)
    final double itemHeight = 150.0;
    final double targetPosition = currentIndex * itemHeight;
    
    // Scroll with animation
    _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _scheduleAllNotifications() async {
    // Schedule wake-up alarm for the wake event
    final wakeEvent = todayEvents.firstWhere((e) => e.eventId == 'evt_wake' || e.eventId.startsWith('evt_wake'));
    final wakeTimeParts = wakeEvent.startTime.split(':');
    final wakeHour = int.parse(wakeTimeParts[0]);
    final wakeMinute = int.parse(wakeTimeParts[1]);
    
    // Schedule wake-up alarm with gentle sound
    await _notificationService.scheduleWakeUpAlarm(
      id: 8888,
      title: '⏰ Wake Up Time!',
      body: 'Time to start your healthy day! Hydrate and take your B12 supplement.',
      hour: wakeHour,
      minute: wakeMinute,
    );
    
    // Add 10 minutes for morning routine reminder
    var morningMinute = wakeMinute + 10;
    var morningHour = wakeHour;
    if (morningMinute >= 60) {
      morningHour++;
      morningMinute -= 60;
    }
    
    await _notificationService.scheduleDailyNotification(
      id: 9999,
      title: 'Good Morning!',
      body: 'Time to check your daily routine!',
      hour: morningHour,
      minute: morningMinute,
    );

    // Schedule notifications for each event
    for (int i = 0; i < todayEvents.length; i++) {
      final event = todayEvents[i];
      final timeParts = event.startTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      String body = event.description ?? '';
      if (body.isEmpty && event.tasks != null && event.tasks!.isNotEmpty) {
        body = event.tasks!.first;
      }

      await _notificationService.scheduleDailyNotification(
        id: i,
        title: event.title,
        body: body,
        hour: hour,
        minute: minute,
      );
    }
  }

  Future<void> _cancelAllNotifications() async {
    await _notificationService.cancelAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications cancelled'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _getCurrentDayName() {
    final now = DateTime.now();
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return daysOfWeek[now.weekday - 1];
  }

  void _showEventDetails(TimelineEvent event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Image for all events
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _getEventImageUrl(event.eventId, event.eventType),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: _getEventColor(event.eventType).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getEventColor(event.eventType),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getEventColor(event.eventType).withOpacity(0.3),
                              _getEventColor(event.eventType).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getEventIcon(event.eventType),
                          size: 80,
                          color: _getEventColor(event.eventType),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Event title and time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getEventColor(event.eventType).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getEventIcon(event.eventType),
                          color: _getEventColor(event.eventType),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.startTime,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _getEventColor(event.eventType),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  if (event.description != null && event.description!.isNotEmpty) ...[
                    Text(
                      event.description!,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Tasks
                  if (event.tasks != null && event.tasks!.isNotEmpty) ...[
                    Text(
                      'Tasks:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...event.tasks!.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getEventColor(event.eventType),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              task,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 20),
                  ],

                  // Meal options
                  if (event.mealReferenceId != null) ...[
                    _buildMealOptions(event.mealReferenceId!, isDark),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealOptions(String mealReferenceId, bool isDark) {
    final mealCategory = routinePlan.mealLibrary.getCategoryByReferenceId(mealReferenceId);
    if (mealCategory == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mealCategory.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        
        // Options
        if (mealCategory.options != null)
          ...mealCategory.options!.map((option) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF059669).withOpacity(0.08)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark 
                    ? const Color(0xFF059669).withOpacity(0.3)
                    : const Color(0xFFBBF7D0),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image for each meal option
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    _getMealOptionImageUrl(option.name),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withOpacity(0.1),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF059669).withOpacity(0.3),
                            const Color(0xFF059669).withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        size: 60,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ),
                          if (option.tags != null)
                            Wrap(
                              spacing: 6,
                              children: option.tags!.map((tag) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              )).toList(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        option.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        
        // Formula
        if (mealCategory.formula != null)
          ...mealCategory.formula!.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '•  ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          )),
      ],
    );
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'MEAL':
        return const Color(0xFF059669); // Emerald
      case 'WORKOUT':
        return const Color(0xFFEA580C); // Orange
      case 'HABIT':
        return const Color(0xFF7C3AED); // Purple
      case 'HYDRATION':
        return const Color(0xFF3B82F6); // Blue
      case 'SLEEP':
        return const Color(0xFF6366F1); // Indigo
      default:
        return const Color(0xFF64748B); // Slate
    }
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case 'MEAL':
        return Icons.restaurant_rounded;
      case 'WORKOUT':
        return Icons.fitness_center_rounded;
      case 'HABIT':
        return Icons.task_alt_rounded;
      case 'HYDRATION':
        return Icons.water_drop_rounded;
      case 'SLEEP':
        return Icons.bedtime_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  String _getEventImageUrl(String eventId, String eventType) {
    // Using Unsplash with specific search terms for consistent, high-quality images
    switch (eventId) {
      case 'evt_wake':
        return 'https://images.unsplash.com/photo-1464692805480-a69dfaafdb0d?w=800&h=600&fit=crop'; // Morning sunlight
      case 'evt_workout':
        return 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&h=600&fit=crop'; // Gym workout
      case 'evt_breakfast':
      case 'evt_breakfast_sun':
        return 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=800&h=600&fit=crop'; // Healthy breakfast with oats, eggs, fruits
      case 'evt_hydration_1':
      case 'evt_hydration_2':
        return 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=800&h=600&fit=crop'; // Water glass
      case 'evt_lunch':
        return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&h=600&fit=crop'; // Indian lunch thali
      case 'evt_snack':
        return 'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=800&h=600&fit=crop'; // Healthy snacks with fruits and nuts
      case 'evt_habit_swap':
        return 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=800&h=600&fit=crop'; // Green tea
      case 'evt_dinner':
        return 'https://images.unsplash.com/photo-1606787620819-8bdf0c44c293?w=800&h=600&fit=crop'; // Grilled chicken and vegetables
      case 'evt_wind_down':
        return 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&h=600&fit=crop'; // Reading, relaxation
      case 'evt_sleep':
        return 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=800&h=600&fit=crop'; // Peaceful bedroom
      default:
        return 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800&h=600&fit=crop'; // Default food image
    }
  }

  String _getMealOptionImageUrl(String optionName) {
    // Specific images for each meal option
    switch (optionName) {
      case 'Savory Protein Plate':
        return 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=800&h=600&fit=crop'; // Boiled eggs
      case 'Cholesterol-Fighter Bowl (Oats)':
        return 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=800&h=600&fit=crop'; // Oats bowl with fruits
      case 'Probiotic Power Bowl':
        return 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=800&h=600&fit=crop'; // Yogurt bowl
      case 'Easy Protein Salad':
        return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&h=600&fit=crop'; // Healthy salad
      case 'Probiotic Snack':
        return 'https://images.unsplash.com/photo-1623065422902-30a2d299bbe4?w=800&h=600&fit=crop'; // Buttermilk
      case 'Simple & Savory':
        return 'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=800&h=600&fit=crop'; // Roasted chana
      case 'Fruit & Fat':
        return 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=800&h=600&fit=crop'; // Apple and almonds
      case 'Antioxidant Snack':
        return 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=800&h=600&fit=crop'; // Pomegranate
      case 'Quick Energy':
        return 'https://images.unsplash.com/photo-1607177380579-d0c5b8e29e0b?w=800&h=600&fit=crop'; // Dates
      case 'Home: Paneer Dinner':
        return 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=800&h=600&fit=crop'; // Paneer tikka
      case 'Home: Soup Dinner':
        return 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=800&h=600&fit=crop'; // Soup
      case 'Home: Chicken Dinner':
        return 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=800&h=600&fit=crop'; // Chicken curry
      case 'Ordering Out: Tandoori':
        return 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=800&h=600&fit=crop'; // Tandoori chicken
      case 'Ordering Out: Tikka':
        return 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=800&h=600&fit=crop'; // Paneer tikka
      default:
        return 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800&h=600&fit=crop'; // Default healthy food
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF5F7FA),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Routine',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            Text(
              _getCurrentDayName(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_off_outlined,
              color: Color(0xFFDC2626),
            ),
            onPressed: _cancelAllNotifications,
            tooltip: 'Cancel All Notifications',
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: todayEvents.length,
        itemBuilder: (context, index) {
          final event = todayEvents[index];
          final isLast = index == todayEvents.length - 1;
          final isCurrent = _isEventCurrent(event);

          return FadeInUp(
            duration: Duration(milliseconds: 400 + (index * 50)),
            child: InkWell(
              onTap: () => _showEventDetails(event),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline
                  Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getEventColor(event.eventType),
                          shape: BoxShape.circle,
                          border: isCurrent ? Border.all(
                            color: AppColors.primaryLight,
                            width: 3,
                          ) : null,
                          boxShadow: [
                            BoxShadow(
                              color: _getEventColor(event.eventType).withOpacity(isCurrent ? 0.5 : 0.3),
                              blurRadius: isCurrent ? 12 : 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getEventIcon(event.eventType),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 80,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                _getEventColor(event.eventType).withOpacity(0.5),
                                _getEventColor(todayEvents[index + 1].eventType).withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Event card
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCurrent 
                            ? AppColors.primaryLight.withOpacity(0.05)
                            : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent 
                              ? AppColors.primaryLight.withOpacity(0.5)
                              : (isDark 
                                  ? _getEventColor(event.eventType).withOpacity(0.3)
                                  : const Color(0xFFE8ECF1)),
                          width: isCurrent ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isCurrent 
                                ? AppColors.primaryLight.withOpacity(0.15)
                                : Colors.black.withOpacity(0.04),
                            blurRadius: isCurrent ? 12 : 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getEventColor(event.eventType).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getEventColor(event.eventType).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  event.startTime,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _getEventColor(event.eventType),
                                  ),
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'NOW',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: isDark ? Colors.white38 : Colors.black26,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                          if (event.description != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              event.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
