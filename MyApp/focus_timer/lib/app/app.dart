import 'package:flutter/material.dart';

import '../services/app_bootstrap.dart';

class KalLogAppRoot extends StatelessWidget {
  const KalLogAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ApnaFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2E8D5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
          background: const Color(0xFFF2E8D5),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.brown,
          unselectedItemColor: Colors.white70,
        ),
      ),
      home: const AppBootstrap(),
    );
  }
}
