import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/login/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi App TFG',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
