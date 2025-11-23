import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/user_dto.dart' as local;
import '../../../data/repositories/user_repository.dart';
import '../../../core/utils/database_initializer.dart';
import '../../widgets/main_drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserRepository _userRepository = UserRepository();
  
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthYearController = TextEditingController();
  
  String _selectedGender = 'Masculino';
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _birthYearController.dispose();
    super.dispose();
  }

  void _loadUserData(local.User user) {
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _phoneController.text = user.phone;
    _birthYearController.text = user.birthYear.toString();
    _selectedGender = user.gender;
  }

  Future<void> _saveChanges(String uid, String email, List<String> profiles) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedUser = local.User(
        uid: uid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: email,
        birthYear: int.parse(_birthYearController.text.trim()),
        gender: _selectedGender,
        phone: _phoneController.text.trim(),
        profiles: profiles,
      );

      await _userRepository.updateUser(uid, updatedUser);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  Future<local.User?> _getUserData(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return local.User.fromMap(doc.data()!, uid);
  }

  Widget _buildProfileChips(List<String> profiles) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.color2.withOpacity(0.3), width: 1),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: profiles.map((profile) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.color2, AppColors.color2.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.color2.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              profile,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.color1,
      ),
      bottomNavigationBar: const MainBottomBar(),
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
                  
                  // Cargar datos en los controladores si no están cargados
                  if (_firstNameController.text.isEmpty) {
                    _loadUserData(user);
                  }
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      color: AppColors.softBlue,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 44,
                                backgroundColor: AppColors.color2,
                                child: const Icon(Icons.person_rounded, size: 54, color: Colors.white),
                              ),
                              const SizedBox(height: 18),
                              
                              if (!_isEditing) ...[
                                // Vista de solo lectura
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(width: 40), // Espacio para balance
                                    Flexible(
                                      child: Text(
                                        '${user.firstName} ${user.lastName}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.color1,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit_rounded, color: AppColors.color4, size: 20),
                                      onPressed: () {
                                        setState(() => _isEditing = true);
                                      },
                                      padding: const EdgeInsets.only(left: 8),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.color2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(width: 32), // Espacio para balance
                                    Icon(Icons.cake_rounded, color: AppColors.color3, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Año nacimiento: ${user.birthYear}',
                                      style: TextStyle(fontSize: 13, color: AppColors.color3),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit_rounded, color: AppColors.color4, size: 15),
                                      onPressed: () {
                                        setState(() => _isEditing = true);
                                      },
                                      padding: const EdgeInsets.only(left: 6),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(width: 32), // Espacio para balance
                                    Icon(Icons.wc_rounded, color: AppColors.color3, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Género: ${user.gender}',
                                      style: TextStyle(fontSize: 13, color: AppColors.color3),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit_rounded, color: AppColors.color4, size: 15),
                                      onPressed: () {
                                        setState(() => _isEditing = true);
                                      },
                                      padding: const EdgeInsets.only(left: 6),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(width: 32), // Espacio para balance
                                    Icon(Icons.phone_rounded, color: AppColors.color3, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Teléfono: ${user.phone}',
                                      style: TextStyle(fontSize: 13, color: AppColors.color3),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit_rounded, color: AppColors.color4, size: 15),
                                      onPressed: () {
                                        setState(() => _isEditing = true);
                                      },
                                      padding: const EdgeInsets.only(left: 6),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.psychology_rounded, color: AppColors.color2, size: 18),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Perfiles detectados',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildProfileChips(user.profiles),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ] else ...[
                                // Vista de edición
                                Text(
                                  'Editar Perfil',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.color1,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Nombre
                                TextFormField(
                                  controller: _firstNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Nombre',
                                    prefixIcon: const Icon(Icons.person_outline),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Introduce tu nombre';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Apellido
                                TextFormField(
                                  controller: _lastNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Apellido',
                                    prefixIcon: const Icon(Icons.person_outline),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Introduce tu apellido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Teléfono
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    labelText: 'Teléfono',
                                    prefixIcon: const Icon(Icons.phone_rounded),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Introduce tu teléfono';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Año de nacimiento
                                TextFormField(
                                  controller: _birthYearController,
                                  decoration: InputDecoration(
                                    labelText: 'Año de nacimiento',
                                    prefixIcon: const Icon(Icons.cake_rounded),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Introduce tu año de nacimiento';
                                    }
                                    final year = int.tryParse(value);
                                    if (year == null || year < 1900 || year > 2024) {
                                      return 'Año inválido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Género
                                DropdownButtonFormField<String>(
                                  value: _selectedGender,
                                  decoration: InputDecoration(
                                    labelText: 'Género',
                                    prefixIcon: const Icon(Icons.wc_rounded),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: ['Masculino', 'Femenino', 'Otro'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() => _selectedGender = newValue);
                                    }
                                  },
                                ),
                                const SizedBox(height: 24),
                                
                                // Botones de acción
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.close_rounded),
                                      label: const Text('Cancelar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                      ),
                                      onPressed: () {
                                        _loadUserData(user);
                                        setState(() => _isEditing = false);
                                      },
                                    ),
                                    ElevatedButton.icon(
                                      icon: _isLoading 
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.save_rounded),
                                      label: const Text('Guardar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.color1,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                      ),
                                      onPressed: _isLoading 
                                          ? null 
                                          : () => _saveChanges(user.uid, user.email, user.profiles),
                                    ),
                                  ],
                                ),
                              ],
                              
                              const SizedBox(height: 32),
                              
                              // Botón Álbum de fotos
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.photo_album_rounded),
                                  label: const Text('Álbum de fotos'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.color2,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/photo-album');
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Botón Cambiar contraseña
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.lock_reset_rounded),
                                  label: const Text('Cambiar contraseña'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.color3,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/change-password');
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Botón Reiniciar Base de Datos (TEMPORAL - Solo para desarrollo)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Reiniciar Actividades (Dev)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Reiniciar Actividades'),
                                        content: const Text('Esto eliminará todas las categorías y actividades actuales y las reemplazará con las nuevas. ¿Continuar?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Reiniciar'),
                                          ),
                                        ],
                                      ),
                                    );
                                    
                                    if (confirm == true) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Reiniciando base de datos...')),
                                      );
                                      await DatabaseInitializer.resetDatabase();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('✅ Base de datos reiniciada correctamente')),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Botón Cerrar sesión
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
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
                              ),
                            ],
                          ),
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
