import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:babyaid/model/colors.dart';
import 'package:babyaid/provider/auth_provider.dart';
import 'package:babyaid/screens/home.dart';
import 'package:babyaid/screens/perfil_update.dart';
import 'package:babyaid/screens/register_user.dart';
import 'package:babyaid/services/auth_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _storage = const FlutterSecureStorage();
  // Esta es la función que debes colocar aquí
  void _handleGoogleSignIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.signInWithGoogle(context);

    if (user != null) {
      final status = await _storage.read(key: 'user_status');

      if (status == 'registered') {
        // Redirige si el usuario es nuevo
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PerfilUpdate()),
        );
      } else {
        // Redirige si el usuario ya existe
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage()),
        );
      }
    }
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true; // Para controlar la visibilidad de la contraseña

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Text(
          "Iniciar Sessión",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),

          onPressed: () {
            exit(0);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? AppColors.blueBlak
                  : Colors.white,
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.89,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset("assets/logo.png", scale: 2.7),
                  ),

                  const SizedBox(height: 50.0),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ), // Icono a la izquierda
                      border: OutlineInputBorder(
                        // Borde para un aspecto más definido
                        borderRadius: BorderRadius.circular(
                          10.0,
                        ), // Bordes redondeados
                      ),
                      labelText: "Email",
                      hintText: 'ejemplo@correo.com',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El email no puede estar vacío';
                      }

                      final email = value.trim().toLowerCase();
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
                      );

                      if (!emailRegex.hasMatch(email)) {
                        return 'Formato de correo inválido';
                      }

                      return null;
                    },

                    keyboardType:
                        TextInputType
                            .emailAddress, // Sugiere el teclado de correo
                  ),
                  const SizedBox(height: 20.0),

                  TextFormField(
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresá tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'Debe tener al menos 6 caracteres';
                      }
                      return null;
                    },

                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ), // Icono a la izquierda
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      suffixIcon: IconButton(
                        // Widget a la derecha (para el icono del ojo)
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText =
                                !_obscureText; // Cambia el estado de la visibilidad
                          });
                        },
                      ),
                    ),
                    obscureText:
                        _obscureText, // Controla si el texto está oculto
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenDark,
                          ),
                          onPressed: () async {
                            final email =
                                emailController.text.trim().toLowerCase();
                            final password = passwordController.text.trim();

                            if (email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('⚠️ Completá todos los campos'),
                                ),
                              );
                              return;
                            }

                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );

                            final result = await authProvider.loginUser(
                              email,
                              password,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ?? 'Error desconocido',
                                ),
                              ),
                            );

                            if (result['status'] == "success") {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyHomePage(),
                                ),
                              );
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Iniciar Sesión",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Iniciar session con Google
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Image.asset(
                            'assets/google_logo.png',
                            height: 24,
                          ), // Agrega el logo de Google
                          label: const Text("Iniciar sesión con Google"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.grey, // El color del borde
                                width: 1.0, // El grosor del borde
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 0,
                          ),
                          // _handleGoogleSignIn,
                          onPressed: _handleGoogleSignIn,

                          // () async {
                          //   UsuarioModel? user = await AuthService()
                          //       .signInWithGoogle(context);
                          //   if (user != null) {
                          //     // Mostrar mensaje de bienvenida
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBar(
                          //         content: Text("Bienvenido, ${user.name}!"),
                          //         duration: Duration(seconds: 2),
                          //       ),
                          //     );

                          //     // Ejecutar guardado y redirección desde ahí
                          //     await guardarUsuarioEnMySQL(context);
                          //   } else {
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBar(
                          //         content: Text(
                          //           "Error al iniciar sesión. Inténtalo de nuevo.",
                          //         ),
                          //         duration: Duration(seconds: 2),
                          //       ),
                          //     );
                          //   }
                          // },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text("¿No tienes cuenta? ↓"),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.green,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Registrate",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 70),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
