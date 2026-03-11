# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Flutter application for business document and shareholder management, inspired by business consulting workflows in Nepal. Users can manage MOUs, shareholder certificates, and business objectives.

## Common Commands

```bash
# Run the app
flutter run

# Run on a specific device
flutter run -d chrome        # Web
flutter run -d ios           # iOS simulator
flutter run -d android       # Android emulator

# Build
flutter build apk            # Android APK
flutter build ios            # iOS
flutter build web            # Web

# Test
flutter test                 # All tests
flutter test test/widget_test.dart  # Single test file

# Lint & analyze
flutter analyze

# Format
dart format lib/
```

## Architecture

**Entry point:** `lib/main.dart` — contains `MyApp`, the `RYC` main scaffold, and the `CustomHeader` reusable AppBar widget.

**Pages** (`lib/pages/`):
- `login_page.dart` — Login UI (auth logic not yet implemented)
- `profile_page.dart` — User profile, expandable company list, share info
- `settings_page.dart` — Settings page (largely unimplemented)

**Navigation:** Uses `Navigator.push`/`pop` throughout (no named routes or routing package). Navigation flows: RYC → ProfilePage (via avatar tap), ProfilePage → SettingsPage (via settings button).

**Color scheme:** Dark red/maroon (`#AB4545`) for the main header; light blue (`#6BABE6`) for the login AppBar.

## Current State

- No models or service layer yet — all data is hardcoded placeholder content
- Login button `onPressed` is empty (TODO)
- Menu icon in `CustomHeader` is unimplemented (TODO)
- The default widget test in `test/widget_test.dart` is a Flutter template stub and does not reflect actual app functionality — it will fail if run
- Multi-platform support is configured (Android, iOS, Web, Linux, macOS, Windows)
