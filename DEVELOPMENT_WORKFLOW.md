# 🔥 Flutter Development Workflow - Hot Reload Guide

## Quick Start: Keep Flutter Running with Hot Reload

### Method 1: Terminal (Recommended for Chrome/Web)

1. **Start Flutter once and keep it running:**

```bash
# Run Flutter in Chrome (keeps running)
flutter run -d chrome
```

2. **Keep this terminal window open** - The app will stay running on `http://localhost:xxxxx`

3. **When you make code changes:**
   - Press `r` in the terminal for **Hot Reload** (fast, preserves state)
   - Press `R` for **Hot Restart** (full restart, resets state)
   - Press `q` to quit

### Method 2: VS Code (Automatic Hot Reload on Save)

1. **Install Flutter extension** in VS Code
2. **Open your project** in VS Code
3. **Press F5** or click "Run and Debug" → "Flutter (Chrome)"
4. **Enable auto-save:**
   - Press `Ctrl+Shift+P` (Windows) or `Cmd+Shift+P` (Mac)
   - Type "Auto Save" and select "onFocusChange" or "afterDelay"

Now when you save any file, Flutter will automatically hot reload! 🎉

### Method 3: Android Studio / IntelliJ

1. **Open project** in Android Studio
2. **Click the green play button** or press `Shift+F10`
3. **Select Chrome** as the device
4. **Enable auto-save:**
   - File → Settings → Appearance & Behavior → System Settings
   - Check "Save files automatically" → Set delay (e.g., 1 second)

---

## Hot Reload vs Hot Restart

| Action | Command | When to Use | Speed |
|--------|---------|-------------|-------|
| **Hot Reload** | Press `r` | UI changes, small code changes | ⚡ Fast (1-2 seconds) |
| **Hot Restart** | Press `R` | State changes, new imports, major changes | 🔄 Medium (3-5 seconds) |
| **Full Restart** | Press `q` then `flutter run` | App crashes, need fresh start | 🐌 Slow (10+ seconds) |

---

## Tips for Best Experience

### 1. Keep Terminal Open
- Don't close the terminal where Flutter is running
- Use a separate terminal for git commands, etc.

### 2. Use Hot Reload for Most Changes
- UI changes (colors, text, layout) → Press `r`
- Widget changes → Press `r`
- Function logic changes → Press `r`

### 3. Use Hot Restart When Needed
- Adding new imports → Press `R`
- Changing `main()` function → Press `R`
- State initialization changes → Press `R`

### 4. Browser DevTools
- Keep Chrome DevTools open (`F12`)
- Check console for errors
- Use Network tab to debug API calls

---

## Troubleshooting

### App Not Updating?
1. Check terminal for errors (red text)
2. Try Hot Restart (`R`) instead of Hot Reload (`r`)
3. Check if file was saved (Ctrl+S)

### Port Already in Use?
```bash
# Kill existing Flutter process
# Windows:
taskkill /F /IM dart.exe

# Mac/Linux:
pkill -f dart
```

### Chrome Not Opening?
```bash
# Specify Chrome explicitly
flutter run -d chrome --web-port=8080
```

### Need to Change Port?
```bash
# Use custom port
flutter run -d chrome --web-port=3000
```

---

## Advanced: Watch Mode (Auto Reload on File Changes)

### Using `flutter run` with watch mode:

```bash
# Flutter automatically watches for file changes
flutter run -d chrome
```

Flutter's default behavior already watches for changes, but you need to manually trigger reload with `r` or `R`.

### Using `dart run` with file watcher (for scripts):

```bash
# Install watcher package
dart pub global activate watcher

# Watch and run
dart run --watch
```

---

## Recommended Setup

### For Daily Development:

1. **Open VS Code** with Flutter extension
2. **Press F5** to start debugging
3. **Enable auto-save** (saves every 1 second)
4. **Keep browser open** on one monitor
5. **Keep VS Code open** on another monitor
6. **Make changes** → Save → Auto hot reload! ✨

### Terminal Commands Cheat Sheet:

```bash
# Start Flutter (keep running)
flutter run -d chrome

# In the running terminal:
r          # Hot reload
R          # Hot restart  
q          # Quit
h          # Help
c          # Clear screen
```

---

## VS Code Settings (Recommended)

Add to `.vscode/settings.json`:

```json
{
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "dart.flutterHotReloadOnSave": "all",
  "dart.flutterHotRestartOnSave": false
}
```

This will:
- ✅ Auto-save files after 1 second of inactivity
- ✅ Auto hot reload when you save
- ✅ Keep your app running continuously

---

## Summary

**You only need to run `flutter run -d chrome` ONCE per session!**

After that:
- Make code changes
- Save file (Ctrl+S)
- Press `r` for hot reload (or use VS Code auto-reload)
- See changes instantly! 🚀

No need to restart Flutter every time! The app stays running on localhost and updates in real-time.

