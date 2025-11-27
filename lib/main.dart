import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(  // Required for Riverpod state management
      child: MaterialApp(
        title: 'Todo App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          // Clean theme following UI design principles
          scaffoldBackgroundColor: Colors.grey[50],
          cardColor: Colors.white,
          dividerColor: Colors.grey[300],
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
