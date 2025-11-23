import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_dto.dart';

class ActivityFirestoreService {
  final CollectionReference _activitiesCollection = FirebaseFirestore.instance.collection('activities');

  // Obtener todas las actividades
  Future<List<Activity>> getAllActivities() async {
    final snapshot = await _activitiesCollection.get();
    return snapshot.docs
        .map((doc) => Activity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Obtener actividades por categoría
  Future<List<Activity>> getActivitiesByCategory(String categoryId) async {
    final snapshot = await _activitiesCollection
        .where('categoryId', isEqualTo: categoryId)
        .get();
    
    return snapshot.docs
        .map((doc) => Activity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Añadir una nueva actividad
  Future<void> addActivity(Activity activity) async {
    await _activitiesCollection.add(activity.toMap());
  }

  // Actualizar una actividad existente
  Future<void> updateActivity(Activity activity) async {
    await _activitiesCollection.doc(activity.id).update(activity.toMap());
  }

  // Eliminar una actividad
  Future<void> deleteActivity(String id) async {
    await _activitiesCollection.doc(id).delete();
  }
}
