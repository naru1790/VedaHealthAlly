import 'package:flutter/material.dart';

/// Veda AI Color Palette - Energetic Fitness Theme
/// Dynamic, bold, and motivating color scheme for fitness enthusiasts
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ==================== LIGHT THEME - ENERGETIC & VIBRANT ====================
  
  // Primary - Electric Purple/Blue (Energy & Power)
  static const Color primaryLight = Color(0xFF6C63FF); // Vibrant Electric Purple
  static const Color primaryContainerLight = Color(0xFFE8E6FF); // Soft Purple
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryContainerLight = Color(0xFF1A0066);

  // Secondary - Neon Coral/Orange (Energy & Motivation)
  static const Color secondaryLight = Color(0xFFFF6B6B); // Energetic Coral
  static const Color secondaryContainerLight = Color(0xFFFFE5E5); // Soft Coral
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryContainerLight = Color(0xFF8B0000);

  // Tertiary - Electric Cyan (Fresh & Dynamic)
  static const Color tertiaryLight = Color(0xFF00D9FF); // Electric Cyan
  static const Color tertiaryContainerLight = Color(0xFFD0F8FF);
  static const Color onTertiaryLight = Color(0xFF003544);
  static const Color onTertiaryContainerLight = Color(0xFF001F28);

  // Surface & Background - Clean & Modern
  static const Color surfaceLight = Color(0xFFFAFAFF);
  static const Color surfaceVariantLight = Color(0xFFF0EFFF);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF1A1A2E);
  static const Color onBackgroundLight = Color(0xFF1A1A2E);

  // Error - Bold Red
  static const Color errorLight = Color(0xFFFF3B3B);
  static const Color errorContainerLight = Color(0xFFFFE5E5);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color onErrorContainerLight = Color(0xFF8B0000);

  // Outline & Dividers
  static const Color outlineLight = Color(0xFFB8B8D1);
  static const Color outlineVariantLight = Color(0xFFE0E0F0);

  // ==================== DARK THEME - BOLD & DYNAMIC ====================

  // Primary - Glowing Purple
  static const Color primaryDark = Color(0xFF8B7FFF); // Brighter for dark mode
  static const Color primaryContainerDark = Color(0xFF4A3FFF); // Deep electric
  static const Color onPrimaryDark = Color(0xFF000033);
  static const Color onPrimaryContainerDark = Color(0xFFE8E6FF);

  // Secondary - Vibrant Coral
  static const Color secondaryDark = Color(0xFFFF8A8A); // Brighter coral
  static const Color secondaryContainerDark = Color(0xFFFF4444); // Deep coral
  static const Color onSecondaryDark = Color(0xFF330000);
  static const Color onSecondaryContainerDark = Color(0xFFFFE5E5);

  // Tertiary - Glowing Cyan
  static const Color tertiaryDark = Color(0xFF33E5FF); // Brighter cyan
  static const Color tertiaryContainerDark = Color(0xFF00A8CC);
  static const Color onTertiaryDark = Color(0xFF001F28);
  static const Color onTertiaryContainerDark = Color(0xFFD0F8FF);

  // Surface & Background - Deep & Rich
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceVariantDark = Color(0xFF1E1E2D);
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color onSurfaceDark = Color(0xFFF0F0FF);
  static const Color onBackgroundDark = Color(0xFFF0F0FF);

  // Error
  static const Color errorDark = Color(0xFFFF6B6B);
  static const Color errorContainerDark = Color(0xFFCC0000);
  static const Color onErrorDark = Color(0xFF330000);
  static const Color onErrorContainerDark = Color(0xFFFFE5E5);

  // Outline & Dividers
  static const Color outlineDark = Color(0xFF6B6B8A);
  static const Color outlineVariantDark = Color(0xFF2E2E44);

  // ==================== FITNESS SEMANTIC COLORS ====================

  // Health Status Colors - Bold & Clear
  static const Color healthExcellent = Color(0xFF00D97E); // Bright Green
  static const Color healthGood = Color(0xFF39D98A); // Green
  static const Color healthWarning = Color(0xFFFFAE33); // Orange
  static const Color healthPoor = Color(0xFFFF4D6A); // Red

  // Activity Colors - Energetic
  static const Color activityHigh = Color(0xFFFF6B6B); // Red-Orange
  static const Color activityMedium = Color(0xFF6C63FF); // Purple
  static const Color activityLow = Color(0xFF00D9FF); // Cyan
  static const Color activityRest = Color(0xFF95A3B3); // Gray

  // Workout Intensity Colors
  static const Color intensityMax = Color(0xFFFF3B3B); // Red
  static const Color intensityHigh = Color(0xFFFF6B35); // Orange-Red
  static const Color intensityModerate = Color(0xFFFFAE33); // Orange
  static const Color intensityLow = Color(0xFF00D97E); // Green

  // ==================== VIBRANT GRADIENTS ====================

  // Primary Gradient - Electric Purple to Blue
  static const List<Color> primaryGradientLight = [
    Color(0xFF6C63FF), // Electric Purple
    Color(0xFF4D47E1), // Deep Purple
  ];

  static const List<Color> primaryGradientDark = [
    Color(0xFF8B7FFF), // Bright Purple
    Color(0xFF6C63FF), // Electric Purple
  ];

  // Secondary Gradient - Sunset Fire
  static const List<Color> secondaryGradientLight = [
    Color(0xFFFF6B6B), // Coral
    Color(0xFFFF8E53), // Orange
  ];

  static const List<Color> secondaryGradientDark = [
    Color(0xFFFF8A8A), // Bright Coral
    Color(0xFFFF6B6B), // Coral
  ];

  // Hero Gradient - Multi-color Energy
  static const List<Color> heroGradient = [
    Color(0xFF6C63FF), // Electric Purple
    Color(0xFFFF6B6B), // Coral
    Color(0xFFFFAE33), // Orange
  ];

  // Workout Card Gradients - Dynamic & Bold
  static const List<Color> cardGradient1 = [
    Color(0xFF6C63FF), // Electric Purple
    Color(0xFF00D9FF), // Cyan
  ];

  static const List<Color> cardGradient2 = [
    Color(0xFFFF6B6B), // Coral
    Color(0xFFFF3B8F), // Pink
  ];

  static const List<Color> cardGradient3 = [
    Color(0xFFFFAE33), // Orange
    Color(0xFFFF6B35), // Red-Orange
  ];

  static const List<Color> cardGradient4 = [
    Color(0xFF00D97E), // Green
    Color(0xFF00D9FF), // Cyan
  ];

  // Energetic Multi-Stop Gradients
  static const List<Color> energyGradient = [
    Color(0xFFFF3B3B), // Red
    Color(0xFFFF6B35), // Orange
    Color(0xFFFFAE33), // Yellow-Orange
  ];

  static const List<Color> powerGradient = [
    Color(0xFF4D47E1), // Deep Purple
    Color(0xFF6C63FF), // Electric Purple
    Color(0xFF8B7FFF), // Bright Purple
  ];

  static const List<Color> cooldownGradient = [
    Color(0xFF00D9FF), // Cyan
    Color(0xFF00D97E), // Green
    Color(0xFF6C63FF), // Purple
  ];

  // Special Effect Colors
  static const Color neonGlow = Color(0xFF6C63FF); // Purple glow
  static const Color successGlow = Color(0xFF00D97E); // Green glow
  static const Color warningGlow = Color(0xFFFFAE33); // Orange glow
  static const Color dangerGlow = Color(0xFFFF3B3B); // Red glow

  // Glassmorphism overlays
  static const Color glassLight = Color(0x40FFFFFF); // 25% white
  static const Color glassDark = Color(0x20000000); // 12% black
}
