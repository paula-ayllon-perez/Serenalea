import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../data/models/user_dto.dart';
import '../../../data/repositories/user_repository.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final UserRepository _userRepository = UserRepository();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _profileController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();

  // Lista de años (últimos 100 años)
  final List<int> years = List.generate(100, (index) => DateTime.now().year - index);
  int selectedYear = DateTime.now().year;

  // Lista de géneros
  final List<String> genders = ['Femenino', 'Masculino', 'Prefiero no decirlo'];
  String? selectedGender;

  void _showYearPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 400,
          child: CupertinoPicker(
            itemExtent: 42,
            scrollController: FixedExtentScrollController(initialItem: 0),
            onSelectedItemChanged: (index) {
              setState(() {
                selectedYear = years[index];
                _birthYearController.text = selectedYear.toString();
              });
            },
            children: years.map((y) => Center(child: Text(y.toString()))).toList(),
          ),
        );
      },
    );
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = User(
          uid: '', // El repositorio/servicio lo asigna tras crear en Auth
          birthYear: int.tryParse(_birthYearController.text) ?? 0,
          email: _emailController.text,
          firstName: _firstNameController.text,
          gender: _genderController.text,
          lastName: _lastNameController.text,
          phone: _phoneController.text,
          profiles: [_profileController.text],
          photoUrl: _photoUrlController.text.isNotEmpty ? _photoUrlController.text : null,
        );
        await _userRepository.registerUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          user: user,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario registrado correctamente')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value == null || value.isEmpty ? 'Introduce tu email' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty ? 'Introduce tu contraseña' : null,
                ),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => value == null || value.isEmpty ? 'Introduce tu nombre' : null,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Apellidos'),
                  validator: (value) => value == null || value.isEmpty ? 'Introduce tus apellidos' : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  validator: (value) => value == null || value.isEmpty ? 'Introduce tu teléfono' : null,
                ),
                // Año con picker
                TextFormField(
                  controller: _birthYearController,
                  decoration: const InputDecoration(labelText: 'Año de nacimiento'),
                  readOnly: true,
                  onTap: () => _showYearPicker(context),
                  validator: (value) => value == null || value.isEmpty ? 'Selecciona tu año de nacimiento' : null,
                ),
                // Género con dropdown
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(labelText: 'Género'),
                  items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                      _genderController.text = value ?? '';
                    });
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Selecciona tu género' : null,
                ),
                TextFormField(
                  controller: _profileController,
                  decoration: const InputDecoration(labelText: 'Perfil'),
                  validator: (value) => value == null || value.isEmpty ? 'Introduce tu perfil' : null,
                ),
                TextFormField(
                  controller: _photoUrlController,
                  decoration: const InputDecoration(labelText: 'URL de foto de perfil (opcional)'),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerUser,
                    child: const Text('Registrarse'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
