# AutoClicker

A lightweight macOS auto-clicker that lets you pick an exact on-screen target and click it repeatedly at a configurable rate. Runs as a menu bar utility with a simple "set target → start → stop" workflow.

## Screenshot

<!-- Add your screenshot here, e.g.: ![AutoClicker](screenshot.png) -->

## How to Download

### Option 1: Pre-built app (if available)
1. Go to the [Releases](../../releases) page of this repo.
2. Download the latest `AutoClicker.zip` (or `.dmg`).
3. Unzip and move `AutoClicker.app` to your Applications folder (or anywhere you like).

### Option 2: Build from source
1. Click the green **Code** button on this page and choose **Download ZIP**.
2. Unzip the file and open `AutoClicker.xcodeproj` in Xcode.
3. In Xcode: **Product** → **Archive** → **Distribute App** → **Copy App**.
4. The built `AutoClicker.app` will be saved to your chosen location.

**First-time opening:** If you get an "Unidentified Developer" warning, right-click the app → **Open** → **Open** in the dialog to run it.

## Requirements

- **macOS 15.2** or later
- **Accessibility permission** (the app will prompt you)

## How to Use

1. **Launch** the app. It appears in your menu bar (top right).
2. **Click the menu bar icon** to open the main window.
3. **Set target:** Click the target (scope) button, then click anywhere on your screen where you want the auto-clicker to click.
4. **Adjust speed:** Use the rate slider or enter clicks-per-second.
5. **Start:** Press the Start button. The app will click your target location at the set rate.
6. **Stop:** Press Stop, or use the emergency hotkey **⌃⌥⌘Q** (Control-Option-Command-Q) anytime.

### Optional settings
Open the gear icon for:
- **Double Click** mode
- **Smart Delay** (waits for mouse to be idle before clicking)
- **Click Limit** (stop after a set number of clicks)
- **Audio feedback** and **visual click indicator**

## Permissions

The app needs **Accessibility** access to simulate mouse clicks. When you first start clicking, macOS will prompt you. If needed, go to **System Settings** → **Privacy & Security** → **Accessibility** and enable AutoClicker.
