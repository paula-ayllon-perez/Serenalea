import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/repositories/user_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final UserRepository _userRepository = UserRepository();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        await _userRepository.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } on Exception catch (e) {
        String errorMessage = 'Error desconocido';
        if (e.toString().contains('user-not-found')) {
          errorMessage = 'No existe un usuario con ese email.';
        } else if (e.toString().contains('wrong-password') || e.toString().contains('invalid-credential') || e.toString().contains('invalid-email')) {
          errorMessage = 'Credenciales incorrectas.';
        } else if (e.toString().contains('firebase_auth')) {
          errorMessage = 'Error de autenticación.';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        setState(() {
          _errorMessage = errorMessage;
        });
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'lib/core/utils/assets/Logo.png',
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Iniciar Sesión',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColors.color1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Introduce tu email' : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          obscureText: true,
                          validator: (value) => value == null || value.isEmpty ? 'Introduce tu contraseña' : null,
                        ),
                        const SizedBox(height: 18),
                        if (_errorMessage != null) ...[
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                        ],
                        _isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CircularProgressIndicator(),
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.color1,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  onPressed: _loginUser,
                                  child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
                                ),
                              ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            '¿No tienes cuenta? Regístrate aquí',
                            style: TextStyle(color: AppColors.color2),
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
