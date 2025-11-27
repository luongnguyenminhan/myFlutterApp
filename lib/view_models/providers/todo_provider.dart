import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo_model.dart';

/// StateNotifier that manages the list of todos
/// This is our ViewModel in MVVM pattern
class TodoNotifier extends StateNotifier<List<Todo>> {
  /// Constructor - starts with empty list
  TodoNotifier() : super([]);

  /// Add a new todo to the list
  void addTodo(String title, String description) {
    // Validate input
    if (title.trim().isEmpty) return;

    // Create new todo with unique ID
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      createdAt: DateTime.now(),
    );

    // Update state by creating new list (immutable pattern)
    state = [...state, newTodo];
  }

  /// Toggle completion status of a todo
  void toggleTodo(String id) {
    state = state.map((todo) {
      // Find the todo with matching ID and toggle its completion status
      if (todo.id == id) {
        return todo.copyWith(isCompleted: !todo.isCompleted);
      }
      return todo; // Return unchanged todos
    }).toList();
  }

  /// Delete a todo from the list
  void deleteTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  /// Update an existing todo
  void updateTodo(String id, String newTitle, String newDescription) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(
          title: newTitle.trim(),
          description: newDescription.trim(),
        );
      }
      return todo;
    }).toList();
  }

  /// Get only completed todos
  List<Todo> get completedTodos {
    return state.where((todo) => todo.isCompleted).toList();
  }

  /// Get only pending (not completed) todos
  List<Todo> get pendingTodos {
    return state.where((todo) => !todo.isCompleted).toList();
  }

  /// Get total count of todos
  int get totalCount => state.length;

  /// Get count of completed todos
  int get completedCount => completedTodos.length;

  /// Get count of pending todos
  int get pendingCount => pendingTodos.length;

  /// Clear all completed todos
  void clearCompleted() {
    state = pendingTodos;
  }

  /// Clear all todos
  void clearAll() {
    state = [];
  }
}

/// Riverpod provider for TodoNotifier
/// This is what widgets will use to access the ViewModel
final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

/// Computed providers for specific todo lists
/// These automatically update when the main todo list changes

final completedTodosProvider = Provider<List<Todo>>((ref) {
  return ref.watch(todoProvider.notifier).completedTodos;
});

final pendingTodosProvider = Provider<List<Todo>>((ref) {
  return ref.watch(todoProvider.notifier).pendingTodos;
});

/// Computed providers for counts
/// These automatically update when todos change

final totalTodosCountProvider = Provider<int>((ref) {
  return ref.watch(todoProvider.notifier).totalCount;
});

final completedTodosCountProvider = Provider<int>((ref) {
  return ref.watch(todoProvider.notifier).completedCount;
});

final pendingTodosCountProvider = Provider<int>((ref) {
  return ref.watch(todoProvider.notifier).pendingCount;
});
