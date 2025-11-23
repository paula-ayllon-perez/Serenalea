import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inicializa la base de datos con datos de ejemplo si está vacía
  static Future<void> initializeIfEmpty() async {
    try {
      // Verificar si ya existen categorías
      final categoriesSnapshot = await _firestore
          .collection('activity_categories')
          .limit(1)
          .get();

      if (categoriesSnapshot.docs.isEmpty) {
        print('🔄 Inicializando base de datos con datos de ejemplo...');
        await _createSampleCategories();
        await _createSampleActivities();
        print('✅ Base de datos inicializada correctamente');
      } else {
        print('✓ Base de datos ya contiene datos');
      }
    } catch (e) {
      print('❌ Error al inicializar base de datos: $e');
    }
  }

  static Future<void> _createSampleCategories() async {
    final categories = [
      {
        'name': 'Creatividad',
        'description': 'Actividades breves para estimular la mente y fomentar expresión personal',
        'iconName': 'brush',
        'colorHex': '#FF6B6B',
        'order': 1,
        'isActive': true,
      },
      {
        'name': 'Observación',
        'description': 'Atención plena del entorno para activar los sentidos',
        'iconName': 'visibility',
        'colorHex': '#FFA726',
        'order': 2,
        'isActive': true,
      },
      {
        'name': 'Paseo Consciente',
        'description': 'Reconectar con el entorno, el movimiento y la naturaleza',
        'iconName': 'directions_walk',
        'colorHex': '#4CAF50',
        'order': 3,
        'isActive': true,
      },
      {
        'name': 'Meditación y Respiración',
        'description': 'Técnicas simples para reducir estrés y mejorar la calma',
        'iconName': 'self_improvement',
        'colorHex': '#7B68EE',
        'order': 4,
        'isActive': true,
      },
      {
        'name': 'Actividades en Casa',
        'description': 'Reconectar con tu espacio y crear pequeñas pausas',
        'iconName': 'home',
        'colorHex': '#9C27B0',
        'order': 5,
        'isActive': true,
      },
      {
        'name': 'Diario y Conexión Personal',
        'description': 'Introspección breve para mejorar el autoconocimiento',
        'iconName': 'book',
        'colorHex': '#00BCD4',
        'order': 6,
        'isActive': true,
      },
    ];

    for (var category in categories) {
      await _firestore.collection('activity_categories').add(category);
      print('✓ Categoría creada: ${category['name']}');
    }
  }

  static Future<void> _createSampleActivities() async {
  // Obtener los IDs de las categorías recién creadas
  final categoriesSnapshot = await _firestore
      .collection('activity_categories')
      .orderBy('order')
      .get();

  final categoryIds = {
    'Creatividad': categoriesSnapshot.docs[0].id,
    'Observación': categoriesSnapshot.docs[1].id,
    'Paseo Consciente': categoriesSnapshot.docs[2].id,
    'Meditación y Respiración': categoriesSnapshot.docs[3].id,
    'Actividades en Casa': categoriesSnapshot.docs[4].id,
    'Diario y Conexión Personal': categoriesSnapshot.docs[5].id,
  };

  final activities = [
    // ✨ Creatividad
    {
      'categoryId': categoryIds['Creatividad'],
      'title': 'Dibujo Express',
      'description': 'Dibuja de manera rápida el primer objeto que veas, sin pensar demasiado, para liberar tu creatividad.',
      'suitableProfiles': ['Uso impulsivo', 'Sobrecarga mental', 'Todos'],
      'duration': 1,
      'score': 20,
      'difficulty': 'easy',
      'activityType': 'photo',
    },
    {
      'categoryId': categoryIds['Creatividad'],
      'title': 'Crea una Sombra Divertida',
      'description': 'Juega con la luz para formar figuras con tus manos y captura una foto de tu creación.',
      'suitableProfiles': ['Uso impulsivo', 'Aislamiento social', 'Todos'],
      'duration': 2,
      'score': 30,
      'difficulty': 'easy',
      'activityType': 'photo',
    },
    {
      'categoryId': categoryIds['Creatividad'],
      'title': 'Escribe una Frase sobre tu Día',
      'description': 'Reflexiona y completa la frase: "Hoy me siento como…" para expresar tu estado emocional.',
      'suitableProfiles': ['Sobrecarga mental', 'Comparacion social', 'Todos'],
      'duration': 1,
      'score': 20,
      'difficulty': 'easy',
      'activityType': 'text',
    },
    {
      'categoryId': categoryIds['Creatividad'],
      'title': 'Haz un Mini Collage',
      'description': 'Combina tres objetos que tengas a mano (papel, ticket, etiqueta…) y crea un pequeño collage visual.',
      'suitableProfiles': ['Uso impulsivo', 'Sobrecarga mental', 'Todos'],
      'duration': 5,
      'score': 50,
      'difficulty': 'easy',
      'activityType': 'photo',
    },
    {
      'categoryId': categoryIds['Creatividad'],
      'title': 'Tostada Creativa',
      'description': 'Prepara y decora una tostada de manera diferente a lo habitual, experimentando con colores y formas.',
      'suitableProfiles': ['Uso impulsivo', 'Aislamiento social', 'Todos'],
      'duration': 5,
      'score': 40,
      'difficulty': 'easy',
      'activityType': 'photo',
    },
    {
      'categoryId': categoryIds['Creatividad'],
      'title': 'Origami Sencillo',
      'description': 'Crea una figura simple de origami, como una estrella, barco o grulla, para ejercitar la concentración y la paciencia.',
      'suitableProfiles': ['Estres digital', 'Sobrecarga mental', 'Todos'],
      'duration': 10,
      'score': 80,
      'difficulty': 'medium',
      'activityType': 'photo',
    },

    // 👁️ Observación
    {
      'categoryId': categoryIds['Observación'],
      'title': 'Busca Tres Colores',
      'description': 'Encuentra a tu alrededor un objeto rojo, uno azul y uno verde, agudizando tu percepción visual.',
      'suitableProfiles': ['Uso impulsivo', 'Sobrecarga mental', 'Todos'],
      'duration': 2,
      'score': 30,
      'difficulty': 'easy',
      'activityType': 'photo',
    },
    {
      'categoryId': categoryIds['Observación'],
      'title': 'Explora Texturas',
      'description': 'Toca un objeto suave, otro áspero y otro frío, prestando atención a las sensaciones de cada superficie.',
      'suitableProfiles': ['Estres digital', 'Sobrecarga mental', 'Todos'],
      'duration': 2,
      'score': 30,
      'difficulty': 'easy',
      'activityType': 'text',
    },
    {
      'categoryId': categoryIds['Observación'],
      'title': 'Encuentra un Detalle Nuevo',
      'description': 'Observa tu entorno y descubre un detalle que normalmente pasas por alto, entrenando tu atención.',
      'suitableProfiles': ['Uso impulsivo', 'Comparacion social', 'Todos'],
      'duration': 3,
      'score': 40,
      'difficulty': 'easy',
      'activityType': 'photo',
    },
    {
      'categoryId': categoryIds['Observación'],
      'title': 'Sonidos del Entorno',
      'description': 'Escucha atentamente y reconoce tres sonidos diferentes que estén ocurriendo a tu alrededor.',
      'suitableProfiles': ['Estres digital', 'Sobrecarga mental', 'Todos'],
      'duration': 2,
      'score': 30,
      'difficulty': 'easy',
      'activityType': 'text',
    },
    {
      'categoryId': categoryIds['Observación'],
      'title': 'Busca un Objeto que te Transmita Calma',
      'description': 'Selecciona un objeto cercano que te genere tranquilidad, como una planta, foto o taza, y obsérvalo.',
      'suitableProfiles': ['Estres digital', 'Sobrecarga mental', 'Comparacion social', 'Todos'],
      'duration': 3,
      'score': 40,
      'difficulty': 'easy',
      'activityType': 'photo',
    },
    {
      'categoryId': categoryIds['Observación'],
      'title': 'Observación del Cielo',
      'description': 'Mira el cielo durante 30 segundos e intenta notar colores, formas o movimientos que no habías visto antes.',
      'suitableProfiles': ['Sobrecarga mental', 'Aislamiento social', 'Todos'],
      'duration': 1,
      'score': 20,
      'difficulty': 'easy',
      'activityType': 'text',
    },

    // 🚶 Paseo Consciente
    {
      'categoryId': categoryIds['Paseo Consciente'],
      'title': 'Encuentra una Nube con Forma',
      'description': 'Durante tu paseo, observa las nubes y encuentra una que tenga forma de animal, objeto o letra.',
      'suitableProfiles': ['Aislamiento social', 'Sobrecarga mental', 'Todos'],
      'duration': 5,
      'score': 50,
      'difficulty': 'easy',
      'activityType': 'photo',
    },
    {
      'categoryId': categoryIds['Paseo Consciente'],
      'title': 'Busca Algo Grande de Color Azul',
      'description': 'Identifica un objeto grande y azul a tu alrededor, como un coche, señal o escaparate, mientras paseas con atención.',
      'suitableProfiles': ['Uso impulsivo', 'Aislamiento social', 'Todos'],
      'duration': 5,
      'score': 50,
      'difficulty': 'easy',
      'activityType': 'photo',
    },
    {
      'categoryId': categoryIds['Paseo Consciente'],
      'title': 'Camina Sintiendo tus Pasos',
      'description': 'Concéntrate en el contacto de tus pies con el suelo mientras caminas durante dos minutos, notando cada sensación.',
      'suitableProfiles': ['Estres digital', 'Sobrecarga mental', 'Todos'],
      'duration': 2,
      'score': 30,
      'difficulty': 'easy',
      'activityType': 'simple',
    },
    {
      'categoryId': categoryIds['Paseo Consciente'],
      'title': 'Identifica Tres Plantas Diferentes',
      'description': 'Durante tu paseo, observa y reconoce tres tipos de plantas, flores o árboles distintos.',
      'suitableProfiles': ['Aislamiento social', 'Comparacion social', 'Todos'],
      'duration': 5,
      'score': 50,
      'difficulty': 'easy',
      'activityType': 'photo',
    },
    {
      'categoryId': categoryIds['Paseo Consciente'],
      'title': 'Sigue un Sonido',
      'description': 'Presta atención a un sonido suave en tu entorno y acércate mentalmente a su origen mientras caminas.',
      'suitableProfiles': ['Uso impulsivo', 'Sobrecarga mental', 'Todos'],
      'duration': 5,
      'score': 60,
      'difficulty': 'medium',
      'activityType': 'text',
    },
    {
      'categoryId': categoryIds['Paseo Consciente'],
      'title': 'Explora un Camino Distinto',
      'description': 'Cambia una calle o giro de tu ruta habitual para descubrir algo nuevo y diferente durante tu paseo.',
      'suitableProfiles': ['Aislamiento social', 'Uso impulsivo', 'Todos'],
      'duration': 10,
      'score': 80,
      'difficulty': 'easy',
      'activityType': 'simple',
    },

    // 🌬️ Meditación y Respiración
    {
      'categoryId': categoryIds['Meditación y Respiración'],
      'title': 'Respiración 4-2-6',
      'description': 'Inhala durante 4 segundos, mantén la respiración 2 segundos y exhala durante 6 segundos, relajando cuerpo y mente.',
      'suitableProfiles': ['Estres digital', 'Sobrecarga mental', 'Todos'],
      'duration': 2,
      'score': 30,
      'difficulty': 'easy',
      'activityType': 'meditation',
    },
    {
      'categoryId': categoryIds['Meditación y Respiración'],
      'title': 'Respiración Cuadrada',
      'description': 'Inhala 4s, retén 4s, exhala 4s y retén 4s, promoviendo concentración y calma interior.',
      'suitableProfiles': ['Estres digital', 'Uso impulsivo', 'Todos'],
      'duration': 2,
      'score': 30,
      'difficulty': 'easy',
      'activityType': 'meditation',
    },
    {
      'categoryId': categoryIds['Meditación y Respiración'],
      'title': 'Atención a la Respiración',
      'description': 'Observa el flujo de tu respiración sin intentar modificarlo, centrándote en cada inhalación y exhalación.',
      'suitableProfiles': ['Sobrecarga mental', 'Estres digital', 'Todos'],
      'duration': 3,
      'score': 40,
      'difficulty': 'easy',
      'activityType': 'meditation',
    },
    {
      'categoryId': categoryIds['Meditación y Respiración'],
      'title': 'Cuenta 10 Respiraciones',
      'description': 'Cuenta cada ciclo de inhalar+exhalar hasta 10 para entrenar la atención y la calma.',
      'suitableProfiles': ['Uso impulsivo', 'Sobrecarga mental', 'Todos'],
      'duration': 2,
      'score': 30,
      'difficulty': 'easy',
      'activityType': 'meditation',
    },
    {
      'categoryId': categoryIds['Meditación y Respiración'],
      'title': 'Escaneo Corporal Rápido',
      'description': 'Recorre mentalmente tu cuerpo desde la cabeza hasta los pies, notando sensaciones y tensiones.',
      'suitableProfiles': ['Estres digital', 'Sobrecarga mental', 'Comparacion social', 'Todos'],
      'duration': 5,
      'score': 50,
      'difficulty': 'medium',
      'activityType': 'meditation',
    },
    {
      'categoryId': categoryIds['Meditación y Respiración'],
      'title': 'Mantra Personal Silencioso',
      'description': 'Repite mentalmente un mantra como "aquí y ahora" con cada respiración para centrar la mente.',
      'suitableProfiles': ['Estres digital', 'Comparacion social', 'Todos'],
      'duration': 3,
      'score': 40,
      'difficulty': 'easy',
      'activityType': 'meditation',
    },

    // 🏠 Actividades en Casa
    {
      'categoryId': categoryIds['Actividades en Casa'],
      'title': 'Organiza un Espacio en 1 Minuto',
      'description': 'Dedica un minuto a ordenar un espacio pequeño como tu escritorio, mesita o estantería para despejar la mente.',
      'suitableProfiles': ['Uso impulsivo', 'Sobrecarga mental', 'Todos'],
      'duration': 1,
      'score': 20,
      'difficulty': 'easy',
      'activityType': 'simple',
    },
    {
      'categoryId': categoryIds['Actividades en Casa'],
      'title': 'Encuentra Tres Objetos de una Categoría',
      'description': 'Localiza tres objetos que compartan una característica: redondos, de madera o pequeños, observando tu entorno con atención.',
      'suitableProfiles': ['Uso impulsivo', 'Sobrecarga mental', 'Todos'],
      'duration': 2,
      'score': 30,
      'difficulty': 'easy',
      'activityType': 'photo',
    },
    {
      'categoryId': categoryIds['Actividades en Casa'],
      'title': 'Prepara una Bebida Caliente',
      'description': 'Tómate tu tiempo para preparar té, infusión o cacao, disfrutando del proceso con calma.',
      'suitableProfiles': ['Estres digital', 'Sobrecarga mental', 'Todos'],
      'duration': 5,
      'score': 40,
      'difficulty': 'easy',
      'activityType': 'photo',
    },
    {
      'categoryId': categoryIds['Actividades en Casa'],
      'title': 'Riega una Planta',
      'description': 'Cuida una planta, flor o pequeño cultivo, conectando con algo vivo y presente.',
      'suitableProfiles': ['Aislamiento social', 'Sobrecarga mental', 'Todos'],
      'duration': 2,
      'score': 30,
      'difficulty': 'easy',
      'activityType': 'simple',
    },
    {
      'categoryId': categoryIds['Actividades en Casa'],
      'title': 'Abre una Ventana y Respira Aire Fresco',
      'description': 'Durante 20–30 segundos, inspira aire fresco y siente cómo refresca tu mente y cuerpo.',
      'suitableProfiles': ['Estres digital', 'Sobrecarga mental', 'Todos'],
      'duration': 1,
      'score': 20,
      'difficulty': 'easy',
      'activityType': 'simple',
    },
    {
      'categoryId': categoryIds['Actividades en Casa'],
      'title': 'Luz y Ambiente',
      'description': 'Modifica la iluminación de la habitación (natural, lámpara o velas) durante un minuto para cambiar tu percepción del espacio.',
      'suitableProfiles': ['Sobrecarga mental', 'Comparacion social', 'Todos'],
      'duration': 1,
      'score': 20,
      'difficulty': 'easy',
      'activityType': 'simple',
    },

    // 📓 Diario y Conexión Personal
    {
      'categoryId': categoryIds['Diario y Conexión Personal'],
      'title': 'Escribe una Cosa Buena del Día',
      'description': 'Reflexiona y anota algo positivo que haya ocurrido, sin importar lo pequeño que sea.',
      'suitableProfiles': ['Comparacion social', 'Aislamiento social', 'Todos'],
      'duration': 1,
      'score': 20,
      'difficulty': 'easy',
      'activityType': 'text',
    },
    {
      'categoryId': categoryIds['Diario y Conexión Personal'],
      'title': 'Emoción Actual',
      'description': 'Identifica la emoción que sientes ahora y escribe brevemente la razón detrás de ella.',
      'suitableProfiles': ['Sobrecarga mental', 'Comparacion social', 'Todos'],
      'duration': 2,
      'score': 30,
      'difficulty': 'easy',
      'activityType': 'text',
    },
    {
      'categoryId': categoryIds['Diario y Conexión Personal'],
      'title': 'Una Gratitud Simple',
      'description': 'Anota algo cotidiano por lo que estés agradecido, como una comida, una conversación o un momento tranquilo.',
      'suitableProfiles': ['Comparacion social', 'Aislamiento social', 'Todos'],
      'duration': 1,
      'score': 20,
      'difficulty': 'easy',
      'activityType': 'text',
    },
    {
      'categoryId': categoryIds['Diario y Conexión Personal'],
      'title': 'Objetivo Mini del Día',
      'description': 'Establece un objetivo muy pequeño y alcanzable para hoy: beber agua, salir 5 minutos, o algo similar.',
      'suitableProfiles': ['Uso impulsivo', 'Aislamiento social', 'Todos'],
      'duration': 1,
      'score': 20,
      'difficulty': 'easy',
      'activityType': 'text',
    },
    {
      'categoryId': categoryIds['Diario y Conexión Personal'],
      'title': 'Describe tu Energía en una Palabra',
      'description': 'Identifica con una sola palabra cómo te sientes: activo, tranquilo, disperso, cansado…',
      'suitableProfiles': ['Sobrecarga mental', 'Estres digital', 'Todos'],
      'duration': 1,
      'score': 20,
      'difficulty': 'easy',
      'activityType': 'text',
    },
    {
      'categoryId': categoryIds['Diario y Conexión Personal'],
      'title': 'Escribe Algo que Estés Esperando',
      'description': 'Anota algo que esperes con ilusión, ya sea del día o de la semana, para conectar con la anticipación positiva.',
      'suitableProfiles': ['Comparacion social', 'Aislamiento social', 'Todos'],
      'duration': 2,
      'score': 30,
      'difficulty': 'easy',
      'activityType': 'text',
    },
  ];


    for (var activity in activities) {
      await _firestore.collection('activities').add(activity);
      print('✓ Actividad creada: ${activity['title']}');
    }
  }

  /// Limpia toda la base de datos (usar con precaución)
  static Future<void> clearDatabase() async {
    try {
      print('🗑️ Limpiando base de datos...');
      
      // Eliminar todas las actividades
      final activitiesSnapshot = await _firestore.collection('activities').get();
      for (var doc in activitiesSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Eliminar todas las categorías
      final categoriesSnapshot = await _firestore.collection('activity_categories').get();
      for (var doc in categoriesSnapshot.docs) {
        await doc.reference.delete();
      }
      
      print('✅ Base de datos limpiada');
    } catch (e) {
      print('❌ Error al limpiar base de datos: $e');
    }
  }

  /// Reinicia la base de datos (limpia y vuelve a crear)
  static Future<void> resetDatabase() async {
    await clearDatabase();
    await _createSampleCategories();
    await _createSampleActivities();
    print('✅ Base de datos reiniciada con datos de ejemplo');
  }
}
