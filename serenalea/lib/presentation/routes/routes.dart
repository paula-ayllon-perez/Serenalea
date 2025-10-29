import 'package:flutter/material.dart';
import 'package:serenalea/presentation/pages/home/home.dart';
import '../pages/login/login.dart';
import '../pages/register/register.dart';
import '../pages/profile/profile.dart';
import '../pages/activities/random_activites.dart';
import '../pages/register/register_assessment.dart';
import 'activity_routes.dart';

final Map<String, WidgetBuilder> appRoutes = {
  // Actividades (se importan desde activity_routes.dart)
  ...activityRoutes,

  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/': (context) => const HomePage(),
  '/home': (context) => const HomePage(),
  '/profile': (context) => const ProfilePage(),
  '/random-activities': (context) => const RandomActivitiesPage(),
  '/register-assessment': (context) => const RegisterAssessmentPage(),
  '/search': (context) => Scaffold(
    appBar: AppBar(title: const Text('Buscar')),
    body: const Center(child: Text('Función de búsqueda próximamente')), // Placeholder
  ),
};