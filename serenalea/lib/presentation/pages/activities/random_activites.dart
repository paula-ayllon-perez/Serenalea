import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../data/models/activity_dto.dart';
import '../../widgets/main_drawer.dart';
import 'dart:math';
import 'activity/random_activity_widget.dart';

// Resumen rápido y justificación 🎯
// Resumen (30s): Página que muestra actividades aleatorias para que el usuario las complete o salte; carga actividades desde el repositorio, muestra un contador de completadas y feedback inmediato (SnackBar) tras completar cada actividad.
//
// Justificación de diseño:
// - Enfoque en la acción: presentar una actividad a la vez reduce la fricción y facilita la toma de acción por parte del usuario.
// - Refuerzo positivo y continuidad: el contador y los SnackBars refuerzan el comportamiento (completar actividades) y motivan a seguir usando la función.
// - Simplicidad para iterar: la selección aleatoria en cliente permite un desarrollo y pruebas rápidos; está documentada para poder optimizarse (p. ej., prefetch, criterios de personalización) cuando las métricas lo indiquen.
// - Feedback y accesibilidad: mensajes claros y tiempos cortos (delay antes de la siguiente actividad) ofrecen una experiencia fluida y comprensible para diferentes perfiles de usuario.

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
  int _completedCount = 0;

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

  void _onActivityCompleted() {
    setState(() {
      _completedCount++;
    });
    
    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Actividad $_completedCount completada! 🎉',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Cargar siguiente actividad automáticamente después de 1.5 segundos
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _loadRandomActivity();
      }
    });
  }

  void _skipActivity() {
    _loadRandomActivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shuffle_rounded, size: 24),
            const SizedBox(width: 8),
            const Text('Actividades Aleatorias'),
            const Spacer(),
            if (_completedCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '$_completedCount',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        backgroundColor: AppColors.color2,
      ),
      bottomNavigationBar: const MainBottomBar(),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.color2,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Cargando actividad...',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.color3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : _currentActivity == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: AppColors.color3.withOpacity(0.5),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No hay actividades disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.color1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Por favor, intenta más tarde',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.color3,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            backgroundColor: AppColors.color2,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _skipActivity,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: RandomActivityWidget(
                        key: ValueKey(_currentActivity!.id),
                        activity: _currentActivity!,
                        onCompleted: _onActivityCompleted,
                      ),
                    ),
                    // Botón flotante para saltar actividad
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.skip_next, size: 20),
                                  label: const Text('Saltar actividad'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    foregroundColor: AppColors.color3,
                                    side: BorderSide(
                                      color: AppColors.color3.withOpacity(0.3),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _skipActivity,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
