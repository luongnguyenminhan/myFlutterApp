# 06 - Navigation & Routing in Flutter

## Why Navigation Matters

Navigation allows users to move between different screens in your app. Good navigation creates intuitive user experiences and organizes your app's content logically.

## Navigation Basics

### The Navigator Widget

Flutter uses a `Navigator` widget that manages a stack of routes (screens). Think of it as a stack of cards where:

- **Push**: Add a new screen on top
- **Pop**: Remove the top screen
- **Replace**: Replace current screen with new one

```dart:lib/views/navigation_demo.dart
class NavigationDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to a new screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SecondScreen(),
                  ),
                );
              },
              child: const Text('Go to Second Screen'),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                // Navigate with named route
                Navigator.of(context).pushNamed('/second');
              },
              child: const Text('Go to Second Screen (Named)'),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                // Go back
                Navigator.of(context).pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
        // Back button is automatically added
      ),
      body: const Center(
        child: Text('This is the second screen!'),
      ),
    );
  }
}
```

## Named Routes (Recommended)

Named routes are more maintainable and allow for deep linking. Define them in your MaterialApp:

### 1. Define Routes

```dart:lib/config/routes/app_router.dart
import 'package:flutter/material.dart';
import '../../views/home_screen.dart';
import '../../views/profile_screen.dart';
import '../../views/settings_screen.dart';
import '../../views/todo_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String todos = '/todos';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
      profile: (context) => const ProfileScreen(),
      settings: (context) => const SettingsScreen(),
      todos: (context) => const TodoScreen(),
    };
  }

  // For routes that need arguments
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/todo-detail':
        final todoId = settings.arguments as String?;
        if (todoId != null) {
          return MaterialPageRoute(
            builder: (context) => TodoDetailScreen(todoId: todoId),
          );
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Route not found!'),
        ),
      ),
    );
  }
}
```

### 2. Setup in main.dart

```dart:lib/main.dart
import 'package:flutter/material.dart';
import 'config/routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRouter.home,  // Starting route
      routes: AppRouter.routes,      // Named routes
      onGenerateRoute: AppRouter.generateRoute,  // Dynamic routes
    );
  }
}
```

### 3. Navigate Using Named Routes

```dart:lib/widgets/navigation_buttons.dart
class NavigationButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRouter.profile);
          },
          child: const Text('Go to Profile'),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRouter.todos);
          },
          child: const Text('Go to Todos'),
        ),

        ElevatedButton(
          onPressed: () {
            // Navigate with arguments
            Navigator.of(context).pushNamed(
              '/todo-detail',
              arguments: 'todo-123',
            );
          },
          child: const Text('View Todo Details'),
        ),

        ElevatedButton(
          onPressed: () {
            // Replace current screen
            Navigator.of(context).pushReplacementNamed(AppRouter.settings);
          },
          child: const Text('Go to Settings (Replace)'),
        ),
      ],
    );
  }
}
```

## Bottom Navigation Bar

For apps with multiple main sections, use a BottomNavigationBar:

```dart:lib/views/main_navigation_screen.dart
import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // List of screens/widgets for each tab
  static const List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],  // Show selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,  // All items visible
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
```

## Tab Navigation

For content that can be categorized into tabs:

```dart:lib/views/tabbed_screen.dart
import 'package:flutter/material.dart';

class TabbedScreen extends StatelessWidget {
  const TabbedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,  // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tabs Demo'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car), text: 'Car'),
              Tab(icon: Icon(Icons.directions_transit), text: 'Transit'),
              Tab(icon: Icon(Icons.directions_bike), text: 'Bike'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CarTab(),
            TransitTab(),
            BikeTab(),
          ],
        ),
      ),
    );
  }
}

class CarTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Car transportation'));
  }
}

class TransitTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Public transit'));
  }
}

class BikeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Bicycle routes'));
  }
}
```

## Drawer Navigation

For apps with many sections or settings:

```dart:lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import '../config/routes/app_router.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'App Name',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          // Menu items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(AppRouter.home);
            },
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(AppRouter.profile);
            },
          ),

          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Todos'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(AppRouter.todos);
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(AppRouter.settings);
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Handle logout
              Navigator.of(context).pushReplacementNamed(AppRouter.home);
            },
          ),
        ],
      ),
    );
  }
}

// Use in your scaffold
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        // Add hamburger menu button
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const AppDrawer(),  // Add drawer here
      body: const Center(child: Text('Home Screen')),
    );
  }
}
```

## Passing Data Between Screens

### Method 1: Constructor Parameters

```dart:lib/views/todo_detail_screen.dart
class TodoDetailScreen extends StatelessWidget {
  final String todoId;

  const TodoDetailScreen({super.key, required this.todoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo: $todoId')),
      body: Center(
        child: Text('Details for todo: $todoId'),
      ),
    );
  }
}

// Navigate with data
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => TodoDetailScreen(todoId: '123'),
  ),
);
```

### Method 2: Route Arguments

```dart:lib/views/product_detail_screen.dart
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments passed to this route
    final productId = ModalRoute.of(context)!.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Center(
        child: Text('Product ID: ${productId ?? 'Unknown'}'),
      ),
    );
  }
}

// Navigate with arguments
Navigator.of(context).pushNamed('/product-detail', arguments: 'product-456');
```

### Method 3: Returning Data from Screens

```dart:lib/views/select_color_screen.dart
class SelectColorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Color')),
      body: GridView.count(
        crossAxisCount: 3,
        children: [
          _ColorOption(color: Colors.red, onTap: () => Navigator.of(context).pop(Colors.red)),
          _ColorOption(color: Colors.blue, onTap: () => Navigator.of(context).pop(Colors.blue)),
          _ColorOption(color: Colors.green, onTap: () => Navigator.of(context).pop(Colors.green)),
        ],
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _ColorOption({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Usage - navigate and wait for result
Future<void> _selectColor(BuildContext context) async {
  final selectedColor = await Navigator.of(context).push<Color>(
    MaterialPageRoute(builder: (context) => const SelectColorScreen()),
  );

  if (selectedColor != null) {
    // Use the selected color
    print('Selected color: $selectedColor');
  }
}
```

## Advanced Navigation Patterns

### Nested Navigation

For complex apps with nested navigators:

```dart:lib/views/nested_navigation.dart
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar navigation
          Container(
            width: 250,
            color: Colors.grey[200],
            child: Column(
              children: [
                ListTile(
                  title: const Text('Dashboard'),
                  onTap: () {
                    // Navigate in the main area
                  },
                ),
                ListTile(
                  title: const Text('Users'),
                  onTap: () {
                    // Navigate in the main area
                  },
                ),
              ],
            ),
          ),

          // Main content area with its own navigator
          Expanded(
            child: Navigator(
              key: _mainNavigatorKey,
              onGenerateRoute: (settings) {
                // Handle routes for main content
                return MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### Deep Linking

Handle external links that open specific screens:

```dart:lib/config/routes/deep_link_handler.dart
class DeepLinkHandler {
  static void handleDeepLink(BuildContext context, Uri uri) {
    switch (uri.path) {
      case '/profile':
        Navigator.of(context).pushNamed(AppRouter.profile);
        break;
      case '/todos':
        final todoId = uri.queryParameters['id'];
        if (todoId != null) {
          Navigator.of(context).pushNamed('/todo-detail', arguments: todoId);
        } else {
          Navigator.of(context).pushNamed(AppRouter.todos);
        }
        break;
      default:
        Navigator.of(context).pushNamed(AppRouter.home);
    }
  }
}

// Handle deep links in main.dart
void main() {
  // Listen for incoming links
  // (Platform specific implementation needed)

  runApp(const MyApp());
}
```

## Navigation Best Practices

### 1. Consistent Navigation
- Use the same navigation pattern throughout your app
- Keep navigation predictable for users

### 2. Handle Back Button
```dart:lib/views/form_screen.dart
class FormScreen extends StatefulWidget {
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  bool _hasUnsavedChanges = false;

  // Handle Android back button
  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('You have unsaved changes. Do you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Stay
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Leave
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true; // Allow navigation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // Your form UI
      ),
    );
  }
}
```

### 3. Loading States During Navigation

```dart:lib/widgets/navigation_with_loading.dart
class NavigationWithLoading extends StatelessWidget {
  final String routeName;
  final Object? arguments;
  final String buttonText;

  const NavigationWithLoading({
    super.key,
    required this.routeName,
    this.arguments,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Simulate loading
        await Future.delayed(const Duration(seconds: 1));

        // Hide loading and navigate
        if (mounted) {
          Navigator.of(context).pop(); // Hide loading
          Navigator.of(context).pushNamed(routeName, arguments: arguments);
        }
      },
      child: Text(buttonText),
    );
  }
}
```

### 4. Navigation Guards

```dart:lib/widgets/navigation_guard.dart
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isLoggedIn = ref.watch(authProvider);

        if (!isLoggedIn) {
          // Redirect to login if not authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return child;
      },
    );
  }
}

// Use in routes
final routes = {
  '/protected': (context) => AuthGuard(
    child: const ProtectedScreen(),
  ),
};
```

## Practice Exercises

### Exercise 1: Tabbed App
Create an app with bottom tabs for:
- Home feed
- Search screen
- Notifications
- Profile

### Exercise 2: Master-Detail Navigation
Build a list screen that navigates to detail screens:
- Product list → Product detail
- Todo list → Todo detail with edit capability

### Exercise 3: Authentication Flow
Implement login/logout flow:
- Login screen
- Protected screens with auth guard
- Auto-redirect after login

## What's Next?

In our final guide, we'll learn how to run and deploy your Flutter app across different platforms!
