import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/user_dto.dart' as local;

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);



  Future<local.User?> _getUserData(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return local.User.fromMap(doc.data()!, uid);
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.color1,
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: firebaseUser == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_rounded, size: 60, color: AppColors.color2),
                  const SizedBox(height: 16),
                  const Text(
                    'No has iniciado sesión',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Para ver tu perfil, inicia sesión o regístrate.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Iniciar sesión'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.color1,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                      ),
                      const SizedBox(width: 18),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.person_add_rounded),
                        label: const Text('Registrarse'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.color2,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                      ),
                    ],
                  ),
                ],
              )
            : FutureBuilder<local.User?>(
                future: _getUserData(firebaseUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final user = snapshot.data;
                  if (user == null) {
                    return const Text('No se encontraron datos de perfil.');
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      color: AppColors.softBlue,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: AppColors.color2,
                              child: Icon(Icons.person_rounded, size: 54, color: Colors.white),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              '${user.firstName} ${user.lastName}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.color1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.color2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cake_rounded, color: AppColors.color3, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  'Año nacimiento: ${user.birthYear}',
                                  style: TextStyle(fontSize: 14, color: AppColors.color3),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.wc_rounded, color: AppColors.color4, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  'Género: ${user.gender}',
                                  style: TextStyle(fontSize: 14, color: AppColors.color4),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone_rounded, color: AppColors.color5, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  'Teléfono: ${user.phone}',
                                  style: TextStyle(fontSize: 14, color: AppColors.color5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_outline_rounded, color: AppColors.color2, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  'Perfiles: ${user.profiles.join(", ")}',
                                  style: TextStyle(fontSize: 14, color: AppColors.color2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text('Cerrar sesión'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.color1,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              ),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
