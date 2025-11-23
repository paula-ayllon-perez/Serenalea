import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/photo_memory_dto.dart';

class PhotoFirestoreService {
  final CollectionReference _photosCollection =
      FirebaseFirestore.instance.collection('photo_memories');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Guardar una foto en el álbum
  Future<void> savePhoto({
    required String imagePath,
    required String activityName,
    required String activityCategory,
    String? description,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final photo = PhotoMemory(
      id: '',
      userId: userId,
      activityName: activityName,
      activityCategory: activityCategory,
      imagePath: imagePath,
      date: DateTime.now(),
      description: description,
    );

    await _photosCollection.add(photo.toMap());
  }

  // Obtener todas las fotos del usuario ordenadas por fecha (más reciente primero)
  Future<List<PhotoMemory>> getUserPhotos() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _photosCollection
        .where('userId', isEqualTo: userId)
        .get();

    final photos = snapshot.docs
        .map((doc) => PhotoMemory.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    
    // Ordenar localmente para evitar necesidad de índices en Firestore
    photos.sort((a, b) => b.date.compareTo(a.date));
    
    return photos;
  }

  // Buscar fotos por nombre de actividad
  Future<List<PhotoMemory>> searchPhotosByActivity(String query) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _photosCollection
        .where('userId', isEqualTo: userId)
        .get();

    final allPhotos = snapshot.docs
        .map((doc) => PhotoMemory.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    // Filtrar localmente por nombre de actividad y ordenar por fecha
    final filtered = allPhotos.where((photo) {
      return photo.activityName.toLowerCase().contains(query.toLowerCase());
    }).toList();
    
    filtered.sort((a, b) => b.date.compareTo(a.date));
    
    return filtered;
  }

  // Filtrar fotos por categoría
  Future<List<PhotoMemory>> filterPhotosByCategory(String category) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _photosCollection
        .where('userId', isEqualTo: userId)
        .where('activityCategory', isEqualTo: category)
        .get();

    final photos = snapshot.docs
        .map((doc) => PhotoMemory.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    
    // Ordenar localmente por fecha
    photos.sort((a, b) => b.date.compareTo(a.date));
    
    return photos;
  }

  // Eliminar una foto
  Future<void> deletePhoto(String photoId) async {
    await _photosCollection.doc(photoId).delete();
  }

  // Obtener categorías únicas de las fotos del usuario
  Future<List<String>> getUserCategories() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _photosCollection
        .where('userId', isEqualTo: userId)
        .get();

    final categories = snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['activityCategory'] as String)
        .toSet()
        .toList();

    return categories;
  }
}
