import 'package:flutter_test/flutter_test.dart';

/// 7.2.1 Pruebas Unitarias - Validadores (Caja Blanca)
/// 
/// OBJETIVO: Verificar la lógica de validación de formularios
/// TIPO DE PRUEBA: Caja Blanca - Validación de entrada de datos
/// COMPONENTE: Funciones de validación reutilizables

// Simular validadores que usaría la app
class Validators {
  /// Valida email con formato correcto
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es obligatorio';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    
    return null; // null = válido
  }

  /// Valida contraseña (mínimo 6 caracteres)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }

  /// Valida que dos contraseñas coincidan
  static String? validatePasswordMatch(String? password, String? confirmPassword) {
    if (password != confirmPassword) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Valida nombre (no vacío, solo letras y espacios)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es obligatorio';
    }
    
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'El nombre solo puede contener letras';
    }
    
    return null;
  }

  /// Valida año de nacimiento (rango razonable)
  static String? validateBirthYear(int? year) {
    if (year == null) {
      return 'El año de nacimiento es obligatorio';
    }
    
    final currentYear = DateTime.now().year;
    
    if (year < 1900 || year > currentYear) {
      return 'Año de nacimiento inválido';
    }
    
    final age = currentYear - year;
    if (age < 13) {
      return 'Debes tener al menos 13 años';
    }
    
    return null;
  }
}

void main() {
  group('7.2.1 Validadores - Email', () {
    test('acepta email válido estándar', () {
      expect(Validators.validateEmail('usuario@example.com'), isNull);
    });

    test('acepta email con subdominios', () {
      expect(Validators.validateEmail('user@mail.company.co.uk'), isNull);
    });

    test('rechaza email vacío', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail(''), contains('obligatorio'));
    });

    test('rechaza email sin @', () {
      expect(Validators.validateEmail('usuarioexample.com'), isNotNull);
      expect(Validators.validateEmail('usuarioexample.com'), contains('inválido'));
    });

    test('rechaza email sin dominio', () {
      expect(Validators.validateEmail('usuario@'), isNotNull);
    });

    test('rechaza email con espacios', () {
      expect(Validators.validateEmail('usuario @example.com'), isNotNull);
    });
  });

  group('7.2.1 Validadores - Contraseña', () {
    test('acepta contraseña de 6 caracteres', () {
      expect(Validators.validatePassword('abc123'), isNull);
    });

    test('acepta contraseña larga', () {
      expect(Validators.validatePassword('contraseñaSegura123!'), isNull);
    });

    test('rechaza contraseña vacía', () {
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword(''), contains('obligatoria'));
    });

    test('rechaza contraseña menor a 6 caracteres', () {
      expect(Validators.validatePassword('abc12'), isNotNull);
      expect(Validators.validatePassword('abc12'), contains('6 caracteres'));
    });

    test('valida que dos contraseñas coincidan', () {
      expect(Validators.validatePasswordMatch('abc123', 'abc123'), isNull);
    });

    test('detecta contraseñas que no coinciden', () {
      expect(Validators.validatePasswordMatch('abc123', 'abc124'), isNotNull);
      expect(Validators.validatePasswordMatch('abc123', 'abc124'), contains('no coinciden'));
    });
  });

  group('7.2.1 Validadores - Nombre', () {
    test('acepta nombre simple', () {
      expect(Validators.validateName('Juan'), isNull);
    });

    test('acepta nombre con espacios', () {
      expect(Validators.validateName('María García'), isNull);
    });

    test('acepta acentos y ñ', () {
      expect(Validators.validateName('José Peña'), isNull);
    });

    test('rechaza nombre vacío', () {
      expect(Validators.validateName(''), isNotNull);
    });

    test('rechaza nombre de 1 carácter', () {
      expect(Validators.validateName('A'), isNotNull);
      expect(Validators.validateName('A'), contains('2 caracteres'));
    });

    test('rechaza nombre con números', () {
      expect(Validators.validateName('Juan123'), isNotNull);
      expect(Validators.validateName('Juan123'), contains('letras'));
    });

    test('rechaza nombre con símbolos', () {
      expect(Validators.validateName('Juan@López'), isNotNull);
    });
  });

  group('7.2.1 Validadores - Año de Nacimiento', () {
    test('acepta año válido (adulto joven)', () {
      expect(Validators.validateBirthYear(2000), isNull);
    });

    test('acepta año válido (persona mayor)', () {
      expect(Validators.validateBirthYear(1950), isNull);
    });

    test('rechaza año futuro', () {
      final futureYear = DateTime.now().year + 1;
      expect(Validators.validateBirthYear(futureYear), isNotNull);
      expect(Validators.validateBirthYear(futureYear), contains('inválido'));
    });

    test('rechaza año anterior a 1900', () {
      expect(Validators.validateBirthYear(1899), isNotNull);
    });

    test('rechaza menores de 13 años', () {
      final currentYear = DateTime.now().year;
      final youngYear = currentYear - 10; // 10 años
      expect(Validators.validateBirthYear(youngYear), isNotNull);
      expect(Validators.validateBirthYear(youngYear), contains('13 años'));
    });

    test('acepta justo 13 años (boundary)', () {
      final currentYear = DateTime.now().year;
      final boundaryYear = currentYear - 13;
      expect(Validators.validateBirthYear(boundaryYear), isNull);
    });
  });
}
