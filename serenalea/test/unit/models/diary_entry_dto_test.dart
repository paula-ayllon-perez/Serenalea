import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenalea/data/models/diary_entry_dto.dart';

/// 7.2.1. Pruebas Unitarias - DiaryEntry DTO
/// 
/// OBJETIVO: Verificar la correcta serialización/deserialización del modelo DiaryEntry
/// incluyendo el manejo correcto de Timestamps de Firestore.
/// 
/// TIPO DE PRUEBA: Caja Blanca

void main() {
  group('Pruebas Unitarias - DiaryEntry DTO', () {
    
    test('toFirestore() convierte correctamente DateTime a Timestamp', () {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      final entry = DiaryEntryDto(
        id: 'entry_001',
        userId: 'user_123',
        content: 'Hoy fue un buen día. Me sentí en paz.',
        date: yesterday,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final firestoreMap = entry.toFirestore();

      // Assert
      expect(firestoreMap['userId'], 'user_123');
      expect(firestoreMap['content'], 'Hoy fue un buen día. Me sentí en paz.');
      expect(firestoreMap['date'], isA<Timestamp>());
      expect(firestoreMap['createdAt'], isA<Timestamp>());
      expect(firestoreMap['updatedAt'], isA<Timestamp>());
      
      // Verificar conversión correcta de fechas
      final dateTimestamp = firestoreMap['date'] as Timestamp;
      expect(dateTimestamp.toDate().year, yesterday.year);
      expect(dateTimestamp.toDate().month, yesterday.month);
      expect(dateTimestamp.toDate().day, yesterday.day);
    });

    test('fromFirestore() convierte correctamente Timestamp a DateTime', () {
      // Arrange: Simular documento de Firestore
      final now = DateTime.now();
      final mockDoc = _MockDocumentSnapshot(
        id: 'entry_002',
        data: {
          'userId': 'user_456',
          'content': 'Entrada de prueba del diario',
          'date': Timestamp.fromDate(now),
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        },
      );

      // Act
      final entry = DiaryEntryDto.fromFirestore(mockDoc);

      // Assert
      expect(entry.id, 'entry_002');
      expect(entry.userId, 'user_456');
      expect(entry.content, 'Entrada de prueba del diario');
      expect(entry.date, isA<DateTime>());
      expect(entry.createdAt, isA<DateTime>());
      expect(entry.updatedAt, isA<DateTime>());
    });

    test('maneja updatedAt null correctamente', () {
      // Arrange: Entrada sin actualización
      final now = DateTime.now();
      final mockDoc = _MockDocumentSnapshot(
        id: 'entry_003',
        data: {
          'userId': 'user_789',
          'content': 'Primera entrada sin editar',
          'date': Timestamp.fromDate(now),
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': null, // Nunca actualizada
        },
      );

      // Act
      final entry = DiaryEntryDto.fromFirestore(mockDoc);

      // Assert
      expect(entry.updatedAt, null);
      expect(entry.createdAt, isNotNull);
    });

    test('toFirestore() maneja updatedAt null correctamente', () {
      // Arrange
      final entry = DiaryEntryDto(
        id: 'entry_004',
        userId: 'user_999',
        content: 'Entrada nueva',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: null, // Sin actualizar
      );

      // Act
      final map = entry.toFirestore();

      // Assert
      expect(map['updatedAt'], null);
    });

    test('copyWith() crea copia con campos modificados', () {
      // Arrange
      final original = DiaryEntryDto(
        id: 'entry_005',
        userId: 'user_111',
        content: 'Contenido original',
        date: DateTime(2025, 11, 20),
        createdAt: DateTime(2025, 11, 20, 10, 0),
        updatedAt: null,
      );

      // Act: Modificar solo el contenido y updatedAt
      final modified = original.copyWith(
        content: 'Contenido modificado',
        updatedAt: DateTime(2025, 11, 25, 15, 30),
      );

      // Assert: Campos modificados cambian, otros permanecen
      expect(modified.id, original.id);
      expect(modified.userId, original.userId);
      expect(modified.content, 'Contenido modificado'); // Cambiado
      expect(modified.date, original.date);
      expect(modified.createdAt, original.createdAt);
      expect(modified.updatedAt, isNotNull); // Cambiado
      expect(modified.updatedAt!.day, 25);
    });

    test('roundtrip: toFirestore() y fromFirestore() mantienen consistencia', () {
      // Arrange
      final original = DiaryEntryDto(
        id: 'entry_roundtrip',
        userId: 'user_roundtrip',
        content: 'Contenido de prueba con caracteres especiales: ñ, á, ü, ¡!',
        date: DateTime(2025, 11, 25),
        createdAt: DateTime(2025, 11, 25, 12, 30),
        updatedAt: DateTime(2025, 11, 25, 14, 45),
      );

      // Act: Serializar y deserializar
      final firestoreMap = original.toFirestore();
      final mockDoc = _MockDocumentSnapshot(
        id: original.id!,
        data: firestoreMap,
      );
      final reconstructed = DiaryEntryDto.fromFirestore(mockDoc);

      // Assert
      expect(reconstructed.id, original.id);
      expect(reconstructed.userId, original.userId);
      expect(reconstructed.content, original.content);
      
      // Comparar fechas (pueden perder microsegundos en la conversión)
      expect(reconstructed.date.year, original.date.year);
      expect(reconstructed.date.month, original.date.month);
      expect(reconstructed.date.day, original.date.day);
      expect(reconstructed.createdAt.day, original.createdAt.day);
      expect(reconstructed.updatedAt!.day, original.updatedAt!.day);
    });

    test('maneja contenido largo sin truncar', () {
      // Arrange: Contenido extenso (500+ caracteres)
      final longContent = 'Lorem ipsum dolor sit amet, ' * 50;
      final entry = DiaryEntryDto(
        id: 'entry_long',
        userId: 'user_test',
        content: longContent,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Act
      final map = entry.toFirestore();
      final mockDoc = _MockDocumentSnapshot(id: 'entry_long', data: map);
      final reconstructed = DiaryEntryDto.fromFirestore(mockDoc);

      // Assert: Contenido completo sin pérdida
      expect(reconstructed.content.length, longContent.length);
      expect(reconstructed.content, longContent);
    });

    test('maneja caracteres especiales y emojis', () {
      // Arrange
      final specialContent = '¡Hoy fue genial! 😊🎉\nPudimos hacer:\n- Meditación\n- Yoga\n#BienestarDigital';
      final entry = DiaryEntryDto(
        id: 'entry_special',
        userId: 'user_test',
        content: specialContent,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Act
      final map = entry.toFirestore();
      final mockDoc = _MockDocumentSnapshot(id: 'entry_special', data: map);
      final reconstructed = DiaryEntryDto.fromFirestore(mockDoc);

      // Assert
      expect(reconstructed.content, specialContent);
    });

    test('fromFirestore() maneja campos faltantes con valores seguros', () {
      // Arrange: Documento con campos mínimos
      final mockDoc = _MockDocumentSnapshot(
        id: 'entry_minimal',
        data: {
          'userId': '',
          'content': '',
          'date': Timestamp.now(),
          'createdAt': Timestamp.now(),
        },
      );

      // Act
      final entry = DiaryEntryDto.fromFirestore(mockDoc);

      // Assert: No lanza excepciones
      expect(entry.id, 'entry_minimal');
      expect(entry.userId, '');
      expect(entry.content, '');
      expect(entry.updatedAt, null);
    });

    test('valida orden cronológico: createdAt <= updatedAt', () {
      // Arrange
      final created = DateTime(2025, 11, 20, 10, 0);
      final updated = DateTime(2025, 11, 20, 15, 30);
      
      final entry = DiaryEntryDto(
        id: 'entry_chrono',
        userId: 'user_test',
        content: 'Test',
        date: created,
        createdAt: created,
        updatedAt: updated,
      );

      // Assert: updatedAt es posterior a createdAt
      expect(entry.updatedAt!.isAfter(entry.createdAt), true);
    });
  });
}

/// Mock de DocumentSnapshot para testing
class _MockDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  final String id;
  final Map<String, dynamic> _data;

  _MockDocumentSnapshot({required this.id, required Map<String, dynamic> data})
      : _data = data;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  dynamic get(Object field) => _data[field];
  
  @override
  dynamic operator [](Object field) => _data[field];

  // Implementar métodos mínimos requeridos por la interfaz
  @override
  bool get exists => true;

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  DocumentReference<Map<String, dynamic>> get reference => throw UnimplementedError();
}
