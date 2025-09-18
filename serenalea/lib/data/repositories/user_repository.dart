import '../models/user_dto.dart';
import '../services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class UserRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // Registro: crea usuario en Auth y Firestore
  Future<void> registerUser({
    required String email,
    required String password,
    required User user,
  }) async {
    await _firestoreService.registerUser(email, password, user);
  }

  // Login: devuelve el usuario de FirebaseAuth si es correcto
  Future<fb.User?> login({
    required String email,
    required String password,
  }) async {
    return await _firestoreService.login(email, password);
  }
}
