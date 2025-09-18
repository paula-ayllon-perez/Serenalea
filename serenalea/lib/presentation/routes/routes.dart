import 'package:flutter/material.dart';
import 'package:serenalea/presentation/pages/home/home.dart';
import 'package:serenalea/presentation/pages/activities/all_activities.dart';
import '../pages/login/login.dart';
import '../pages/register/register.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/': (context) => const HomePage(),
  '/home': (context) => const HomePage(),
  '/activities': (context) => const AllActivitiesPage(),
};