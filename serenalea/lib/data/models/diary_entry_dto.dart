import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryEntryDto {
  final String? id;
  final String userId;
  final String content;
  final DateTime date;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DiaryEntryDto({
    this.id,
    required this.userId,
    required this.content,
    required this.date,
    required this.createdAt,
    this.updatedAt,
  });

  // Convertir de Firestore a objeto
  factory DiaryEntryDto.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DiaryEntryDto(
      id: doc.id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Convertir objeto a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'content': content,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  DiaryEntryDto copyWith({
    String? id,
    String? userId,
    String? content,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntryDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
