# 01 - Getting Started with Flutter

## Welcome to Flutter Learning Journey!

This guide will help you learn Flutter from scratch while building a cross-platform desktop app. We'll start with the basics and gradually build up to more complex concepts.

## What is Flutter?

Flutter is Google's UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.

**Key Concepts:**
- **Widgets**: Everything in Flutter is a widget (buttons, text, layouts, etc.)
- **Hot Reload**: See changes instantly without restarting the app
- **Dart Language**: Flutter uses Dart programming language
- **Cross-Platform**: One codebase for iOS, Android, Web, Windows, macOS, Linux

## Prerequisites

Before starting, make sure you have:

1. **Flutter SDK** installed
2. **Dart SDK** (comes with Flutter)
3. **Android Studio** or **VS Code** with Flutter extensions
4. **Android/iOS Simulator** or physical device

### Installation Check

Open terminal and run:
```bash
flutter doctor
```

This command checks if everything is properly installed and configured.

## Your First Flutter Project

You've already created a Flutter project! Let's examine what we have:

### Project Structure Overview

```
myFlutterApp/
├── lib/                    # Main Dart code
│   ├── main.dart          # App entry point
│   ├── models/            # Data models
│   ├── view_models/       # Business logic (MVVM)
│   ├── views/             # UI screens
│   ├── services/          # External data/API calls
│   ├── utils/             # Helper functions
│   └── widgets/           # Reusable UI components
├── android/               # Android-specific code
├── ios/                   # iOS-specific code
├── web/                   # Web-specific code
├── macos/                 # macOS-specific code
├── windows/               # Windows-specific code
├── linux/                 # Linux-specific code
├── pubspec.yaml           # Project configuration
└── test/                  # Unit and widget tests
```

## Understanding main.dart

Let's look at the entry point of our app:

```dart:lib/main.dart
import 'package:flutter/material.dart';  // Import Material Design widgets

void main() {
  runApp(const MyApp());  // This starts our Flutter app
}

class MyApp extends StatelessWidget {  // Stateless = doesn't change over time
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // build() creates the UI. Called whenever widget needs to update
    return MaterialApp(  // MaterialApp provides Material Design theme
      title: 'DesktopAppTest',
      theme: ThemeData(  // Defines colors, fonts, etc.
        primarySwatch: Colors.blue,
        useMaterial3: true,  // Modern Material Design
      ),
      home: const HomeScreen(),  // First screen to show
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(  // Basic page structure
      appBar: AppBar(  // Top bar with title
        title: const Text('DesktopAppTest'),
      ),
      body: const Center(  // Main content area
        child: Text('Welcome to DesktopAppTest'),  // Centered text
      ),
    );
  }
}
```

## Key Flutter Concepts Explained

### 1. Widgets
Everything in Flutter is a widget. Widgets are:
- **Immutable**: Once created, they don't change
- **Compositional**: Built by combining smaller widgets
- **Reactive**: Rebuild when data changes

### 2. Stateless vs Stateful Widgets

**StatelessWidget**: For static content that doesn't change
```dart
class MyStaticWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('This never changes');
  }
}
```

**StatefulWidget**: For dynamic content that can change
```dart
class MyDynamicWidget extends StatefulWidget {
  @override
  _MyDynamicWidgetState createState() => _MyDynamicWidgetState();
}

class _MyDynamicWidgetState extends State<MyDynamicWidget> {
  int counter = 0;  // This can change!

  @override
  Widget build(BuildContext context) {
    return Text('Counter: $counter');
  }
}
```

### 3. Build Context
- `context` is like a "handle" to the widget tree
- Used for navigation, accessing themes, finding ancestors
- Every widget's build method receives a context

## Running Your First App

### For Desktop (macOS/Windows/Linux):

```bash
# Make sure you're in the project directory
cd /Users/anlnm/Desktop/Project/myFlutterApp

# Get dependencies
flutter pub get

# Run on your desktop
flutter run
```

### For Web:

```bash
flutter run -d chrome  # Run in Chrome browser
```

### For Mobile:

```bash
flutter run -d android  # Android emulator/device
flutter run -d ios      # iOS simulator (macOS only)
```

## Hot Reload vs Hot Restart

- **Hot Reload** (Ctrl+R): Injects code changes, preserves state
- **Hot Restart** (Ctrl+Shift+R): Restarts app, loses state but faster than full restart

Try changing the text in `HomeScreen` and press Ctrl+R to see Hot Reload in action!

## What's Next?

In the next guide, we'll explore the project structure and understand the MVVM (Model-View-ViewModel) architecture pattern used in this project.

## Quick Exercises

1. Change the app title in `main.dart`
2. Modify the welcome text
3. Try changing the primary color in the theme
4. Experiment with different text styles

Remember: Every time you make a change, use **Hot Reload** (Ctrl+R) to see it instantly!

