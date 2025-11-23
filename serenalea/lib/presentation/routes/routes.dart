import 'package:flutter/material.dart';
import 'package:serenalea/presentation/pages/home/home.dart';
import '../pages/login/login.dart';
import '../pages/register/register.dart';
import '../pages/profile/profile.dart';
import '../pages/activities/random_activites.dart';
import '../pages/register/register_assessment.dart';
import '../pages/profile/photo_album.dart';
import '../pages/profile/change_password.dart';
import '../pages/diary/diary_page.dart';
import '../widgets/auth_guard.dart';
import 'activity_routes.dart';

final Map<String, WidgetBuilder> appRoutes = {
  // Rutas públicas (no requieren autenticación)
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/register-assessment': (context) => const RegisterAssessmentPage(),
  
  // Rutas protegidas (requieren autenticación)
  '/': (context) => const AuthGuard(child: HomePage()),
  '/home': (context) => const AuthGuard(child: HomePage()),
  '/profile': (context) => const AuthGuard(child: ProfilePage()),
  '/photo-album': (context) => const AuthGuard(child: PhotoAlbumPage()),
  '/change-password': (context) => const AuthGuard(child: ChangePasswordPage()),
  '/random-activities': (context) => const AuthGuard(child: RandomActivitiesPage()),
  '/diary': (context) => const AuthGuard(child: DiaryPage()),
  '/statistics': (context) => AuthGuard(
    child: Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: const Center(child: Text('Estadísticas próximamente')), // Placeholder
    ),
  ),
  
  // Actividades (se importan desde activity_routes.dart) - también protegidas
  ...activityRoutes.map((key, value) => MapEntry(
    key, 
    (context) => AuthGuard(child: value(context)),
  )),
};