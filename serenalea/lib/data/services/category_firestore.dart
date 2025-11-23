import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_category_dto.dart';

class CategoryFirestoreService {
  final CollectionReference _categoriesCollection = 
      FirebaseFirestore.instance.collection('activity_categories');

  // Obtener todas las categorías activas ordenadas por order
  Future<List<ActivityCategory>> getAllCategories() async {
    final snapshot = await _categoriesCollection
        .where('isActive', isEqualTo: true)
        .get();
    
    final categories = snapshot.docs
        .map((doc) => ActivityCategory.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    
    // Ordenar localmente por el campo order
    categories.sort((a, b) => a.order.compareTo(b.order));
    
    return categories;
  }

  // Obtener una categoría por ID
  Future<ActivityCategory?> getCategoryById(String categoryId) async {
    final doc = await _categoriesCollection.doc(categoryId).get();
    if (!doc.exists) return null;
    
    return ActivityCategory.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Añadir una nueva categoría
  Future<void> addCategory(ActivityCategory category) async {
    await _categoriesCollection.add(category.toMap());
  }

  // Actualizar una categoría
  Future<void> updateCategory(ActivityCategory category) async {
    await _categoriesCollection.doc(category.id).update(category.toMap());
  }

  // Eliminar una categoría (soft delete - marcar como inactiva)
  Future<void> deleteCategory(String id) async {
    await _categoriesCollection.doc(id).update({'isActive': false});
  }
}
