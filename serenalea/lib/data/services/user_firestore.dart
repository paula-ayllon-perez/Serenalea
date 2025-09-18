import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:serenalea/data/models/user_dto.dart';

class UserFirestoreService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users'); // en plural por convención
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // REGISTRO: crea en Auth y luego guarda en Firestore
  Future<void> registerUser(String email, String password, User user) async {
    try {
      // 1. Crear en Firebase Authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 2. Guardar datos extra en Firestore con ese UID
      await usersCollection.doc(uid).set(user.toMap());

    } catch (e) {
      rethrow; // lanzar el error al widget para mostrar mensaje
    }
  }

  // LOGIN: solo usa Auth
  Future<auth.User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }
}
