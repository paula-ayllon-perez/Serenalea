import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:serenalea/firebase_options.dart';
import 'package:serenalea/presentation/pages/register/register.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/login/login.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: const RegisterPage(),
    ); 
  }
}
