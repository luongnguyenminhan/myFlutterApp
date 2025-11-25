# 04 - State Management with Riverpod

## What is State Management?

**State** is any data that can change over time in your app. State management is how you handle, update, and share this data across your widgets.

**Why Riverpod?**
- Type-safe and compile-time safe
- Easy testing
- Great debugging tools
- Works with all Flutter platforms
- No boilerplate code

## Riverpod Core Concepts

### 1. Providers
Providers are the heart of Riverpod. They define how to create and manage state.

```dart:lib/view_models/providers/counter_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple provider for a value
final counterProvider = StateProvider<int>((ref) => 0);

// Provider for complex state with methods
final counterNotifierProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0); // Initial value

  void increment() {
    state++; // Update state
  }

  void decrement() {
    state--;
  }

  void reset() {
    state = 0;
  }
}
```

### 2. Reading Providers in Widgets

#### Method 1: ConsumerWidget
```dart:lib/views/counter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/providers/counter_provider.dart';

class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the counter value - rebuilds when it changes
    final counter = ref.watch(counterNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Counter: $counter',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Read the notifier and call methods
                    ref.read(counterNotifierProvider.notifier).decrement();
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(counterNotifierProvider.notifier).reset();
                  },
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(counterNotifierProvider.notifier).increment();
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Method 2: Consumer (for part of widget tree)
```dart:lib/widgets/consumer_example.dart
class PartialConsumerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partial Consumer')),
      body: Column(
        children: [
          const Text('This part never rebuilds'),

          // Only this part rebuilds when counter changes
          Consumer(
            builder: (context, ref, child) {
              final counter = ref.watch(counterNotifierProvider);
              return Text('Counter: $counter');
            },
          ),

          const Text('This part also never rebuilds'),
        ],
      ),
    );
  }
}
```

## Different Provider Types

### StateProvider - Simple State
```dart:lib/view_models/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple boolean state
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// Usage in widget
class ThemeToggleButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Switch(
      value: isDark,
      onChanged: (value) {
        ref.read(isDarkModeProvider.notifier).state = value;
      },
    );
  }
}
```

### StateNotifierProvider - Complex State
```dart:lib/view_models/providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  Future<void> login(String email, String password) async {
    state = User(id: '1', name: 'John Doe', email: email);
  }

  void logout() {
    state = null;
  }

  void updateName(String newName) {
    if (state != null) {
      state = User(
        id: state!.id,
        name: newName,
        email: state!.email,
      );
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});
```

### FutureProvider - Async Operations
```dart:lib/view_models/providers/weather_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simulates API call
Future<String> fetchWeather(String city) async {
  await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
  return 'Sunny, 25°C in $city';
}

final weatherProvider = FutureProvider.family<String, String>((ref, city) async {
  return fetchWeather(city);
});

// Usage
class WeatherWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider('London'));

    return weatherAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (weather) => Text(weather),
    );
  }
}
```

### StreamProvider - Real-time Data
```dart:lib/view_models/providers/time_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentTimeProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

// Usage
class ClockWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeAsync = ref.watch(currentTimeProvider);

    return timeAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (time) => Text(
        '${time.hour}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}',
        style: const TextStyle(fontSize: 48),
      ),
    );
  }
}
```

## Provider Scopes and Dependencies

### Provider Dependencies
```dart:lib/view_models/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Base providers
final authTokenProvider = StateProvider<String?>((ref) => null);

// Dependent provider
final isLoggedInProvider = Provider<bool>((ref) {
  final token = ref.watch(authTokenProvider);
  return token != null && token.isNotEmpty;
});

// Provider that depends on authentication
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final isLoggedIn = ref.watch(isLoggedInProvider);
  final token = ref.watch(authTokenProvider);

  if (!isLoggedIn || token == null) return null;

  // Fetch user profile using token
  return await fetchUserProfile(token);
});
```

### Provider Overrides (Testing)
```dart:lib/main_test.dart
void main() {
  testWidgets('Counter increments', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override with test data
          counterNotifierProvider.overrideWith((ref) => TestCounterNotifier()),
        ],
        child: const MyApp(),
      ),
    );

    // Test your UI
  });
}
```

## Combining Multiple Providers

### Using Selectors for Performance
```dart:lib/widgets/optimized_user_widget.dart
class UserNameWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuilds when user name changes, not when email changes
    final userName = ref.watch(
      userProvider.select((user) => user?.name),
    );

    return Text('Name: $userName');
  }
}

class UserEmailWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuilds when user email changes
    final userEmail = ref.watch(
      userProvider.select((user) => user?.email),
    );

    return Text('Email: $userEmail');
  }
}
```

## Error Handling

```dart:lib/view_models/providers/error_handling_provider.dart
final apiProvider = FutureProvider<String>((ref) async {
  try {
    final result = await makeApiCall();
    return result;
  } catch (error) {
    // Log error, show user message, etc.
    throw Exception('API call failed: $error');
  }
});

class ApiResultWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiResult = ref.watch(apiProvider);

    return apiResult.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) {
        return Column(
          children: [
            Text('Error: $error'),
            ElevatedButton(
              onPressed: () => ref.invalidate(apiProvider), // Retry
              child: const Text('Retry'),
            ),
          ],
        );
      },
      data: (data) => Text('Result: $data'),
    );
  }
}
```

## Best Practices

### 1. Provider Naming Conventions
```dart
// Good: descriptive names
final userProfileProvider = StateNotifierProvider<UserNotifier, User>((ref) => UserNotifier());
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Bad: unclear names
final provider1 = StateProvider((ref) => 0);
final data = FutureProvider((ref) => fetchData());
```

### 2. Keep Providers Focused
```dart
// Good: single responsibility
final userProvider = StateNotifierProvider<UserNotifier, User>((ref) => UserNotifier());
final postsProvider = StateNotifierProvider<PostsNotifier, List<Post>>((ref) => PostsNotifier());

// Avoid: doing too many things
final everythingProvider = StateNotifierProvider<EverythingNotifier, AppState>((ref) => EverythingNotifier());
```

### 3. Use Selectors for Performance
```dart
// Instead of watching entire object
final user = ref.watch(userProvider);

// Watch only what you need
final userName = ref.watch(userProvider.select((user) => user.name));
```

### 4. Handle Loading and Error States
```dart
final apiResult = ref.watch(apiProvider);

return apiResult.when(
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
  data: (data) => DataWidget(data),
);
```

## Common Patterns

### Form State Management
```dart:lib/view_models/providers/form_provider.dart
class FormState {
  final String email;
  final String password;
  final bool isSubmitting;
  final String? error;

  FormState({
    this.email = '',
    this.password = '',
    this.isSubmitting = false,
    this.error,
  });

  FormState copyWith({
    String? email,
    String? password,
    bool? isSubmitting,
    String? error,
  }) {
    return FormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
    );
  }
}

class FormNotifier extends StateNotifier<FormState> {
  FormNotifier() : super(FormState());

  void updateEmail(String email) {
    state = state.copyWith(email: email, error: null);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, error: null);
  }

  Future<void> submit() async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      await loginUser(state.email, state.password);
      // Success - maybe navigate or show success message
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final formProvider = StateNotifierProvider<FormNotifier, FormState>((ref) {
  return FormNotifier();
});
```

## Practice Exercises

### Exercise 1: Todo List
Create providers for:
- List of todos
- Add/remove todo items
- Toggle completion status
- Filter completed/incomplete todos

### Exercise 2: Shopping Cart
Build providers for:
- Cart items with quantities
- Add/remove items
- Calculate total price
- Apply discounts

### Exercise 3: Settings Screen
Create providers for:
- Theme preference (light/dark)
- Language selection
- Notification settings
- Save/load settings from storage

## What's Next?

In the next guide, we'll build complete UI screens using what we've learned about widgets and state management!
