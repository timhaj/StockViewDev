import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const StockViewApp());
}

class StockViewApp extends StatelessWidget {
  const StockViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StockView',
      home: const HomeScreen(),
    );
  }
}
