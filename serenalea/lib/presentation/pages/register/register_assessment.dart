import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
// Devuelve las recomendaciones al formulario de registro en lugar de registrar aquí

class RegisterAssessmentPage extends StatefulWidget {
  const RegisterAssessmentPage({Key? key}) : super(key: key);

  @override
  State<RegisterAssessmentPage> createState() => _RegisterAssessmentPageState();
}

class _RegisterAssessmentPageState extends State<RegisterAssessmentPage> {
  // Estructura de preguntas por sección
  final Map<String, List<String>> sections = {
    'Estrés y ansiedad digital': [
      'Me siento inquieto o nervioso cuando no tengo el móvil cerca.',
      'Miro el móvil aunque no haya recibido notificaciones.',
      'Uso el móvil para distraerme cuando me siento ansioso o aburrido.',
      'Me cuesta dejar de pensar en el móvil cuando intento concentrarme.',
      'Siento que el móvil interfiere en mi descanso.',
    ],
    'Impulsividad y pérdida de control': [
      'Prometo usar menos el móvil, pero acabo usándolo igual.',
      'Siento necesidad de revisar las redes sociales constantemente.',
      'Cuando me doy cuenta, he pasado más tiempo del que quería usando el móvil.',
      'Me resulta difícil apagar las notificaciones o silenciar el móvil.',
      'A veces actúo impulsivamente con el móvil sin pensar en consecuencias.',
    ],
    'Dificultad de concentración': [
      'Me cuesta concentrarme en mis tareas por mirar el móvil con frecuencia.',
      'Cuando dejo el móvil, me cuesta mantener la atención.',
      'Pierdo fácilmente el hilo de lo que estaba haciendo por mirar el móvil.',
    ],
    'Aislamiento y desconexión social': [
      'Prefiero pasar tiempo en redes sociales que hablar con alguien cara a cara.',
      'Siento que uso el móvil para evitar momentos incómodos con otras personas.',
      'Me resulta más fácil comunicarme por mensaje que en persona.',
    ],
    'Autoestima y comparación social': [
      'Me comparo con las vidas o cuerpos de otras personas en redes sociales.',
      'A veces siento que mi vida es menos interesante que la de los demás online.',
      'Publicar en redes me genera ansiedad por la valoración de otros.',
    ],
  };

  // Almacenar respuestas (0-3) por pregunta usando la misma clave de sección y lista de ints
  final Map<String, List<int>> answers = {};

  @override
  void initState() {
    super.initState();
    // Inicializar arrays de respuestas con ceros
    for (final entry in sections.entries) {
      answers[entry.key] = List.filled(entry.value.length, 0);
    }
    // iniciar en la primera sección/pregunta
    _currentSection = 0;
    _currentQuestion = 0;
  }

  void _setAnswer(String section, int questionIndex, int value) {
    setState(() {
      answers[section]![questionIndex] = value;
    });
  }

  int _sumSection(String section) => answers[section]!.fold(0, (a, b) => a + b);

  /// Calcula la puntuación por sección y devuelve el/los perfil(es) dominantes.
  /// Devuelve una lista con el/los nombre(s) del perfil(es) (por ejemplo
  /// 'Estrés digital', 'Uso impulsivo', ...). En caso de empate se devuelven
  /// todos los perfiles con la puntuación máxima.
  List<String> _computeProfiles() {
    // Calculamos la puntuación por sección
    final Map<String, int> scores = {};
    for (final section in sections.keys) {
      scores[section] = _sumSection(section);
    }

    // Mapear los nombres de sección a los nombres de perfil deseados
    final Map<String, String> sectionToProfile = {
      'Estrés y ansiedad digital': 'Estrés digital',
      'Impulsividad y pérdida de control': 'Uso impulsivo',
      'Dificultad de concentración': 'Sobrecarga mental',
      'Aislamiento y desconexión social': 'Aislamiento social',
      'Autoestima y comparación social': 'Comparación social',
    };

    // Umbrales por sección para considerar que ese perfil está presente.
    // (Estos valores reflejan la lógica previa: e.g. 12 para bloques de 5 items,
    // 6 para bloques de 3 items, etc.)
    final Map<String, int> thresholds = {
      'Estrés y ansiedad digital': 12,
      'Impulsividad y pérdida de control': 12,
      'Dificultad de concentración': 6,
      'Aislamiento y desconexión social': 6,
      'Autoestima y comparación social': 6,
    };

    final List<String> detected = [];
    scores.forEach((section, value) {
      final threshold = thresholds[section] ?? 6;
      if (value >= threshold) {
        detected.add(sectionToProfile[section] ?? section);
      }
    });

    // Si no se detecta ningún perfil según umbrales, devolver el perfil por defecto
    if (detected.isEmpty) return ['General'];
    return detected;
  }

  Future<void> _finishRegistration(Map<String, dynamic> partialData) async {
    // En vez de registrar aquí, devolvemos el/los perfil(es) detectado(s) al formulario
    final profiles = _computeProfiles();
    Navigator.pop(context, profiles);
  }

  // Estado de navegación del cuestionario (sección y pregunta)
  late int _currentSection;
  late int _currentQuestion;

  int get _totalSections => sections.keys.length;

  int get _totalQuestions {
    int t = 0;
    for (final v in sections.values) t += v.length;
    return t;
  }

  // Calcula índice global (1-based) para mostrar progreso
  int get _globalIndex {
    int idx = 0;
    for (int s = 0; s < _currentSection; s++) {
      idx += sections.values.elementAt(s).length;
    }
    idx += _currentQuestion + 1;
    return idx;
  }

  void _nextQuestion() {
    final questions = sections.values.elementAt(_currentSection).length;
    setState(() {
      if (_currentQuestion < questions - 1) {
        _currentQuestion++;
      } else if (_currentSection < _totalSections - 1) {
        _currentSection++;
        _currentQuestion = 0;
      }
    });
  }

  void _prevQuestion() {
    setState(() {
      if (_currentQuestion > 0) {
        _currentQuestion--;
      } else if (_currentSection > 0) {
        _currentSection--;
        _currentQuestion = sections.values.elementAt(_currentSection).length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final partialData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cuestionario de preferencias'),
        backgroundColor: AppColors.color1,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.color1.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.quiz_rounded, color: AppColors.color2),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Responde con: Nunca (0), A veces (1), A menudo (2), Siempre (3)',
                      style: TextStyle(color: AppColors.color1, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Single-question view: muestra una pregunta centrada y las opciones debajo
            Builder(builder: (_) {
              final sectionKey = sections.keys.elementAt(_currentSection);
              final questionText = sections[sectionKey]![_currentQuestion];
              final currentScore = _sumSection(sectionKey);
              final total = _totalQuestions;
              final index = _globalIndex;

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: AppColors.color1.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 6))],
                    ),
                    child: Column(
                      children: [
                        Text(sectionKey, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.color1), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(questionText, style: TextStyle(fontSize: 20, color: AppColors.color1, height: 1.3), textAlign: TextAlign.center),
                        const SizedBox(height: 18),
                        Text('Score sección: $currentScore', style: TextStyle(color: AppColors.color2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(4, (opt) {
                      final labels = ['Nunca', 'A veces', 'A menudo', 'Siempre'];
                      final selected = answers[sectionKey]![_currentQuestion] == opt;
                      return ChoiceChip(
                        label: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Text(labels[opt], style: TextStyle(fontSize: 16, color: selected ? Colors.white : AppColors.color1)),
                        ),
                        selected: selected,
                        onSelected: (_) => _setAnswer(sectionKey, _currentQuestion, opt),
                        selectedColor: AppColors.color1,
                        backgroundColor: AppColors.softBlue,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      );
                    }),
                  ),
                  const SizedBox(height: 22),
                  Text('$index de $total', style: TextStyle(color: AppColors.color3)),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!(_currentSection == 0 && _currentQuestion == 0))
                        OutlinedButton(
                          onPressed: _prevQuestion,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.color1,
                            side: BorderSide(color: AppColors.color1.withOpacity(0.18)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                          child: const Text('Atrás'),
                        )
                      else
                        const SizedBox(width: 90),
                      ElevatedButton(
                        onPressed: () {
                          // Si es la última pregunta de la última sección -> finalizar
                          final isLastSection = _currentSection == _totalSections - 1;
                          final isLastQuestion = _currentQuestion == sections.values.elementAt(_currentSection).length - 1;
                          if (isLastSection && isLastQuestion) {
                            _finishRegistration(partialData);
                          } else {
                            _nextQuestion();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.color1,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text((_currentSection == _totalSections - 1 && _currentQuestion == sections.values.elementAt(_currentSection).length - 1) ? 'Finalizar' : 'Siguiente'),
                      ),
                    ],
                  ),
                ],
              );
            }),
            Builder(builder: (ctx) {
              final profiles = _computeProfiles();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (profiles.isNotEmpty) ...[
                    const Text('Perfil detectado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(profiles.join(', '), style: TextStyle(color: AppColors.color2, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.color1,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _finishRegistration(partialData),
                    child: const Text('Finalizar registro'),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
