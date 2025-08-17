import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serenalea/data/models/user_dto.dart';

class FirestoreService {

  //Get collection of Users
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('User');

  //CREATE: Add a new User
  Future<void> addUser(User user) async {
  await usersCollection.add(user.toMap());
  }
}
