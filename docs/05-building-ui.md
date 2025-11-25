# 05 - Building Complete UI Screens

## Let's Build Real Features!

Now we'll combine widgets, state management, and MVVM architecture to build complete, functional screens. Each example includes the full implementation with comments.

## Feature 1: Todo List App

### 1. Create the Model

```dart:lib/models/todo_model.dart
class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Create a copy with some fields changed
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to/from JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
```

### 2. Create the ViewModel (Provider)

```dart:lib/view_models/providers/todo_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo_model.dart';

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]); // Start with empty list

  // Add a new todo
  void addTodo(String title, String description) {
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID generation
      title: title,
      description: description,
    );
    state = [...state, newTodo]; // Create new list with added item
  }

  // Toggle completion status
  void toggleTodo(String id) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(isCompleted: !todo.isCompleted);
      }
      return todo;
    }).toList();
  }

  // Delete a todo
  void deleteTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  // Edit a todo
  void editTodo(String id, String newTitle, String newDescription) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(
          title: newTitle,
          description: newDescription,
        );
      }
      return todo;
    }).toList();
  }

  // Get filtered todos
  List<Todo> getCompletedTodos() {
    return state.where((todo) => todo.isCompleted).toList();
  }

  List<Todo> getPendingTodos() {
    return state.where((todo) => !todo.isCompleted).toList();
  }
}

// Create the provider
final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

// Filtered providers for performance
final completedTodosProvider = Provider<List<Todo>>((ref) {
  return ref.watch(todoProvider.notifier).getCompletedTodos();
});

final pendingTodosProvider = Provider<List<Todo>>((ref) {
  return ref.watch(todoProvider.notifier).getPendingTodos();
});
```

### 3. Create the View (UI)

```dart:lib/views/todo_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/providers/todo_provider.dart';
import '../models/todo_model.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _showCompleted = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addTodo() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isNotEmpty) {
      ref.read(todoProvider.notifier).addTodo(title, description);
      _titleController.clear();
      _descriptionController.clear();
      Navigator.of(context).pop(); // Close dialog
    }
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'What needs to be done?',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Additional details...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addTodo,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoProvider);
    final pendingTodos = ref.watch(pendingTodosProvider);
    final completedTodos = ref.watch(completedTodosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(_showCompleted ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showCompleted = !_showCompleted;
              });
            },
            tooltip: _showCompleted ? 'Hide completed' : 'Show completed',
          ),
        ],
      ),
      body: todos.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checklist, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No todos yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Tap the + button to add one',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: pendingTodos.length + (_showCompleted ? completedTodos.length : 0),
              itemBuilder: (context, index) {
                final todo = index < pendingTodos.length
                    ? pendingTodos[index]
                    : completedTodos[index - pendingTodos.length];

                return TodoItemWidget(
                  todo: todo,
                  onToggle: () => ref.read(todoProvider.notifier).toggleTodo(todo.id),
                  onDelete: () => ref.read(todoProvider.notifier).deleteTodo(todo.id),
                  onEdit: () => _showEditDialog(todo),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).cardColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('${pendingTodos.length} pending'),
            Text('${completedTodos.length} completed'),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Todo todo) {
    final titleController = TextEditingController(text: todo.title);
    final descController = TextEditingController(text: todo.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(todoProvider.notifier).editTodo(
                todo.id,
                titleController.text,
                descController.text,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Separate widget for better performance and reusability
class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: todo.description.isNotEmpty
            ? Text(
                todo.description,
                style: TextStyle(
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  color: todo.isCompleted ? Colors.grey : null,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
        onTap: onToggle, // Tap anywhere to toggle
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
```

## Feature 2: User Profile Screen

### Model
```dart:lib/models/user_profile.dart
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String bio;
  final String avatarUrl;
  final DateTime joinDate;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.bio = '',
    this.avatarUrl = '',
    DateTime? joinDate,
  }) : joinDate = joinDate ?? DateTime.now();

  UserProfile copyWith({
    String? name,
    String? email,
    String? bio,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinDate: joinDate,
    );
  }
}
```

### Provider
```dart:lib/view_models/providers/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';

class ProfileNotifier extends StateNotifier<UserProfile?> {
  ProfileNotifier() : super(null);

  // Simulate login
  void login() {
    state = UserProfile(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      bio: 'Flutter developer passionate about building beautiful apps',
      avatarUrl: 'https://example.com/avatar.jpg',
    );
  }

  void logout() {
    state = null;
  }

  void updateProfile({
    String? name,
    String? email,
    String? bio,
  }) {
    if (state != null) {
      state = state!.copyWith(
        name: name,
        email: email,
        bio: bio,
      );
    }
  }

  Future<void> saveProfile() async {
    // Simulate API call to save profile
    await Future.delayed(const Duration(seconds: 1));
    // In real app, this would save to backend
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) {
  return ProfileNotifier();
});

// Loading state for save operations
final savingProfileProvider = StateProvider<bool>((ref) => false);
```

### View
```dart:lib/views/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers when profile loads
    final profile = ref.read(profileProvider);
    if (profile != null) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _bioController.text = profile.bio;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _saveProfile() async {
    ref.read(savingProfileProvider.notifier).state = true;

    try {
      await ref.read(profileProvider.notifier).saveProfile();
      ref.read(profileProvider.notifier).updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        bio: _bioController.text,
      );

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      ref.read(savingProfileProvider.notifier).state = false;
    }
  }

  void _cancelEditing() {
    final profile = ref.read(profileProvider);
    if (profile != null) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _bioController.text = profile.bio;
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final isSaving = ref.watch(savingProfileProvider);

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Not logged in'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(profileProvider.notifier).login(),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelEditing,
              tooltip: 'Cancel',
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _startEditing,
              tooltip: 'Edit Profile',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(profileProvider.notifier).logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 60,
              backgroundImage: profile.avatarUrl.isNotEmpty
                  ? NetworkImage(profile.avatarUrl)
                  : null,
              child: profile.avatarUrl.isEmpty
                  ? Text(
                      profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32),
                    )
                  : null,
            ),

            const SizedBox(height: 24),

            // Name
            if (_isEditing)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              )
            else
              Text(
                profile.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

            const SizedBox(height: 16),

            // Email
            if (_isEditing)
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.email, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    profile.email,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Bio section
            const Text(
              'Bio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_isEditing)
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                  hintText: 'Tell us about yourself...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  profile.bio.isNotEmpty ? profile.bio : 'No bio yet',
                  style: TextStyle(
                    color: profile.bio.isNotEmpty ? null : Colors.grey,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Join date
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Joined ${profile.joinDate.toString().split(' ')[0]}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Save button (only show when editing)
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Profile'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

## Feature 3: Settings Screen with Theme Toggle

### Provider
```dart:lib/view_models/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemeModeOption { system, light, dark }

class Settings {
  final ThemeModeOption themeMode;
  final bool notificationsEnabled;
  final String language;

  Settings({
    this.themeMode = ThemeModeOption.system,
    this.notificationsEnabled = true,
    this.language = 'en',
  });

  Settings copyWith({
    ThemeModeOption? themeMode,
    bool? notificationsEnabled,
    String? language,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
    );
  }
}

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(Settings());

  void setThemeMode(ThemeModeOption themeMode) {
    state = state.copyWith(themeMode: themeMode);
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }

  void setLanguage(String language) {
    state = state.copyWith(language: language);
  }

  ThemeMode getThemeMode() {
    switch (state.themeMode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
      default:
        return ThemeMode.system;
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});

// Computed provider for actual theme mode
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider.notifier).getThemeMode();
});
```

### View
```dart:lib/views/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme Section
          const _SectionHeader(title: 'Appearance'),
          _ThemeSelector(
            currentTheme: settings.themeMode,
            onThemeChanged: (theme) {
              ref.read(settingsProvider.notifier).setThemeMode(theme);
            },
          ),

          const Divider(),

          // Notifications Section
          const _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive app notifications'),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleNotifications();
            },
          ),

          const Divider(),

          // Language Section
          const _SectionHeader(title: 'Language'),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(_getLanguageName(settings.language)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(context, ref),
          ),

          const Divider(),

          // About Section
          const _SectionHeader(title: 'About'),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () {
              // Navigate to privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy policy not implemented yet')),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              code: 'en',
              name: 'English',
              onSelected: () {
                ref.read(settingsProvider.notifier).setLanguage('en');
                Navigator.of(context).pop();
              },
            ),
            _LanguageOption(
              code: 'es',
              name: 'Español',
              onSelected: () {
                ref.read(settingsProvider.notifier).setLanguage('es');
                Navigator.of(context).pop();
              },
            ),
            _LanguageOption(
              code: 'fr',
              name: 'Français',
              onSelected: () {
                ref.read(settingsProvider.notifier).setLanguage('fr');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeModeOption currentTheme;
  final ValueChanged<ThemeModeOption> onThemeChanged;

  const _ThemeSelector({
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('System Theme'),
          leading: Radio<ThemeModeOption>(
            value: ThemeModeOption.system,
            groupValue: currentTheme,
            onChanged: (value) => onThemeChanged(value!),
          ),
          onTap: () => onThemeChanged(ThemeModeOption.system),
        ),
        ListTile(
          title: const Text('Light Theme'),
          leading: Radio<ThemeModeOption>(
            value: ThemeModeOption.light,
            groupValue: currentTheme,
            onChanged: (value) => onThemeChanged(value!),
          ),
          onTap: () => onThemeChanged(ThemeModeOption.light),
        ),
        ListTile(
          title: const Text('Dark Theme'),
          leading: Radio<ThemeModeOption>(
            value: ThemeModeOption.dark,
            groupValue: currentTheme,
            onChanged: (value) => onThemeChanged(value!),
          ),
          onTap: () => onThemeChanged(ThemeModeOption.dark),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String code;
  final String name;
  final VoidCallback onSelected;

  const _LanguageOption({
    required this.code,
    required this.name,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      onTap: onSelected,
    );
  }
}
```

## Practice Exercises

### Exercise 1: Product Catalog
Build a screen that displays:
- List of products with images, names, prices
- Search/filter functionality
- Add to cart functionality
- Product detail screen

### Exercise 2: Weather App
Create an app that shows:
- Current weather for user's location
- 5-day forecast
- Weather icons and animations
- Settings for temperature units

### Exercise 3: Note Taking App
Implement features for:
- Creating and editing notes
- Categorizing notes
- Search functionality
- Sync with cloud storage

## What's Next?

In the next guide, we'll learn about navigation between screens and routing in Flutter apps!
