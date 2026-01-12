import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:serenalea/data/models/user_dto.dart';

class UserFirestoreService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users'); // en plural por convención
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // REGISTRO: crea en Auth y luego guarda en Firestore
  Future<void> registerUser(String email, String password, User user, {File? profileImageFile}) async {
    try {
      // 1. Crear en Firebase Authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 2. Si hay imagen de perfil, subirla con el UID y obtener la URL
      String? finalPhotoUrl = user.photoUrl;
      if (profileImageFile != null) {
        final storageRef = firebase_storage.FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
        final uploadTask = storageRef.putFile(profileImageFile);
        final snapshot = await uploadTask;
        finalPhotoUrl = await snapshot.ref.getDownloadURL();
      }

      // 3. Guardar datos extra en Firestore con ese UID (incluyendo foto final si existe)
      final userToSave = User(
        uid: uid,
        birthYear: user.birthYear,
        email: user.email,
        firstName: user.firstName,
        gender: user.gender,
        lastName: user.lastName,
        phone: user.phone,
        profiles: user.profiles,
        photoUrl: finalPhotoUrl,
      );

      await usersCollection.doc(uid).set(userToSave.toMap());

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

  // ACTUALIZAR USUARIO: actualiza los datos en Firestore
  Future<void> updateUser(String uid, User user) async {
    try {
      await usersCollection.doc(uid).update(user.toMap());
    } catch (e) {
      rethrow;
    }
  }
}
