import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/layout/mainapp.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartGuard | 골든타임 구조 플랫폼',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      home: MainApp(),
    );
  }
}
