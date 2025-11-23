class Activity {
  final String id;
  final String categoryId; // Referencia a la categoría general
  final String title;
  final String description;
  final List<String> suitableProfiles;
  final int duration; // en minutos
  final int score;
  final String difficulty; // 'easy', 'medium', 'hard'
  final String? imageUrl; // Imagen opcional de la actividad
  final String activityType; // 'photo', 'text', 'meditation', 'simple'

  Activity({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.suitableProfiles,
    required this.duration,
    required this.score,
    this.difficulty = 'medium',
    this.imageUrl,
    this.activityType = 'simple', // por defecto 'simple'
  });

  factory Activity.fromMap(Map<String, dynamic> map, String documentId) {
    return Activity(
      id: documentId,
      categoryId: map['categoryId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      suitableProfiles: List<String>.from(map['suitableProfiles'] ?? []),
      duration: map['duration'] ?? 0,
      score: map['score'] ?? 0,
      difficulty: map['difficulty'] ?? 'medium',
      imageUrl: map['imageUrl'],
      activityType: map['activityType'] ?? 'simple',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'suitableProfiles': suitableProfiles,
      'duration': duration,
      'score': score,
      'difficulty': difficulty,
      'imageUrl': imageUrl,
      'activityType': activityType,
    };
  }
  
  // Método de ayuda para obtener el nombre legible de la dificultad
  String get difficultyLabel {
    switch (difficulty) {
      case 'easy':
        return 'Fácil';
      case 'hard':
        return 'Difícil';
      default:
        return 'Medio';
    }
  }
}
