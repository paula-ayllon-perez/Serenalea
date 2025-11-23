import '../models/activity_dto.dart';
import '../services/activity_firestore.dart';

class ActivityRepository {
  final ActivityFirestoreService _service = ActivityFirestoreService();

  // Obtener todas las actividades
  Future<List<Activity>> getAllActivities() async {
    return await _service.getAllActivities();
  }

  // Obtener actividades por ID de categoría
  Future<List<Activity>> getActivitiesByCategory(String categoryId) async {
    return await _service.getActivitiesByCategory(categoryId);
  }

  // Añadir una nueva actividad
  Future<void> addActivity(Activity activity) async {
    await _service.addActivity(activity);
  }

  // Actualizar una actividad existente
  Future<void> updateActivity(Activity activity) async {
    await _service.updateActivity(activity);
  }

  // Eliminar una actividad
  Future<void> deleteActivity(String id) async {
    await _service.deleteActivity(id);
  }
}
