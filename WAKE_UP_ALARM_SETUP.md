# Wake Up Alarm Setup

## Overview
The app now includes a **gentle alarm** specifically for the wake-up task at 6:00 AM. This alarm is designed to be more effective than a regular notification.

## Features Implemented

### 1. **Dedicated Wake-Up Alarm** (ID: 8888)
- **Time**: 6:00 AM daily (based on evt_wake in your routine)
- **Title**: "⏰ Wake Up Time!"
- **Message**: "Time to start your healthy day! Hydrate and take your B12 supplement."
- **Type**: Full-screen alarm notification

### 2. **Morning Routine Reminder** (ID: 9999)
- **Time**: 6:10 AM (10 minutes after wake-up)
- **Title**: "Good Morning!"
- **Message**: "Time to check your daily routine!"

## Alarm Characteristics

### Android:
- ✅ **High Priority**: Uses maximum importance and priority
- ✅ **Full Screen Intent**: Will show even when phone is locked
- ✅ **Vibration**: Enabled for better wake-up effectiveness
- ✅ **Sound**: Custom gentle alarm sound (when audio file is added)
- ✅ **Alarm Category**: Marked as alarm for system handling
- ✅ **Exact Timing**: Uses exactAllowWhileIdle for precise timing

### iOS:
- ✅ **Sound Support**: Custom gentle alarm sound
- ✅ **Alert**: Full alert presentation
- ✅ **Badge & Sound**: Both enabled

## Adding Custom Gentle Sound (Optional)

### For Android:
1. **Find a gentle alarm sound**:
   - Recommended: Soft chimes, gentle bells, or nature sounds
   - Format: MP3 or OGG
   - Duration: 5-30 seconds with fade-in

2. **Free sound sources**:
   - Pixabay: https://pixabay.com/sound-effects/search/alarm/
   - Freesound: https://freesound.org/ (search "gentle alarm")
   - YouTube Audio Library (search for gentle wake sounds)

3. **Add to project**:
   - Place file at: `android/app/src/main/res/raw/gentle_alarm.mp3`
   - The `raw` folder has been created for you
   - File must be named exactly: `gentle_alarm.mp3` or `gentle_alarm.ogg`

4. **Rebuild the app**:
   ```bash
   flutter run -d emulator-5554
   ```

### For iOS:
1. Convert sound to `.aiff` or `.caf` format
2. Add to: `ios/Runner/Resources/gentle_alarm.aiff`
3. Add to Xcode project resources

## Testing the Alarm

### Immediate Testing:
To test without waiting until 6 AM:

1. **Open the app** and go to "Daily Routine & Nutrition"
2. **Tap "Schedule Notifications"** button
3. **Change your device time** to 5:59 AM
4. Wait 1 minute - the alarm should trigger at 6:00 AM

### Production Testing:
- The alarm is set for 6:00 AM every day
- It will repeat daily automatically
- To cancel, tap the "Cancel All Notifications" button in the app

## Default Behavior (Without Custom Sound)

Even without adding a custom sound file, the alarm will:
- ✅ Still trigger at 6:00 AM
- ✅ Use system default alarm sound
- ✅ Show full-screen notification
- ✅ Vibrate the device
- ✅ Work when phone is locked

The custom sound just provides a gentler, more pleasant wake-up experience.

## Troubleshooting

### Alarm doesn't trigger:
1. Ensure "Exact Alarms" permission is granted (app requests this automatically)
2. Check battery optimization settings - exclude the app
3. Verify notifications are enabled in device settings

### No sound plays:
1. Check device is not in silent/DND mode
2. Verify notification sound settings
3. If custom sound: ensure file is in correct location with correct name

### Alarm not showing when locked:
1. Grant "Display over other apps" permission if prompted
2. Enable "Show notifications on lock screen" in device settings

## Files Modified

1. **lib/services/notification_service.dart**
   - Added `scheduleWakeUpAlarm()` method
   - Enhanced `scheduleDailyNotification()` with alarm support
   - Configured full-screen intent and alarm category

2. **lib/screens/daily_routine_screen.dart**
   - Updated to call `scheduleWakeUpAlarm()` for wake event
   - Separate alarm at 6:00 AM
   - Morning reminder at 6:10 AM

3. **android/app/src/main/res/raw/**
   - Created directory for custom alarm sound
   - Added README with instructions

## Next Steps

1. **Test the alarm** with the default sound (works immediately)
2. **Optional**: Add a custom gentle alarm sound file
3. **Adjust time**: If needed, modify wake time in the JSON data
4. **Battery optimization**: Ensure app is excluded from battery restrictions

The alarm is now ready to use! 🎵⏰
