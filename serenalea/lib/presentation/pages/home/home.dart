import '../../../core/constants/colors.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import '../../widgets/main_drawer.dart';
import '../../../data/models/activity_dto.dart';
import '../../../data/repositories/activity_repository.dart';
import '../activities/activity/walk_activity.dart';
import '../activities/activity/mindfullness_activity.dart';
import '../activities/activity/creative_actovity.dart';
import '../activities/activity/observing_activity.dart';

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
    _setRandomGratitude();
    _loadRecommendedActivities();
  }

  // Repositorio
  final ActivityRepository _activityRepo = ActivityRepository();

  // Recomendadas
  List<Activity> _recommendedActivities = [];
  bool _loadingRecommendations = true;

  void _openActivity(Activity activity) {
    if (activity.category.toLowerCase() == 'walk' || activity.title.toLowerCase().contains('paseo')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WalkActivityPage()),
      );
    } else if (activity.category.toLowerCase() == 'mindfulness' || activity.title.toLowerCase().contains('mindfulness')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MindfulnessActivityPage()),
      );
    } else if (activity.category.toLowerCase() == 'creativa' || activity.title.toLowerCase().contains('creativa')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreativeActivityPage()),
      );
    } else if (activity.category.toLowerCase() == 'observación' || activity.title.toLowerCase().contains('observación')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ObservingActivityPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Actividad aún no implementada.')));
    }
  }

  Future<void> _loadRecommendedActivities() async {
    try {
      final activities = await _activityRepo.getAllActivities();
      final firebaseUser = FirebaseAuth.instance.currentUser;

      // Si no hay usuario autenticado, mostramos actividades marcadas como 'Todos'
      if (firebaseUser == null) {
        _recommendedActivities = activities.where((a) => a.suitableProfiles.map((s) => s.toLowerCase()).contains('todos')).toList();
      } else {
        final doc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
        final List<String> userProfiles = doc.exists ? List<String>.from(doc.data()?['profiles'] ?? []) : [];

        _recommendedActivities = activities.where((a) {
          final lower = a.suitableProfiles.map((s) => s.toLowerCase()).toList();
          if (lower.contains('todos')) return true;
          for (final p in userProfiles) {
            if (lower.contains(p.toLowerCase())) return true;
          }
          return false;
        }).toList();
      }
    } catch (e) {
      // En caso de error dejamos lista vacía (se puede loggear si hace falta)
      _recommendedActivities = [];
    } finally {
      if (mounted) setState(() => _loadingRecommendations = false);
    }
  }

  void _setRandomGratitude() {
    final random = Random();
    gratitudeIndex = random.nextInt(gratitudePhrases.length);
    setState(() {});
  }

  // Antes la app añadía actividades por defecto aquí. Se eliminó para evitar duplicados
  // ahora que las actividades ya existen en la colección de Firestore.



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
  final width = size.width;
  // Medidas responsivas (se usan abajo para ajustar paddings y tamaños)
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
              padding: EdgeInsets.symmetric(horizontal: width < 380 ? 16.0 : 24.0),
              child: GestureDetector(
                onTap: _setRandomGratitude,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: width < 380 ? 18 : 22, horizontal: width < 380 ? 14 : 20),
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
                      LayoutBuilder(builder: (ctx, cons) {
                        final double fs = width < 360 ? 16 : (width < 480 ? 18 : 20);
                        return Text(
                          gratitudePhrases[gratitudeIndex],
                          style: TextStyle(
                            fontSize: fs,
                            fontWeight: FontWeight.w500,
                            color: AppColors.color1,
                            height: 1.35,
                          ),
                        );
                      }),
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
            const SizedBox(height: 18),

            // Sección: Actividades recomendadas (lista vertical, igual que la sección "Todas compatibles")
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width < 380 ? 16.0 : 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text('Actividades recomendadas', style: TextStyle(fontSize: width < 380 ? 16 : 18, fontWeight: FontWeight.w600, color: AppColors.color1))),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/activities'),
                    child: Text('Explorar', style: TextStyle(color: AppColors.color3)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width < 380 ? 12.0 : 20.0),
              child: _loadingRecommendations
                  ? const Center(child: CircularProgressIndicator())
                  : _recommendedActivities.isEmpty
                      ? Text('No hay recomendaciones por ahora. Explora las actividades disponibles.', style: TextStyle(color: AppColors.color3))
                      : Column(
                          children: _recommendedActivities.map((a) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: width < 380 ? 12.0 : 14.0),
                              child: Material(
                                color: AppColors.white,
                                elevation: 2,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _openActivity(a),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(horizontal: width < 380 ? 12 : 16, vertical: width < 380 ? 10 : 14),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: width < 380 ? 56 : 72,
                                          height: width < 380 ? 56 : 72,
                                          decoration: BoxDecoration(
                                            color: AppColors.softBlue,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(child: Icon(Icons.self_improvement_rounded, color: AppColors.color2)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(a.title, style: TextStyle(fontSize: width < 380 ? 14 : 16, fontWeight: FontWeight.w600, color: AppColors.color1)),
                                              const SizedBox(height: 6),
                                              Text(a.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.color2, fontSize: width < 380 ? 12 : 13)),
                                              const SizedBox(height: 6),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(a.category, style: TextStyle(color: AppColors.color3, fontSize: width < 380 ? 11 : 12)),
                                                  Text('${a.duration} min', style: TextStyle(color: AppColors.color4, fontSize: width < 380 ? 11 : 12)),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
            ),
            
            const SizedBox(height: 8),
            const SizedBox(height: 14),
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
