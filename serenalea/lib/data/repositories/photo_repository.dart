import '../models/photo_memory_dto.dart';
import '../services/photo_firestore.dart';

class PhotoRepository {
  final PhotoFirestoreService _service = PhotoFirestoreService();

  // Guardar una foto en el álbum
  Future<void> savePhoto({
    required String imagePath,
    required String activityName,
    required String activityCategory,
    String? description,
  }) async {
    await _service.savePhoto(
      imagePath: imagePath,
      activityName: activityName,
      activityCategory: activityCategory,
      description: description,
    );
  }

  // Obtener todas las fotos del usuario
  Future<List<PhotoMemory>> getUserPhotos() async {
    return await _service.getUserPhotos();
  }

  // Buscar fotos por nombre de actividad
  Future<List<PhotoMemory>> searchPhotosByActivity(String query) async {
    return await _service.searchPhotosByActivity(query);
  }

  // Filtrar fotos por categoría
  Future<List<PhotoMemory>> filterPhotosByCategory(String category) async {
    return await _service.filterPhotosByCategory(category);
  }

  // Eliminar una foto
  Future<void> deletePhoto(String photoId) async {
    await _service.deletePhoto(photoId);
  }

  // Obtener categorías únicas
  Future<List<String>> getUserCategories() async {
    return await _service.getUserCategories();
  }
}
