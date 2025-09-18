class Activity {
  final String id;
  final String title;
  final String description;
  final List<String> suitableProfiles;
  final int duration; // en segundos o minutos
  final int score;
  final String category;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.suitableProfiles,
    required this.duration,
    required this.score,
    required this.category,
  });

  factory Activity.fromMap(Map<String, dynamic> map, String documentId) {
    return Activity(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      suitableProfiles: List<String>.from(map['suitableProfiles'] ?? []),
      duration: map['duration'] ?? 0,
      score: map['score'] ?? 0,
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'suitableProfiles': suitableProfiles,
      'duration': duration,
      'score': score,
      'category': category,
    };
  }
}
