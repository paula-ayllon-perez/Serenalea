import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoMemory {
  final String id;
  final String userId;
  final String activityName;
  final String activityCategory;
  final String imagePath; // Ruta local o URL de Firebase Storage
  final DateTime date;
  final String? description;

  PhotoMemory({
    required this.id,
    required this.userId,
    required this.activityName,
    required this.activityCategory,
    required this.imagePath,
    required this.date,
    this.description,
  });

  factory PhotoMemory.fromMap(Map<String, dynamic> map, String documentId) {
    return PhotoMemory(
      id: documentId,
      userId: map['userId'] ?? '',
      activityName: map['activityName'] ?? '',
      activityCategory: map['activityCategory'] ?? '',
      imagePath: map['imagePath'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'activityName': activityName,
      'activityCategory': activityCategory,
      'imagePath': imagePath,
      'date': Timestamp.fromDate(date),
      'description': description,
    };
  }
}
