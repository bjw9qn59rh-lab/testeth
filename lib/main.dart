import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ETHApp());
}

class ETHApp extends StatelessWidget {
  const ETHApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETH Zeiterfassung',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC62828)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFC62828),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
