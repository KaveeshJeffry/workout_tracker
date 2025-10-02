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
    // Accent (you can tweak this)
    const seed = Color(0xFF6C5CE7);

    // Build a dark scheme, then force near-black surfaces
    final baseDark = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    final blackScheme = baseDark.copyWith(
      surface: Colors.black,
      background: Colors.black,
      // keep contrasty containers for cards/sheets/dialogs
      surfaceVariant: const Color(0xFF121212),
      primaryContainer: const Color(0xFF101010),
      secondaryContainer: const Color(0xFF0D0D0D),
      outline: const Color(0xFF2A2A2A),
      outlineVariant: const Color(0xFF2A2A2A),
    );

    return ChangeNotifierProvider(
      create: (_) => WorkoutProvider()..init(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '2-Day Split',
        themeMode: ThemeMode.dark, // force dark/black
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: blackScheme,
          scaffoldBackgroundColor: Colors.black,
          canvasColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: const CardTheme(
            color: Colors.black,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.black,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),
          dialogTheme: const DialogTheme(
            backgroundColor: Color(0xFF0E0E0E),
            surfaceTintColor: Colors.transparent,
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color(0xFF111111),
            contentTextStyle: TextStyle(color: Colors.white),
            behavior: SnackBarBehavior.floating,
          ),
          tabBarTheme: TabBarTheme(
            dividerColor: Colors.transparent,
            unselectedLabelColor: const Color(0xFF9E9E9E),
            labelColor: Colors.black,
            indicator: BoxDecoration(
              color: seed,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: seed,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // (Optional) you can still define a light theme, but we force dark anyway.
        home: const HomeScreen(),
      ),
    );
  }
}
