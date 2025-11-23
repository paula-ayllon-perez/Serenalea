import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_entry_dto.dart';

class DiaryFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'diary_entries';

  // Crear o actualizar una entrada del diario
  Future<String> saveDiaryEntry(DiaryEntryDto entry) async {
    try {
      if (entry.id != null && entry.id!.isNotEmpty) {
        // Actualizar entrada existente
        await _firestore
            .collection(collectionName)
            .doc(entry.id)
            .update(entry.toFirestore());
        return entry.id!;
      } else {
        // Crear nueva entrada
        DocumentReference docRef = await _firestore
            .collection(collectionName)
            .add(entry.toFirestore());
        return docRef.id;
      }
    } catch (e) {
      throw Exception('Error al guardar la entrada del diario: $e');
    }
  }

  // Obtener entrada por fecha específica y usuario
  Future<DiaryEntryDto?> getEntryByDate(String userId, DateTime date) async {
    try {
      // Normalizar la fecha al inicio del día
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // Obtener todas las entradas del usuario y filtrar en memoria
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        DiaryEntryDto entry = DiaryEntryDto.fromFirestore(doc);
        if (entry.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
            entry.date.isBefore(endOfDay.add(const Duration(seconds: 1)))) {
          return entry;
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('Error al obtener la entrada del diario: $e');
    }
  }

  // Obtener todas las entradas de un usuario
  Future<List<DiaryEntryDto>> getUserEntries(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      // Ordenar en memoria en lugar de en la consulta
      List<DiaryEntryDto> entries = querySnapshot.docs
          .map((doc) => DiaryEntryDto.fromFirestore(doc))
          .toList();
      
      entries.sort((a, b) => b.date.compareTo(a.date));
      
      return entries;
    } catch (e) {
      throw Exception('Error al obtener las entradas del usuario: $e');
    }
  }

  // Obtener entradas por rango de fechas
  Future<List<DiaryEntryDto>> getEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      // Filtrar y ordenar en memoria
      List<DiaryEntryDto> entries = querySnapshot.docs
          .map((doc) => DiaryEntryDto.fromFirestore(doc))
          .where((entry) => 
              entry.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
              entry.date.isBefore(endDate.add(const Duration(seconds: 1))))
          .toList();
      
      entries.sort((a, b) => b.date.compareTo(a.date));
      
      return entries;
    } catch (e) {
      throw Exception('Error al obtener las entradas por rango de fechas: $e');
    }
  }

  // Eliminar una entrada
  Future<void> deleteDiaryEntry(String entryId) async {
    try {
      await _firestore.collection(collectionName).doc(entryId).delete();
    } catch (e) {
      throw Exception('Error al eliminar la entrada del diario: $e');
    }
  }
}
