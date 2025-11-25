# 02 - Project Structure & MVVM Architecture

## Understanding MVVM Architecture

MVVM (Model-View-ViewModel) is a design pattern that separates your app into three distinct layers:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│      Model      │    │   ViewModel      │    │      View       │
│                 │    │                  │    │                 │
│ • Data models   │◄──►│ • Business logic │◄──►│ • UI widgets    │
│ • API responses │    │ • State management│    │ • User interface│
│ • Database      │    │ • Data processing │    │ • Layouts       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

**Benefits:**
- **Separation of Concerns**: Each layer has a single responsibility
- **Testability**: Easy to unit test business logic
- **Maintainability**: Changes in one layer don't affect others
- **Reusability**: ViewModels can be reused across different views

## Our Project Structure

Let's explore each folder and understand its purpose:

### 📁 lib/
The main application code directory.

#### 📁 models/
**Purpose**: Define data structures and business objects.

```dart:lib/models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  // Convert from JSON (useful for API calls)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
```

#### 📁 view_models/
**Purpose**: Contains business logic and state management.

**With Riverpod (our state management solution):**

```dart:lib/view_models/providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';

// Provider for user state
final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null); // Initial state is null (no user logged in)

  // Business logic methods
  void login(String email, String password) {
    // Simulate API call
    final user = UserModel(
      id: '1',
      name: 'John Doe',
      email: email,
    );
    state = user; // Update state
  }

  void logout() {
    state = null; // Clear user state
  }
}
```

#### 📁 views/
**Purpose**: UI screens and pages.

```dart:lib/views/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {  // ConsumerWidget for Riverpod
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the user state
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: Text('Please login'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Name: ${user.name}'),
                  Text('Email: ${user.email}'),
                  ElevatedButton(
                    onPressed: () => ref.read(userProvider.notifier).logout(),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
    );
  }
}
```

#### 📁 services/
**Purpose**: Handle external data sources (APIs, databases, etc.).

```dart:lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.example.com';

  // Simulate API call to get user data
  Future<UserModel> fetchUser(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UserModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Simulate login API call
  Future<String> login(String email, String password) async {
    // In real app, this would make HTTP request
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    if (email == 'test@example.com' && password == 'password') {
      return 'fake-jwt-token';
    } else {
      throw Exception('Invalid credentials');
    }
  }
}
```

#### 📁 utils/
**Purpose**: Utility functions and helper classes.

```dart:lib/utils/date_formatter.dart
class DateFormatter {
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }
}
```

#### 📁 widgets/
**Purpose**: Reusable UI components.

```dart:lib/widgets/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
```

#### 📁 config/
**Purpose**: App configuration, themes, and routing.

```dart:lib/config/routes/app_routes.dart
class AppRoutes {
  static const String home = '/';
  static const String profile = '/profile';
  static const String settings = '/settings';
}
```

```dart:lib/config/themes/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.grey[900],
    ),
  );
}
```

## How Data Flows in MVVM

1. **User interacts with View** (taps button, enters text)
2. **View notifies ViewModel** about the interaction
3. **ViewModel processes the logic** (validates data, calls services)
4. **ViewModel updates Model** or internal state
5. **ViewModel notifies View** about state changes
6. **View re-renders** to reflect the new state

## Riverpod State Management

Riverpod is our state management solution. Key concepts:

### Providers
- **Provider**: Simple values
- **StateNotifierProvider**: Complex state with methods
- **FutureProvider**: Async operations
- **StreamProvider**: Stream data

### Reading Providers
```dart
// Method 1: ConsumerWidget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);  // Automatically rebuilds on change
    return Text(user?.name ?? 'No user');
  }
}

// Method 2: HookWidget (with flutter_hooks)
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final user = useProvider(userProvider);  // Hook-based
    return Text(user?.name ?? 'No user');
  }
}
```

## Best Practices

1. **Keep Views Dumb**: Views should only display data and handle user input
2. **Business Logic in ViewModels**: All logic goes here, not in widgets
3. **Models Immutable**: Don't modify model instances directly
4. **Single Responsibility**: Each class should do one thing well
5. **Dependency Injection**: Use providers to inject dependencies

## Practice Exercise

Try creating:
1. A new model for "Product" with id, name, price, description
2. A ViewModel provider for managing a list of products
3. A View that displays the product list
4. A Service that simulates fetching products from an API

## What's Next?

In the next guide, we'll dive deep into Flutter widgets - the building blocks of every UI component!
