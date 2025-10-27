# Veda AI App Icon Setup Guide

## Quick Setup (Recommended)

### Option 1: Use Icon.Kitchen (Easiest - 2 minutes)
1. Go to https://icon.kitchen/
2. Click "Upload Image" or use their icon library
3. Search for "heart" or "health" icon
4. Set background color to `#6C63FF` (Veda AI purple)
5. Set foreground color to white
6. Download the generated icons
7. Extract and copy:
   - `android/` contents to `android/app/src/main/res/`
   - `ios/` contents to `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Option 2: Use AppIcon.co
1. Go to https://www.appicon.co/
2. Upload a 1024x1024 PNG with your design
3. Download the generated icon set
4. Follow same extraction process as Option 1

### Option 3: Manual Creation

#### Design Specifications:
- **Size**: 1024x1024 pixels
- **Background**: #6C63FF (Purple)
- **Foreground**: White (#FFFFFF)
- **Icon**: Heart symbol (❤️) or 'V' letter

#### Tools You Can Use:
- **Canva** (free online): https://www.canva.com/
  1. Create new design (1024x1024)
  2. Add purple rectangle background
  3. Add white heart icon or text
  4. Download as PNG

- **Figma** (free online): https://www.figma.com/
  1. Create new file with 1024x1024 frame
  2. Design your icon
  3. Export as PNG

- **Microsoft Paint 3D** (Windows built-in)
  1. Create 1024x1024 canvas
  2. Fill with purple (#6C63FF)
  3. Add white shapes
  4. Save as PNG

## After Creating Icon:

1. Save your icon as:
   - `assets/icon/android_icon.png` (1024x1024)
   - `assets/icon/ios_icon.png` (1024x1024)

2. Run the icon generator:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

3. Rebuild your app:
   ```bash
   flutter clean
   flutter build apk --release
   ```

## Current Icon Theme:
- **Primary Color**: #6C63FF (Electric Purple)
- **Secondary Color**: #FF6B6B (Coral)
- **Accent Color**: #00D9FF (Cyan)
- **Suggested Icons**: 
  - Heart with pulse line ❤️
  - Letter 'V' with heart
  - Lotus flower (wellness theme)
  - DNA helix (health theme)

## Quick Test:
After setup, check the icon appears correctly by:
1. Installing app on device/emulator
2. Looking at app drawer/home screen
3. Icon should show purple background with white symbol
