import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/workout_provider.dart';
import 'screens/home_screen.dart';
void main() {
  runApp(const TwoDaySplitApp());
}
class TwoDaySplitApp extends StatelessWidget {
  const TwoDaySplitApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutProvider()..init(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '2‑Day Split',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const
          Color(0xFF6C5CE7)),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}