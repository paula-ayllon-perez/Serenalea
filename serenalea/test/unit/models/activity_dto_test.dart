import 'package:flutter_test/flutter_test.dart';
import 'package:serenalea/data/models/activity_dto.dart';

/// 7.2.1. Pruebas Unitarias - Modelos de Datos (DTOs)
/// 
/// OBJETIVO: Verificar la correcta serialización/deserialización de datos
/// desde y hacia Firestore. Estas pruebas son fundamentales para garantizar
/// la integridad de los datos en la comunicación con la base de datos.
/// 
/// TIPO DE PRUEBA: Caja Blanca - Verificación de lógica interna
/// COBERTURA: Métodos toMap() y fromMap() del modelo Activity

void main() {
  group('7.2.1 Pruebas Unitarias - Activity DTO', () {
    
    /// TEST 1: Serialización correcta (toMap)
    /// Verifica que un objeto Activity se convierte correctamente a Map
    test('toMap() serializa correctamente todos los campos', () {
      // Arrange: Crear una actividad con todos los campos
      final activity = Activity(
        id: 'act_001',
        categoryId: 'cat_mindfulness',
        title: 'Meditación guiada',
        description: 'Practica 10 minutos de meditación consciente',
        suitableProfiles: ['Estrés digital', 'Sobrecarga mental'],
        duration: 10,
        score: 15,
        difficulty: 'easy',
        imageUrl: 'https://example.com/meditation.jpg',
        activityType: 'meditation',
      );

      // Act: Convertir a Map
      final map = activity.toMap();

      // Assert: Verificar que todos los campos están presentes y correctos
      expect(map['categoryId'], 'cat_mindfulness');
      expect(map['title'], 'Meditación guiada');
      expect(map['description'], 'Practica 10 minutos de meditación consciente');
      expect(map['suitableProfiles'], ['Estrés digital', 'Sobrecarga mental']);
      expect(map['duration'], 10);
      expect(map['score'], 15);
      expect(map['difficulty'], 'easy');
      expect(map['imageUrl'], 'https://example.com/meditation.jpg');
      expect(map['activityType'], 'meditation');
      
      // Verificar que NO incluye el ID (se maneja por separado en Firestore)
      expect(map.containsKey('id'), false);
    });

    /// TEST 2: Deserialización correcta (fromMap)
    /// Verifica que un Map desde Firestore se convierte correctamente a objeto
    test('fromMap() deserializa correctamente desde Firestore', () {
      // Arrange: Simular datos desde Firestore
      final firestoreData = {
        'categoryId': 'cat_creativity',
        'title': 'Fotografía mindful',
        'description': 'Captura algo que te haga sentir paz',
        'suitableProfiles': ['Comparación social', 'Aislamiento social'],
        'duration': 15,
        'score': 20,
        'difficulty': 'medium',
        'imageUrl': 'https://example.com/photo.jpg',
        'activityType': 'photo',
      };
      const documentId = 'act_002';

      // Act: Crear objeto desde Map
      final activity = Activity.fromMap(firestoreData, documentId);

      // Assert: Verificar todos los campos
      expect(activity.id, 'act_002');
      expect(activity.categoryId, 'cat_creativity');
      expect(activity.title, 'Fotografía mindful');
      expect(activity.description, 'Captura algo que te haga sentir paz');
      expect(activity.suitableProfiles, ['Comparación social', 'Aislamiento social']);
      expect(activity.duration, 15);
      expect(activity.score, 20);
      expect(activity.difficulty, 'medium');
      expect(activity.imageUrl, 'https://example.com/photo.jpg');
      expect(activity.activityType, 'photo');
    });

    /// TEST 3: Manejo de valores por defecto
    /// Verifica el comportamiento cuando faltan campos opcionales
    test('fromMap() aplica valores por defecto para campos faltantes', () {
      // Arrange: Map con campos mínimos
      final minimalData = {
        'categoryId': 'cat_001',
        'title': 'Actividad básica',
        'description': 'Descripción simple',
        'suitableProfiles': [],
        'duration': 5,
        'score': 5,
        // difficulty, imageUrl y activityType faltantes
      };

      // Act
      final activity = Activity.fromMap(minimalData, 'act_003');

      // Assert: Verificar valores por defecto
      expect(activity.difficulty, 'medium'); // Valor por defecto
      expect(activity.imageUrl, null); // Campo opcional
      expect(activity.activityType, 'simple'); // Valor por defecto
    });

    /// TEST 4: Manejo de datos corruptos/inválidos
    /// Verifica el comportamiento con datos vacíos o null
    test('fromMap() maneja datos vacíos sin errores', () {
      // Arrange: Map vacío (caso extremo)
      final emptyData = <String, dynamic>{};

      // Act
      final activity = Activity.fromMap(emptyData, 'act_004');

      // Assert: Verificar valores seguros por defecto
      expect(activity.id, 'act_004');
      expect(activity.categoryId, '');
      expect(activity.title, '');
      expect(activity.description, '');
      expect(activity.suitableProfiles, []);
      expect(activity.duration, 0);
      expect(activity.score, 0);
      expect(activity.difficulty, 'medium');
      expect(activity.activityType, 'simple');
    });

    /// TEST 5: Roundtrip (serialización + deserialización)
    /// Verifica que toMap() y fromMap() son operaciones inversas
    test('toMap() y fromMap() mantienen consistencia en roundtrip', () {
      // Arrange: Crear actividad original
      final originalActivity = Activity(
        id: 'act_005',
        categoryId: 'cat_test',
        title: 'Test Activity',
        description: 'Testing roundtrip',
        suitableProfiles: ['Profile1', 'Profile2'],
        duration: 20,
        score: 30,
        difficulty: 'hard',
        imageUrl: 'https://test.com/image.png',
        activityType: 'text',
      );

      // Act: Serializar y deserializar
      final map = originalActivity.toMap();
      final reconstructedActivity = Activity.fromMap(map, originalActivity.id);

      // Assert: Verificar que son equivalentes
      expect(reconstructedActivity.id, originalActivity.id);
      expect(reconstructedActivity.categoryId, originalActivity.categoryId);
      expect(reconstructedActivity.title, originalActivity.title);
      expect(reconstructedActivity.description, originalActivity.description);
      expect(reconstructedActivity.suitableProfiles, originalActivity.suitableProfiles);
      expect(reconstructedActivity.duration, originalActivity.duration);
      expect(reconstructedActivity.score, originalActivity.score);
      expect(reconstructedActivity.difficulty, originalActivity.difficulty);
      expect(reconstructedActivity.imageUrl, originalActivity.imageUrl);
      expect(reconstructedActivity.activityType, originalActivity.activityType);
    });

    /// TEST 6: Método auxiliar difficultyLabel
    /// Verifica la lógica de negocio del getter difficultyLabel
    test('difficultyLabel devuelve las etiquetas correctas en español', () {
      // Arrange & Act & Assert
      final easyActivity = Activity(
        id: 'a1',
        categoryId: 'c1',
        title: 'Test',
        description: 'Test',
        suitableProfiles: [],
        duration: 5,
        score: 5,
        difficulty: 'easy',
      );
      expect(easyActivity.difficultyLabel, 'Fácil');

      final mediumActivity = Activity(
        id: 'a2',
        categoryId: 'c1',
        title: 'Test',
        description: 'Test',
        suitableProfiles: [],
        duration: 5,
        score: 5,
        difficulty: 'medium',
      );
      expect(mediumActivity.difficultyLabel, 'Medio');

      final hardActivity = Activity(
        id: 'a3',
        categoryId: 'c1',
        title: 'Test',
        description: 'Test',
        suitableProfiles: [],
        duration: 5,
        score: 5,
        difficulty: 'hard',
      );
      expect(hardActivity.difficultyLabel, 'Difícil');

      // Caso de valor desconocido
      final unknownActivity = Activity(
        id: 'a4',
        categoryId: 'c1',
        title: 'Test',
        description: 'Test',
        suitableProfiles: [],
        duration: 5,
        score: 5,
        difficulty: 'unknown',
      );
      expect(unknownActivity.difficultyLabel, 'Medio');
    });

    /// TEST 7: Validación de tipos de actividad
    /// Verifica que activityType maneja todos los tipos esperados
    test('activityType acepta todos los tipos válidos', () {
      final types = ['photo', 'text', 'meditation', 'simple'];
      
      for (final type in types) {
        final activity = Activity(
          id: 'test_$type',
          categoryId: 'cat_test',
          title: 'Test $type',
          description: 'Testing type $type',
          suitableProfiles: [],
          duration: 10,
          score: 10,
          activityType: type,
        );
        
        expect(activity.activityType, type);
        
        // Verificar serialización
        final map = activity.toMap();
        expect(map['activityType'], type);
      }
    });

    /// TEST 8: Validación de lista vacía vs null
    /// Importante para prevenir errores en el frontend
    test('suitableProfiles nunca es null, solo lista vacía', () {
      // Caso 1: Lista explícitamente vacía
      final activity1 = Activity.fromMap({
        'categoryId': 'c1',
        'title': 'Test',
        'description': 'Test',
        'suitableProfiles': [],
        'duration': 5,
        'score': 5,
      }, 'a1');
      
      expect(activity1.suitableProfiles, isNotNull);
      expect(activity1.suitableProfiles, isEmpty);
      
      // Caso 2: Campo faltante (debería usar valor por defecto)
      final activity2 = Activity.fromMap({
        'categoryId': 'c1',
        'title': 'Test',
        'description': 'Test',
        'duration': 5,
        'score': 5,
      }, 'a2');
      
      expect(activity2.suitableProfiles, isNotNull);
      expect(activity2.suitableProfiles, isEmpty);
    });
  });
}
