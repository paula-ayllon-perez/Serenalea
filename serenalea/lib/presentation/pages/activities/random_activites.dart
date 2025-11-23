import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../data/models/activity_dto.dart';
import 'activity/generic_activity_page.dart';
import '../../widgets/main_drawer.dart';
import 'dart:math';

class RandomActivitiesPage extends StatefulWidget {
  const RandomActivitiesPage({Key? key}) : super(key: key);

  @override
  State<RandomActivitiesPage> createState() => _RandomActivitiesPageState();
}

class _RandomActivitiesPageState extends State<RandomActivitiesPage> {
  final ActivityRepository _activityRepo = ActivityRepository();
  final Random _random = Random();
  Activity? _currentActivity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRandomActivity();
  }

  Future<void> _loadRandomActivity() async {
    setState(() => _isLoading = true);
    
    try {
      final activities = await _activityRepo.getAllActivities();
      if (activities.isNotEmpty) {
        final randomIndex = _random.nextInt(activities.length);
        setState(() {
          _currentActivity = activities[randomIndex];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showNextActivity() {
    _loadRandomActivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividad Aleatoria'),
        backgroundColor: AppColors.color1,
      ),
      bottomNavigationBar: const MainBottomBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentActivity == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: AppColors.color3),
                      const SizedBox(height: 16),
                      const Text('No hay actividades disponibles'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showNextActivity,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: GenericActivityPage(
                        activity: _currentActivity!,
                        categoryName: 'Aleatoria',
                        categoryColor: AppColors.color2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.shuffle_rounded),
                        label: const Text('Siguiente actividad'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          backgroundColor: AppColors.color2,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _showNextActivity,
                      ),
                    ),
                  ],
                ),
    );
  }
}
