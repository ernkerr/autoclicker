---
description: Build and Distribute macOS Application
---

# How to Distribute AutoClicker

Since you are distributing a macOS app that uses Accessibility permissions (`AXIsProcessTrusted`), you have two main options:

## Option A: Official Distribution (Recommended)
*Requires a paid Apple Developer Account ($99/year).*
1.  **Commit Changes**: Ensure your git working tree is clean.
2.  **Open in Xcode**: Open `AutoClicker.xcodeproj`.
3.  **Signing**: Go to Project Settings -> Target (AutoClicker) -> **Signing & Capabilities**.
    *   Ensure "Automatically manage signing" is ON.
    *   Team: Select your Team (Personal Team doesn't support Notarization for distribution usually, you need a paid team).
4.  **Archive**:
    *   Select **Product** > **Archive** from the menu bar.
    *   Wait for the build to finish.
5.  **Distribute**:
    *   In the Organizer window that pops up, select the new archive.
    *   Click **Distribute App**.
    *   Choose **Direct Distribution** (or "Developer ID").
    *   Follow the prompts to **Upload** to Apple for Notarization.
    *   Once Notarized (can take a few minutes), you can "Export" the `.app` or `.dmg`.
6.  **Share**: You can now zip this `.app` and send it to anyone.

## Option B: Ad-Hoc / Personal Use (Free)
*If you don't have a paid account.*
1.  **Archive**: (Same as above) **Product** > **Archive**.
2.  **Distribute**:
    *   Click **Distribute App**.
    *   Choose **Copy App**.
    *   Save the `AutoClicker.app` to your Desktop.
3.  **Distribution**:
    *   Zip the app.
    *   Send it to your friend/user.
    *   **Crucial Step for User**: When they open it, they will likely get a "Unidentified Developer" warning.
    *   They must **Right-Click** (Control-Click) the app and select **Open**, then click **Open** in the dialog to bypass the security check one time.

## Option C: Quick Build (Development only)
If you just want the verified binary you are running right now:
1.  In Xcode, look at the "Products" group in the left sidebar.
2.  Right-click `AutoClicker.app` -> **Show in Finder**.
3.  Copy that file. (Note: This is a debug build and might be slower or have debugging symbols).
