import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../screens/health_report_screen.dart';
import '../../../screens/daily_routine_screen.dart';
import '../../../screens/workout_wizard_screen.dart';

/// Veda AI Landing Page - Modern & Exciting Design
/// Inspired by modern healthcare app designs with bold gradients and animations
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0A0E1A),
                    const Color(0xFF000000),
                  ]
                : [
                    const Color(0xFFF8FAFB),
                    const Color(0xFFFFFFFF),
                  ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Hero Section - Modern & Bold
              _buildHeroSection(size, isDark),
              
              const SizedBox(height: 60),
              
              // Feature Cards - Card Style
              _buildFeatureCards(isDark),
              
              const SizedBox(height: 60),
              
              // Stats Section
              _buildStatsSection(isDark),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(Size size, bool isDark) {
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Stack(
        children: [
          // Animated Floating Circles with Soft Gradients
          Positioned(
            top: size.height * 0.1,
            right: -50,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                final offset = math.sin(_floatingController.value * 2 * math.pi) * 20;
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primaryLight.withOpacity(0.2),
                          AppColors.primaryLight.withOpacity(0.05),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withOpacity(0.15),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: size.height * 0.15,
            left: -40,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                final offset = math.cos(_floatingController.value * 2 * math.pi) * 25;
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.secondaryLight.withOpacity(0.18),
                          AppColors.secondaryLight.withOpacity(0.05),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryLight.withOpacity(0.12),
                          blurRadius: 50,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Main Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.15),
                // Animated Logo Circle
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1 + (_pulseController.value * 0.05),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryLight,
                              AppColors.secondaryLight,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLight.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 45,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title with Gradient
              FadeInDown(
                delay: const Duration(milliseconds: 400),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppColors.primaryLight,
                      AppColors.secondaryLight,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'Veda AI',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1.5,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              FadeInDown(
                delay: const Duration(milliseconds: 600),
                child: Text(
                  'Your AI companion for a healthier, happier life',
                  style: TextStyle(
                    fontSize: 17,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Animated CTA Button
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight.withOpacity(0.3 + (_pulseController.value * 0.1)),
                            blurRadius: 20 + (_pulseController.value * 10),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _buildModernButton(
                        'Get Started Free',
                        isPrimary: true,
                        isDark: isDark,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Onboarding coming soon! 🎉'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Trust Indicators
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTrustBadge('10K+', 'Users', isDark),
                    Container(
                      width: 1,
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: isDark 
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.15),
                    ),
                    _buildTrustBadge('4.9★', 'Rating', isDark),
                  ],
                ),
              ),
            ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildModernButton(String text, {required bool isPrimary, required bool isDark, required VoidCallback onPressed}) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isPrimary 
            ? AppColors.primaryLight
            : (isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(16),
        border: !isPrimary ? Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
          width: 1,
        ) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isPrimary 
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF000000)),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCards(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 600),
            child: _buildFeatureCard(
              'AI Insights',
              'Personalized health analysis powered by advanced AI',
              Icons.auto_awesome_rounded,
              AppColors.primaryLight,
              isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HealthReportScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          FadeInRight(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 600),
            child: _buildFeatureCard(
              'Smart Workouts',
              'Custom fitness plans that adapt to your progress',
              Icons.fitness_center_rounded,
              AppColors.secondaryLight,
              isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutWizardScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 600),
            child: _buildFeatureCard(
              'Daily Routine & Nutrition',
              'Personalized daily schedule with meals, workouts & reminders',
              Icons.calendar_today_rounded,
              const Color(0xFF7C3AED),
              isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DailyRoutineScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color, bool isDark, {VoidCallback? onTap}) {
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF1A1A1A).withOpacity(0.6)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1)
              : color.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.8),
                  color,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    
    return card;
  }

  Widget _buildStatsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('10K+', 'Active Users', isDark),
                _buildStatDivider(isDark),
                _buildStatItem('4.9★', 'App Rating', isDark),
                _buildStatDivider(isDark),
                _buildStatItem('50K+', 'Workouts', isDark),
              ],
            ),
          ),
          const SizedBox(height: 48),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                      ? [
                          AppColors.primaryLight.withOpacity(0.15),
                          AppColors.secondaryLight.withOpacity(0.1),
                        ]
                      : [
                          AppColors.primaryLight.withOpacity(0.05),
                          AppColors.secondaryLight.withOpacity(0.05),
                        ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark 
                      ? AppColors.primaryLight.withOpacity(0.2)
                      : AppColors.primaryLight.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Start Your Journey',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF000000),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Join thousands transforming their health',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: _buildModernButton(
                      'Get Started Free',
                      isPrimary: true,
                      isDark: isDark,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Onboarding coming soon! 🎉'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF000000),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark 
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.08),
    );
  }

}
