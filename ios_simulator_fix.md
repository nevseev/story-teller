# iOS Simulator Troubleshooting Guide

If you're encountering the error "Failed to launch iOS Simulator: Error: Emulator didn't connect within 60 seconds", try these solutions:

## Solution 1: Restart the iOS Simulator manually

1. Close VS Code
2. Open Terminal
3. Close any running simulators: `xcrun simctl shutdown all`
4. Open the simulator manually: `open -a Simulator`
5. Wait for the simulator to fully boot up
6. Reopen VS Code and try running the app again

## Solution 2: Reset Simulator

1. From the iOS Simulator menu, select "Device" > "Erase All Content and Settings"
2. Restart the simulator
3. Try running the app again

## Solution 3: Update Xcode Command Line Tools

```bash
sudo xcode-select --reset
xcode-select --install
```

## Solution 4: Check Flutter Doctor

Run the following command to verify your Flutter installation:

```bash
flutter doctor -v
```

Make sure Xcode and iOS tools are properly installed and configured.

## Solution 5: Use a Different Simulator

1. List available simulators: `xcrun simctl list`
2. Create a new simulator if needed
3. Try with a different iOS version

## Solution 6: Specify Simulator Directly

Run your app by explicitly specifying the simulator:

```bash
flutter run -d "iPhone 13"  # Replace with your simulator name
```

## Solution 7: Fix Blank OS Versions in Simulator

If the list of OS Versions is blank when trying to create a new simulator:

1. Close Simulator app completely
2. Open Terminal and run:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app
   ```
3. Run the following commands to reset simulator data:
   ```bash
   xcrun simctl erase all
   # The next command might show "Domain not found" error - that's OK
   defaults delete com.apple.CoreSimulator 2>/dev/null || echo "CoreSimulator preferences not found (this is normal if you haven't used the simulator before)"
   killall "Simulator" 2>/dev/null || echo "Simulator not running"
   ```
4. Reinstall iOS simulator runtime:
   ```bash
   xcodebuild -downloadPlatform iOS
   ```
   (This may take some time as it downloads iOS simulator runtimes)
5. Restart your Mac
6. Open Xcode (not Simulator) and go to Xcode → Settings → Components
7. Verify iOS simulator runtimes are installed
8. Try creating a simulator from Xcode directly: Xcode → Window → Devices and Simulators
9. Then launch the Simulator app again

If none of these solutions work, try completely reinstalling the Flutter and Dart plugins in VS Code.
