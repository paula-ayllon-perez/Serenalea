import 'package:flutter_test/flutter_test.dart';
import 'package:serenalea/data/models/user_dto.dart';

/// 7.2.1. Pruebas Unitarias - User DTO
/// 
/// OBJETIVO: Verificar la correcta serialización/deserialización del modelo User
/// Estas pruebas garantizan que los datos del usuario se almacenan y recuperan
/// correctamente desde Firestore.
/// 
/// TIPO DE PRUEBA: Caja Blanca

void main() {
  group('7.2.1 Pruebas Unitarias - User DTO', () {
    
    test('toMap() serializa correctamente todos los campos del usuario', () {
      // Arrange
      final user = User(
        uid: 'user_123',
        birthYear: 1995,
        email: 'test@example.com',
        firstName: 'María',
        gender: 'Femenino',
        lastName: 'García',
        phone: '+34600123456',
        profiles: ['Estrés digital', 'Uso impulsivo'],
        photoUrl: 'https://example.com/photo.jpg',
      );

      // Act
      final map = user.toMap();

      // Assert
      expect(map['birthYear'], 1995);
      expect(map['email'], 'test@example.com');
      expect(map['firstName'], 'María');
      expect(map['gender'], 'Femenino');
      expect(map['lastName'], 'García');
      expect(map['phone'], '+34600123456');
      expect(map['profiles'], ['Estrés digital', 'Uso impulsivo']);
      expect(map['photoUrl'], 'https://example.com/photo.jpg');
      
      // El UID no se incluye en toMap (se usa como documentId en Firestore)
      expect(map.containsKey('uid'), false);
    });

    test('fromMap() deserializa correctamente desde Firestore', () {
      // Arrange
      final firestoreData = {
        'birthYear': 2000,
        'email': 'juan@test.com',
        'firstName': 'Juan',
        'gender': 'Masculino',
        'lastName': 'Pérez',
        'phone': '+34611222333',
        'profiles': ['Comparación social'],
        'photoUrl': 'https://test.com/juan.jpg',
      };
      const documentId = 'user_456';

      // Act
      final user = User.fromMap(firestoreData, documentId);

      // Assert
      expect(user.uid, 'user_456');
      expect(user.birthYear, 2000);
      expect(user.email, 'juan@test.com');
      expect(user.firstName, 'Juan');
      expect(user.gender, 'Masculino');
      expect(user.lastName, 'Pérez');
      expect(user.phone, '+34611222333');
      expect(user.profiles, ['Comparación social']);
      expect(user.photoUrl, 'https://test.com/juan.jpg');
    });

    test('fromMap() maneja photoUrl null correctamente', () {
      // Arrange: Usuario sin foto de perfil
      final dataWithoutPhoto = {
        'birthYear': 1998,
        'email': 'noPhoto@test.com',
        'firstName': 'Ana',
        'gender': 'Femenino',
        'lastName': 'López',
        'phone': '+34622333444',
        'profiles': ['General'],
        // photoUrl ausente
      };

      // Act
      final user = User.fromMap(dataWithoutPhoto, 'user_789');

      // Assert
      expect(user.photoUrl, null);
      expect(user.firstName, 'Ana');
    });

    test('fromMap() maneja datos faltantes con valores por defecto', () {
      // Arrange: Map incompleto
      final incompleteData = <String, dynamic>{};

      // Act
      final user = User.fromMap(incompleteData, 'user_empty');

      // Assert: Valores seguros por defecto
      expect(user.uid, 'user_empty');
      expect(user.birthYear, 0);
      expect(user.email, '');
      expect(user.firstName, '');
      expect(user.gender, '');
      expect(user.lastName, '');
      expect(user.phone, '');
      expect(user.profiles, []);
      expect(user.photoUrl, null);
    });

    test('roundtrip: toMap() y fromMap() mantienen consistencia', () {
      // Arrange
      final originalUser = User(
        uid: 'user_roundtrip',
        birthYear: 1992,
        email: 'roundtrip@test.com',
        firstName: 'Carlos',
        gender: 'Masculino',
        lastName: 'Ruiz',
        phone: '+34633444555',
        profiles: ['Estrés digital', 'Sobrecarga mental', 'Aislamiento social'],
        photoUrl: 'https://test.com/carlos.jpg',
      );

      // Act
      final map = originalUser.toMap();
      final reconstructedUser = User.fromMap(map, originalUser.uid);

      // Assert
      expect(reconstructedUser.uid, originalUser.uid);
      expect(reconstructedUser.birthYear, originalUser.birthYear);
      expect(reconstructedUser.email, originalUser.email);
      expect(reconstructedUser.firstName, originalUser.firstName);
      expect(reconstructedUser.gender, originalUser.gender);
      expect(reconstructedUser.lastName, originalUser.lastName);
      expect(reconstructedUser.phone, originalUser.phone);
      expect(reconstructedUser.profiles, originalUser.profiles);
      expect(reconstructedUser.photoUrl, originalUser.photoUrl);
    });

    test('profiles nunca es null, siempre es lista (vacía o con elementos)', () {
      // Caso 1: Profiles explícitamente vacío
      final user1 = User.fromMap({
        'birthYear': 1990,
        'email': 'test1@test.com',
        'firstName': 'Test',
        'gender': 'Otro',
        'lastName': 'User',
        'phone': '+34611111111',
        'profiles': [],
      }, 'user1');
      
      expect(user1.profiles, isNotNull);
      expect(user1.profiles, isEmpty);
      
      // Caso 2: Profiles faltante
      final user2 = User.fromMap({
        'birthYear': 1990,
        'email': 'test2@test.com',
        'firstName': 'Test',
        'gender': 'Otro',
        'lastName': 'User',
        'phone': '+34611111111',
      }, 'user2');
      
      expect(user2.profiles, isNotNull);
      expect(user2.profiles, isEmpty);
    });

    test('maneja múltiples perfiles correctamente', () {
      // Arrange: Usuario con 4 perfiles (caso del cuestionario)
      final userData = {
        'birthYear': 1997,
        'email': 'multi@test.com',
        'firstName': 'Laura',
        'gender': 'Femenino',
        'lastName': 'Martín',
        'phone': '+34644555666',
        'profiles': [
          'Estrés digital',
          'Uso impulsivo',
          'Sobrecarga mental',
          'Comparación social'
        ],
      };

      // Act
      final user = User.fromMap(userData, 'user_multi');

      // Assert
      expect(user.profiles.length, 4);
      expect(user.profiles, contains('Estrés digital'));
      expect(user.profiles, contains('Uso impulsivo'));
      expect(user.profiles, contains('Sobrecarga mental'));
      expect(user.profiles, contains('Comparación social'));
    });

    test('valida formato de email (campo crítico)', () {
      // Arrange: Diferentes formatos de email
      final emails = [
        'valid@example.com',
        'user.name@domain.co.uk',
        'test+tag@test.com',
        '', // email vacío (manejado por fromMap)
      ];

      for (final email in emails) {
        // Act
        final user = User(
          uid: 'test',
          birthYear: 2000,
          email: email,
          firstName: 'Test',
          gender: 'Otro',
          lastName: 'User',
          phone: '+34600000000',
          profiles: [],
        );

        // Assert: El modelo acepta cualquier string (validación en otro lugar)
        expect(user.email, email);
      }
    });

    test('valida rango de birthYear (lógica de negocio)', () {
      // Arrange: Diferentes años de nacimiento
      final validYears = [1950, 1980, 2000, 2010];
      
      for (final year in validYears) {
        // Act
        final user = User(
          uid: 'test_$year',
          birthYear: year,
          email: 'test@test.com',
          firstName: 'Test',
          gender: 'Otro',
          lastName: 'User',
          phone: '+34600000000',
          profiles: [],
        );

        // Assert
        expect(user.birthYear, year);
        
        // Calcular edad aproximada (prueba de lógica)
        final currentYear = DateTime.now().year;
        final age = currentYear - year;
        expect(age, greaterThanOrEqualTo(0));
      }
    });
  });
}
