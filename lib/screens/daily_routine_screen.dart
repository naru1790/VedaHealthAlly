import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../models/daily_routine_models.dart';
import '../services/notification_service.dart';
import '../core/theme/app_colors.dart';

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
      // Load JSON from assets
      final String jsonString = await rootBundle.loadString('bdata/DailyRoutine.json');
      routinePlan = DailyRoutinePlan.fromJsonString(jsonString);
      
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
      
      // Check if notifications have already been scheduled today
      await _scheduleNotificationsIfNeeded();
      
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
    
    // Show as current if we're within 60 minutes before the event start time
    final minBound = eventMinutes - 60;
    
    // If event has an end time, check if we're currently in it or approaching it
    if (event.endTime != null) {
      final endTimeParts = event.endTime!.split(':');
      final endMinutes = int.parse(endTimeParts[0]) * 60 + int.parse(endTimeParts[1]);
      // Show from 60 min before start to end time
      if (currentMinutes >= minBound && currentMinutes <= endMinutes) {
        return true;
      }
    } else {
      // For events without end time, show from 60 min before to 30 min after
      final maxBound = eventMinutes + 30;
      if (currentMinutes >= minBound && currentMinutes <= maxBound) {
        return true;
      }
    }
    
    return false;
  }

  String _getEventStatusLabel(TimelineEvent event) {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    final timeParts = event.startTime.split(':');
    final eventMinutes = int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);
    
    // If event has started or is happening now
    if (currentMinutes >= eventMinutes) {
      // Check if still ongoing (if has end time)
      if (event.endTime != null) {
        final endTimeParts = event.endTime!.split(':');
        final endMinutes = int.parse(endTimeParts[0]) * 60 + int.parse(endTimeParts[1]);
        if (currentMinutes <= endMinutes) {
          return 'NOW';
        }
      } else if (currentMinutes <= eventMinutes + 30) {
        return 'NOW';
      }
    }
    
    // Event is upcoming
    return 'UPCOMING';
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

  Future<void> _scheduleNotificationsIfNeeded() async {
    // Always reschedule notifications to ensure they work
    // Cancel all existing notifications first
    await _notificationService.cancelAll();
    
    // Schedule fresh notifications
    await _scheduleAllNotifications();
    
    // Show confirmation to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Daily notifications scheduled successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
          // Test notification button
          IconButton(
            icon: Icon(
              Icons.notifications_active,
              color: AppColors.primaryLight,
            ),
            tooltip: 'Test Notifications',
            onPressed: () async {
              try {
                // Check if notifications are enabled
                final enabled = await _notificationService.areNotificationsEnabled();
                
                if (!enabled) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Notifications are disabled! Please enable them in Settings.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 4),
                      ),
                    );
                  }
                  return;
                }
                
                // Show test notification
                await _notificationService.showTestNotification();
                
                // Get pending notifications count
                final pending = await _notificationService.getPendingNotifications();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✅ Test notification sent!'),
                          const SizedBox(height: 4),
                          Text('${pending.length} notifications scheduled'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
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
                                      Text(
                                        _getEventStatusLabel(event),
                                        style: const TextStyle(
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
