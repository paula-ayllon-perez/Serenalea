import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 80, color: AppColors.color1),
                const SizedBox(height: 20),
                Text(
                  "Iniciar Sesión",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.color1,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: "Usuario",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor introduce tu usuario";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor introduce tu contraseña";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Aquí iría la lógica de login
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Iniciando sesión...")),
                        );
                      }
                    },
                    child: const Text("Entrar"),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Navegar a página de registro
                  },
                  child: Text(
                    "¿No tienes cuenta? Regístrate",
                    style: TextStyle(color: AppColors.color2),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
