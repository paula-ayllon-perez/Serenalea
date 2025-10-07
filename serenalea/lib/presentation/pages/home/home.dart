
import 'package:flutter/material.dart';
import '../../widgets/main_drawer.dart';
import '../../../data/models/activity_dto.dart';
import '../../../data/repositories/activity_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _insertDefaultActivitiesIfNeeded();
  }

  void _insertDefaultActivitiesIfNeeded() async {
    final repo = ActivityRepository();
    final activities = await repo.getAllActivities();

    // Mindfulness respiración
    final existsMind = activities.any((a) => a.category.toLowerCase() == 'mindfulness' || a.title.toLowerCase().contains('mindfulness'));
    if (!existsMind) {
      final mindActivity = Activity(
        id: '',
        title: 'Respiración Mindfulness',
        description: 'Actividad guiada de respiración con animaciones relajantes.',
        suitableProfiles: ['Todos'],
        duration: 5,
        score: 8,
        category: 'mindfulness',
      );
      await repo.addActivity(mindActivity);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      drawer: const MainDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¡Bienvenido a la página de inicio!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('Ver actividades'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 4,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/activities');
              },
            ),
          ],
        ),
      ),
    );
  }
}
