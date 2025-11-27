# 03 - Flutter Widgets Basics

## Everything is a Widget

In Flutter, **everything is a widget**. Buttons, text, layouts, animations, themes - all are widgets. Widgets are the fundamental building blocks of Flutter UIs.

## Widget Tree

Flutter apps are built as a **tree of widgets**:

```
MaterialApp          // Root widget
├── Scaffold         // Page structure
│   ├── AppBar      // Top bar
│   │   └── Text    // Title text
│   └── Container   // Main content
│       └── Column // Vertical layout
│           ├── Text  // Welcome message
│           ├── Text  // Instructions
│           └── ElevatedButton  // Action button
```

Each widget can contain other widgets, creating a hierarchical tree structure.

## Stateless vs Stateful Widgets

### StatelessWidget
For static content that doesn't change:

```dart:lib/widgets/stateless_example.dart
class WelcomeMessage extends StatelessWidget {
  final String name;

  const WelcomeMessage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Welcome, $name!',
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
```

**Key Points:**
- Immutable (properties can't change)
- No internal state
- Rebuilds when parent rebuilds or external data changes

### StatefulWidget
For dynamic content that can change over time:

```dart:lib/widgets/stateful_example.dart
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;  // Private state variable

  void _incrementCounter() {
    setState(() {  // Triggers rebuild
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Counter: $_counter'),
        ElevatedButton(
          onPressed: _incrementCounter,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

**Key Points:**
- Has mutable state that can change
- `setState()` triggers rebuild
- State persists across rebuilds

## Basic Layout Widgets

### Container
The most versatile layout widget:

```dart:lib/widgets/container_examples.dart
// Simple colored box
Container(
  width: 100,
  height: 100,
  color: Colors.blue,
)

// Container with padding and decoration
Container(
  padding: const EdgeInsets.all(16.0),  // Inner spacing
  margin: const EdgeInsets.all(8.0),    // Outer spacing
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.3),
        spreadRadius: 2,
        blurRadius: 5,
      ),
    ],
  ),
  child: const Text('Hello Container!'),
)
```

### Column & Row
For arranging widgets vertically or horizontally:

```dart:lib/widgets/layout_examples.dart
// Vertical layout
Column(
  mainAxisAlignment: MainAxisAlignment.center,  // Vertical alignment
  crossAxisAlignment: CrossAxisAlignment.start, // Horizontal alignment
  children: [
    Text('First item'),
    SizedBox(height: 16),  // Spacing
    Text('Second item'),
    Text('Third item'),
  ],
)

// Horizontal layout
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,  // Even spacing
  children: [
    Icon(Icons.home),
    Icon(Icons.search),
    Icon(Icons.settings),
  ],
)
```

### Stack
For overlapping widgets:

```dart:lib/widgets/stack_example.dart
Stack(
  alignment: Alignment.center,
  children: [
    // Background
    Container(
      width: 200,
      height: 200,
      color: Colors.blue,
    ),
    // Foreground
    Container(
      width: 100,
      height: 100,
      color: Colors.red,
    ),
    // Text on top
    const Positioned(
      bottom: 20,
      child: Text(
        'Overlay Text',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    ),
  ],
)
```

## Material Design Widgets

### Scaffold
Provides basic page structure:

```dart:lib/widgets/scaffold_example.dart
Scaffold(
  appBar: AppBar(
    title: const Text('My App'),
    actions: [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          // Handle settings tap
        },
      ),
    ],
  ),
  body: const Center(
    child: Text('Main content goes here'),
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () {
      // Handle FAB tap
    },
    child: const Icon(Icons.add),
  ),
  bottomNavigationBar: BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ],
  ),
)
```

### Common Input Widgets

```dart:lib/widgets/input_examples.dart
// Text Field
TextField(
  decoration: const InputDecoration(
    labelText: 'Enter your name',
    hintText: 'John Doe',
    border: OutlineInputBorder(),
  ),
  onChanged: (value) {
    // Handle text changes
  },
)

// Checkbox
Checkbox(
  value: isChecked,
  onChanged: (bool? value) {
    setState(() {
      isChecked = value ?? false;
    });
  },
)

// Dropdown
DropdownButton<String>(
  value: selectedValue,
  items: ['Option 1', 'Option 2', 'Option 3']
      .map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
  onChanged: (String? newValue) {
    setState(() {
      selectedValue = newValue!;
    });
  },
)
```

## Styling & Theming

### Text Styling

```dart:lib/widgets/text_styling.dart
Text(
  'Styled Text',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
    letterSpacing: 1.5,
    decoration: TextDecoration.underline,
  ),
)

// Using theme
Text(
  'Themed Text',
  style: Theme.of(context).textTheme.headlineMedium,
)
```

### Colors & Themes

```dart:lib/widgets/color_examples.dart
// Direct colors
Container(color: Colors.blue)

// Custom colors
Container(color: Color(0xFF42A5F5))

// Colors with opacity
Container(color: Colors.blue.withOpacity(0.5))

// Theme colors
Container(color: Theme.of(context).primaryColor)
```

## Interactive Widgets

### Button Types

```dart:lib/widgets/button_examples.dart
// Elevated Button (raised)
ElevatedButton(
  onPressed: () {
    print('Elevated button pressed');
  },
  child: const Text('Click me'),
)

// Text Button (flat)
TextButton(
  onPressed: () {},
  child: const Text('Flat button'),
)

// Outlined Button
OutlinedButton(
  onPressed: () {},
  child: const Text('Outlined button'),
)

// Icon Button
IconButton(
  icon: const Icon(Icons.favorite),
  onPressed: () {},
)
```

### Gesture Detection

```dart:lib/widgets/gesture_examples.dart
// Detect taps
GestureDetector(
  onTap: () {
    print('Widget tapped');
  },
  onDoubleTap: () {
    print('Widget double tapped');
  },
  onLongPress: () {
    print('Widget long pressed');
  },
  child: Container(
    padding: const EdgeInsets.all(16),
    color: Colors.blue,
    child: const Text('Tap me'),
  ),
)

// InkWell for Material ripple effect
InkWell(
  onTap: () {
    print('InkWell tapped');
  },
  child: Container(
    padding: const EdgeInsets.all(16),
    child: const Text('Ripple effect'),
  ),
)
```

## Build Context Deep Dive

Every widget's `build()` method receives a `BuildContext`. This context:

```dart:lib/widgets/context_examples.dart
class ContextExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Access screen size
        Text('Screen width: ${MediaQuery.of(context).size.width}'),

        // Access theme
        Text(
          'Primary color',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),

        // Navigation
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/next-screen');
          },
          child: const Text('Go to next screen'),
        ),

        // Show snackbar
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hello from snackbar!')),
            );
          },
          child: const Text('Show snackbar'),
        ),
      ],
    );
  }
}
```

## Practice Exercises

### Exercise 1: Create a Profile Card
Build a widget that displays:
- Profile picture (CircleAvatar)
- Name (Text)
- Bio (Text)
- Follow button (ElevatedButton)

### Exercise 2: Settings Screen
Create a settings screen with:
- Switches for notifications
- Dropdown for theme selection
- Text fields for user preferences

### Exercise 3: Interactive Counter
Build a counter that:
- Displays current count
- Has + and - buttons
- Changes color based on count value
- Shows different messages for different ranges

## Key Takeaways

1. **Everything is a widget** - from buttons to entire screens
2. **Widget tree** - UIs are hierarchical trees of widgets
3. **Stateless** for static content, **Stateful** for dynamic content
4. **Context** gives access to theme, navigation, media queries
5. **Composition** over inheritance - build complex UIs from simple widgets

## What's Next?

In the next guide, we'll explore **state management with Riverpod** - how to manage app state across widgets and screens!

