import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/constants/colors.dart';
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
  // Campo de perfil ahora se rellena desde el cuestionario
  List<String> _selectedProfiles = [];
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
      // Registro final: validar que el cuestionario ya fue realizado
      if (_selectedProfiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, completa el cuestionario de perfil antes de registrarte')));
        return;
      }

      final user = User(
        uid: '',
        birthYear: int.tryParse(_birthYearController.text) ?? selectedYear,
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        gender: _genderController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        profiles: _selectedProfiles,
        photoUrl: _photoUrlController.text.isNotEmpty ? _photoUrlController.text.trim() : null,
      );

      try {
        await _userRepository.registerUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          user: user,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario registrado correctamente')));
        Navigator.pushReplacementNamed(context, '/');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error registro: ${e.toString()}')));
      }
    }
  }

  Future<void> _openAssessment() async {
    // Pasamos datos parciales por si son necesarios en el assessment
    final Map<String, dynamic> partialData = {
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'birthYear': int.tryParse(_birthYearController.text) ?? selectedYear,
      'gender': _genderController.text.trim(),
      'photoUrl': _photoUrlController.text.trim(),
    };

    final result = await Navigator.pushNamed(context, '/register-assessment', arguments: partialData);
    if (result != null && result is List<String>) {
      setState(() {
        _selectedProfiles = result;
      });
    }
  }

  Future<void> _onContinuePressed() async {
    // Validar formulario básico antes de continuar
    if (!_formKey.currentState!.validate()) return;

    // Abrir assessment y esperar que rellene _selectedProfiles
    await _openAssessment();

    if (_selectedProfiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se detectó perfil. Por favor completa el cuestionario.')));
      return;
    }

    // Si hay perfiles, continuar con el registro automáticamente
    await _registerUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
        backgroundColor: AppColors.color1,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Encabezado breve
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.color1.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_add_alt_1_rounded, color: AppColors.color2),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Crea tu cuenta — paso 1: datos básicos',
                        style: TextStyle(color: AppColors.color1, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Card contenedor del formulario
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Campos con estilo
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Introduce tu email' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          obscureText: true,
                          validator: (value) => value == null || value.isEmpty ? 'Introduce tu contraseña' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Introduce tu nombre' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Apellidos',
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Introduce tus apellidos' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Teléfono',
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Introduce tu teléfono' : null,
                        ),
                        const SizedBox(height: 12),

                        // Año con picker
                        TextFormField(
                          controller: _birthYearController,
                          decoration: InputDecoration(
                            labelText: 'Año de nacimiento',
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            suffixIcon: Icon(Icons.calendar_today, color: AppColors.color3),
                          ),
                          readOnly: true,
                          onTap: () => _showYearPicker(context),
                          validator: (value) => value == null || value.isEmpty ? 'Selecciona tu año de nacimiento' : null,
                        ),
                        const SizedBox(height: 12),

                        // Género con dropdown
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          decoration: InputDecoration(
                            labelText: 'Género',
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value;
                              _genderController.text = value ?? '';
                            });
                          },
                          validator: (value) => value == null || value.isEmpty ? 'Selecciona tu género' : null,
                        ),
                        const SizedBox(height: 12),

                        // Foto (opcional)
                        TextFormField(
                          controller: _photoUrlController,
                          decoration: InputDecoration(
                            labelText: 'URL de foto de perfil (opcional)',
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Botón principal
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _onContinuePressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.color1,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Continuar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
