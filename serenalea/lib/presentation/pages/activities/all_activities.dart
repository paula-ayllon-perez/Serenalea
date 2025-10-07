import 'package:flutter/material.dart';
import '../../../data/models/activity_dto.dart';
import '../../../data/repositories/activity_repository.dart';

import 'activity/walk_activity.dart';
import 'activity/mindfullness_activity.dart';


class AllActivitiesPage extends StatefulWidget {
  const AllActivitiesPage({Key? key}) : super(key: key);

  @override
  State<AllActivitiesPage> createState() => _AllActivitiesPageState();
}

class _AllActivitiesPageState extends State<AllActivitiesPage> {
  final ActivityRepository _activityRepository = ActivityRepository();
  late Future<List<Activity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _activityRepository.getAllActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todas las actividades')),
      body: FutureBuilder<List<Activity>>(
        future: _activitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay actividades disponibles.'));
          }
          final activities = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (activity.category.toLowerCase() == 'walk' || activity.title.toLowerCase().contains('paseo')) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalkActivityPage()),
                    );
                  } else if (activity.category.toLowerCase() == 'mindfulness' || activity.title.toLowerCase().contains('mindfulness')) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MindfulnessActivityPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Actividad aún no implementada.')),
                    );
                  }
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text(activity.description),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(label: Text('Perfiles: ${activity.suitableProfiles.join(", ")}')),
                            Chip(label: Text('Duración: ${activity.duration}')),
                            Chip(label: Text('Puntuación: ${activity.score}')),
                            Chip(label: Text('Categoría: ${activity.category}')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
