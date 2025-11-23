import '../models/diary_entry_dto.dart';
import '../services/diary_firestore.dart';

class DiaryRepository {
  final DiaryFirestore _diaryFirestore = DiaryFirestore();

  Future<String> saveDiaryEntry(DiaryEntryDto entry) async {
    return await _diaryFirestore.saveDiaryEntry(entry);
  }

  Future<DiaryEntryDto?> getEntryByDate(String userId, DateTime date) async {
    return await _diaryFirestore.getEntryByDate(userId, date);
  }

  Future<List<DiaryEntryDto>> getUserEntries(String userId) async {
    return await _diaryFirestore.getUserEntries(userId);
  }

  Future<List<DiaryEntryDto>> getEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _diaryFirestore.getEntriesByDateRange(
      userId,
      startDate,
      endDate,
    );
  }

  Future<void> deleteDiaryEntry(String entryId) async {
    return await _diaryFirestore.deleteDiaryEntry(entryId);
  }
}
