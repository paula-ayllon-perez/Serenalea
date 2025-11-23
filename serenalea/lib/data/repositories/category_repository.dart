import '../models/activity_category_dto.dart';
import '../services/category_firestore.dart';

class CategoryRepository {
  final CategoryFirestoreService _service = CategoryFirestoreService();

  // Obtener todas las categorías activas
  Future<List<ActivityCategory>> getAllCategories() async {
    return await _service.getAllCategories();
  }

  // Obtener una categoría por ID
  Future<ActivityCategory?> getCategoryById(String categoryId) async {
    return await _service.getCategoryById(categoryId);
  }

  // Añadir una nueva categoría
  Future<void> addCategory(ActivityCategory category) async {
    await _service.addCategory(category);
  }

  // Actualizar una categoría
  Future<void> updateCategory(ActivityCategory category) async {
    await _service.updateCategory(category);
  }

  // Eliminar una categoría
  Future<void> deleteCategory(String id) async {
    await _service.deleteCategory(id);
  }
}
