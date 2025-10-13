import '../../../core/constants/colors.dart';

import 'dart:math';

import 'package:flutter/material.dart';


import '../../widgets/main_drawer.dart';
import '../../../data/models/activity_dto.dart';
import '../../../data/repositories/activity_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> gratitudePhrases = [
    // Frases de gratitud
    "Gracias por seguir adelante a pesar de las dificultades.",
    "Hoy es un nuevo día lleno de oportunidades.",
    "Gracias por todo lo que tengo y por lo que está por venir.",
    "Gracias por las oportunidades que trae cada día.",
    "Hoy estás brillando con luz propia",
    "Estás increíble, no lo olvides.",
    "Hoy vas a arrasar, como siempre.",
    "Tu sonrisa puede cambiar el día de alguien ",
    "Estás más fuerte de lo que imaginas.",
    "Hoy es un gran día para creer en ti.",
    "Eres suficiente, exactamente como eres.",
    "No necesitas ser perfecto, solo ser tú mismo.",
    "Estás creciendo, aunque a veces no lo notes.",
    "Tienes una energía única, úsala a tu favor.",
    "Eres capaz de cosas maravillosas.",
    "Hoy vas a sorprenderte a ti mismo.",
    "Mírate: estás haciendo lo mejor que puedes, y eso ya es muchísimo.",
    "Hoy caminas con confianza y alegría.",
    "Eres valiente, incluso en los días en que dudas.",
    "Estás aquí, y eso ya es algo grandioso.",
    "Cada paso que das cuenta.",
    "Hoy es tu día, y mereces disfrutarlo.",
    "Eres luz para ti y para quienes te rodean",
    "No hay nadie como tú, y eso es tu superpoder.",
    "Hoy voy a darlo todo.",
    "Yo puedo con todo.",
    "No me voy a rendir.",
    "Cada paso cuenta.",
    "Hoy es una buena oportunidad para avanzar.",
    "Tengo la capacidad de lograr grandes cosas.",
    "Aunque sea difícil, seguiré adelante.",
    "Soy más fuerte de lo que pienso.",
    "Lo importante no es ir rápido, es no detenerse.",
    "Confío en mí y en mi camino.",
    "Cada día es una nueva oportunidad.",
    "Lo que hoy parece pequeño, mañana puede ser enorme.",
    "Puedo con esto y con mucho más.",
    "Hoy elijo creer en mí."
  ];
  int gratitudeIndex = 0;

  @override
  void initState() {
    super.initState();
    _insertDefaultActivitiesIfNeeded();
    _setRandomGratitude();
  }

  void _setRandomGratitude() {
    final random = Random();
    gratitudeIndex = random.nextInt(gratitudePhrases.length);
    setState(() {});
  }

  void _insertDefaultActivitiesIfNeeded() async {
    // (Eliminado bloque duplicado de actividad de observación)
    final repo = ActivityRepository();
    final activities = await repo.getAllActivities();

    // Mindfulness respiración
    final existsMind = activities.any((a) => a.category.toLowerCase() == 'mindfulness' || a.title.toLowerCase().contains('mindfulness'));
    if (!existsMind) {
      final mindActivity = Activity(
        id: '',
        title: 'Respiración Mindfulness',
        description: 'Actividad guiada de respiración con animaciones relajantes.',
        suitableProfiles: ['Todos'],
        duration: 5,
        score: 8,
        category: 'mindfulness',
      );
      await repo.addActivity(mindActivity);
    }

    // Actividad creativa
    final existsCreative = activities.any((a) => a.category.toLowerCase() == 'creativa' || a.title.toLowerCase().contains('creativa'));
    if (!existsCreative) {
      final creativeActivity = Activity(
        id: '',
        title: 'Actividad Creativa',
        description: 'Reto creativo: dibuja, fotografía o crea y comparte tu resultado.',
        suitableProfiles: ['Todos'],
        duration: 5,
        score: 8,
        category: 'creativa',
      );
      await repo.addActivity(creativeActivity);
    }

    // Actividad de observación
    final existsObserving = activities.any((a) => a.category.toLowerCase() == 'observación' || a.title.toLowerCase().contains('observación'));
    if (!existsObserving) {
      final observingActivity = Activity(
        id: '',
        title: 'Actividad de Observación',
        description: 'Reto de observación: observa, busca y comparte una foto de lo que encuentres.',
        suitableProfiles: ['Todos'],
        duration: 5,
        score: 8,
        category: 'observación',
      );
      await repo.addActivity(observingActivity);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: _setRandomGratitude,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.color3.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.color1.withOpacity(0.22),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.wb_sunny_rounded, color: AppColors.color2, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'Frase inspiradora',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: AppColors.color2,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        gratitudePhrases[gratitudeIndex],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppColors.color1,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '¡Bienvenido a la página de inicio!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('Ver actividades'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 4,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/activities');
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
