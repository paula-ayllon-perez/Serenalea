import 'package:flutter_test/flutter_test.dart';

/// 7.2.1 Pruebas Unitarias - Helpers y Utilidades (Caja Negra)
/// 
/// OBJETIVO: Verificar comportamiento de funciones auxiliares de formateo y conversión
/// TIPO DE PRUEBA: Caja Negra - Se verifica salida esperada sin conocer implementación
/// COMPONENTE: Funciones helper de texto, fechas y perfiles

class TextHelpers {
  /// Capitaliza la primera letra de cada palabra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Trunca texto largo y añade "..."
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Obtiene iniciales de un nombre (máximo 2 letras)
  static String getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  /// Cuenta palabras en un texto
  static int wordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}

class DateHelpers {
  /// Formatea fecha relativa ("Hace 2 días", "Hoy", etc.)
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Justo ahora';
        }
        return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
      }
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace $weeks semana${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months mes${months > 1 ? 'es' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years año${years > 1 ? 's' : ''}';
    }
  }

  /// Verifica si una fecha es reciente (últimos 7 días)
  static bool isRecent(DateTime date) {
    final now = DateTime.now();
    return now.difference(date).inDays < 7;
  }
}

class ProfileHelpers {
  /// Convierte lista de perfiles a texto legible
  static String profilesToText(List<String> profiles) {
    if (profiles.isEmpty) return 'Sin perfil asignado';
    if (profiles.length == 1) return profiles[0];
    if (profiles.length == 2) return '${profiles[0]} y ${profiles[1]}';
    
    final allButLast = profiles.sublist(0, profiles.length - 1).join(', ');
    return '$allButLast y ${profiles.last}';
  }

  /// Obtiene emoji representativo según perfil
  static String getProfileEmoji(String profile) {
    final emojiMap = {
      'Comparación social': '👥',
      'Miedo a perderse algo': '📱',
      'Perfeccionismo': '⭐',
      'Búsqueda de validación': '❤️',
      'Sin perfil asignado': '🔍',
    };
    return emojiMap[profile] ?? '🌟';
  }
}

void main() {
  group('7.2.1 Helpers - Formateo de Texto (Caja Negra)', () {
    test('capitaliza palabra simple', () {
      expect(TextHelpers.capitalize('hola'), 'Hola');
    });

    test('capitaliza texto con múltiples palabras', () {
      expect(TextHelpers.capitalize('hola mundo'), 'Hola Mundo');
    });

    test('maneja texto ya capitalizado', () {
      expect(TextHelpers.capitalize('Hola Mundo'), 'Hola Mundo');
    });

    test('maneja texto vacío', () {
      expect(TextHelpers.capitalize(''), '');
    });

    test('trunca texto largo correctamente', () {
      expect(TextHelpers.truncate('Este es un texto muy largo', 10), 'Este es un...');
    });

    test('no trunca texto corto', () {
      expect(TextHelpers.truncate('Corto', 10), 'Corto');
    });

    test('obtiene iniciales de nombre simple', () {
      expect(TextHelpers.getInitials('María'), 'M');
    });

    test('obtiene iniciales de nombre completo', () {
      expect(TextHelpers.getInitials('María García'), 'MG');
    });

    test('obtiene iniciales de 3+ palabras (solo primeras 2)', () {
      expect(TextHelpers.getInitials('Juan Carlos López'), 'JC');
    });

    test('cuenta palabras correctamente', () {
      expect(TextHelpers.wordCount('Hola mundo'), 2);
      expect(TextHelpers.wordCount('Una'), 1);
      expect(TextHelpers.wordCount(''), 0);
      expect(TextHelpers.wordCount('   Texto   con   espacios   '), 3);
    });
  });

  group('7.2.1 Helpers - Fechas Relativas (Caja Negra)', () {
    test('muestra "Justo ahora" para fecha actual', () {
      final now = DateTime.now();
      expect(DateHelpers.formatRelative(now), 'Justo ahora');
    });

    test('muestra "Hace X minutos" para minutos atrás', () {
      final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
      expect(DateHelpers.formatRelative(fiveMinutesAgo), 'Hace 5 minutos');
    });

    test('muestra "Hace X horas" para horas atrás', () {
      final threeHoursAgo = DateTime.now().subtract(const Duration(hours: 3));
      expect(DateHelpers.formatRelative(threeHoursAgo), 'Hace 3 horas');
    });

    test('muestra "Ayer" para 1 día atrás', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateHelpers.formatRelative(yesterday), 'Ayer');
    });

    test('muestra "Hace X días" para días recientes', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      expect(DateHelpers.formatRelative(threeDaysAgo), 'Hace 3 días');
    });

    test('muestra "Hace X semanas" para semanas', () {
      final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
      expect(DateHelpers.formatRelative(twoWeeksAgo), 'Hace 2 semanas');
    });

    test('muestra "Hace X meses" para meses', () {
      final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));
      expect(DateHelpers.formatRelative(twoMonthsAgo), 'Hace 2 meses');
    });

    test('muestra "Hace X años" para años', () {
      final oneYearAgo = DateTime.now().subtract(const Duration(days: 400));
      expect(DateHelpers.formatRelative(oneYearAgo), 'Hace 1 año');
    });

    test('detecta fechas recientes (< 7 días)', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      expect(DateHelpers.isRecent(threeDaysAgo), true);
    });

    test('detecta fechas antiguas (>= 7 días)', () {
      final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
      expect(DateHelpers.isRecent(tenDaysAgo), false);
    });

    test('boundary: exactamente 7 días no es reciente', () {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      expect(DateHelpers.isRecent(sevenDaysAgo), false);
    });
  });

  group('7.2.1 Helpers - Perfiles (Caja Negra)', () {
    test('formatea lista vacía de perfiles', () {
      expect(ProfileHelpers.profilesToText([]), 'Sin perfil asignado');
    });

    test('formatea un solo perfil', () {
      expect(ProfileHelpers.profilesToText(['Comparación social']), 'Comparación social');
    });

    test('formatea dos perfiles con "y"', () {
      expect(
        ProfileHelpers.profilesToText(['Comparación social', 'Perfeccionismo']),
        'Comparación social y Perfeccionismo',
      );
    });

    test('formatea tres o más perfiles con comas y "y"', () {
      expect(
        ProfileHelpers.profilesToText([
          'Comparación social',
          'Perfeccionismo',
          'Miedo a perderse algo'
        ]),
        'Comparación social, Perfeccionismo y Miedo a perderse algo',
      );
    });

    test('obtiene emoji correcto para cada perfil', () {
      expect(ProfileHelpers.getProfileEmoji('Comparación social'), '👥');
      expect(ProfileHelpers.getProfileEmoji('Miedo a perderse algo'), '📱');
      expect(ProfileHelpers.getProfileEmoji('Perfeccionismo'), '⭐');
      expect(ProfileHelpers.getProfileEmoji('Búsqueda de validación'), '❤️');
    });

    test('obtiene emoji por defecto para perfil desconocido', () {
      expect(ProfileHelpers.getProfileEmoji('Perfil Inexistente'), '🌟');
    });

    test('obtiene emoji para sin perfil asignado', () {
      expect(ProfileHelpers.getProfileEmoji('Sin perfil asignado'), '🔍');
    });
  });
}
