import 'package:flutter/material.dart';
import 'package:serenalea/presentation/pages/home/home.dart';
import '../pages/login/login.dart';
import '../pages/register/register.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/': (context) => const HomePage(),
  '/home': (context) => const HomePage(),
  // Agrega más rutas aquí
};