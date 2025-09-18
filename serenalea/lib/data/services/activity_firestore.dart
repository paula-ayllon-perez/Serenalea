import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_dto.dart';

class ActivityFirestoreService {
  final CollectionReference _activitiesCollection = FirebaseFirestore.instance.collection('activities');

  Future<List<Activity>> getAllActivities() async {
    final snapshot = await _activitiesCollection.get();
    return snapshot.docs
        .map((doc) => Activity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<Activity>> getActivitiesByCategory(String category) async {
    final snapshot = await _activitiesCollection.where('category', isEqualTo: category).get();
    return snapshot.docs
        .map((doc) => Activity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> addActivity(Activity activity) async {
    await _activitiesCollection.add(activity.toMap());
  }

  Future<void> updateActivity(Activity activity) async {
    await _activitiesCollection.doc(activity.id).update(activity.toMap());
  }

  Future<void> deleteActivity(String id) async {
    await _activitiesCollection.doc(id).delete();
  }
}
