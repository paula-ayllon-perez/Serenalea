import 'package:flutter/material.dart';
import 'package:serenalea/presentation/pages/home/home.dart';
import 'package:serenalea/presentation/pages/activities/all_activities.dart';
import '../pages/login/login.dart';
import '../pages/register/register.dart';
import '../pages/activities/activity/creative_actovity.dart';
import '../pages/profile/profile.dart';
import '../pages/activities/activity/observing_activity.dart';
import '../pages/activities/random_activites.dart';
import '../pages/register/register_assessment.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/': (context) => const HomePage(),
  '/home': (context) => const HomePage(),
  '/activities': (context) => const AllActivitiesPage(),
  '/creative': (context) => const CreativeActivityPage(),
  '/observing': (context) => const ObservingActivityPage(),
  '/profile': (context) => const ProfilePage(),
  '/random-activities': (context) => const RandomActivitiesPage(),
  '/all-activities': (context) => const AllActivitiesPage(),
  '/register-assessment': (context) => const RegisterAssessmentPage(),
  '/search': (context) => Scaffold(
    appBar: AppBar(title: const Text('Buscar')),
    body: const Center(child: Text('Función de búsqueda próximamente')), // Placeholder
  ),
};