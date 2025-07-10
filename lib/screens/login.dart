import 'dart:io';

import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/usuario_model.dart';
import 'package:helfer/provider/auth_provider.dart';
import 'package:helfer/screens/home.dart';
import 'package:helfer/screens/register_user.dart';
import 'package:helfer/services/auth_service.dart';
import 'package:helfer/services/guardar_usuario.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true; // Para controlar la visibilidad de la contraseña

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blueDark),
          onPressed: () {
            exit(0);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.94,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset("assets/logo.png", scale: 4),
                ),
                Text(
                  "Iniciar Sessión",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30.0),
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Usuario",
                    prefixIcon: const Icon(
                      Icons.person_2_outlined,
                    ), // Icono a la izquierda
                    border: OutlineInputBorder(
                      // Borde para un aspecto más definido
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ), // Bordes redondeados
                    ),
                  ),
                  keyboardType:
                      TextInputType
                          .emailAddress, // Sugiere el teclado de correo
                ),
                const SizedBox(height: 20.0),

                TextFormField(
                  controller: passwordController,
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
                  obscureText: _obscureText, // Controla si el texto está oculto
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                        ),
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          final result = await authProvider.loginUser(
                            usernameController.text,
                            passwordController.text,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result?['message'] ?? 'Error desconocido',
                              ),
                            ),
                          );

                          if (result?['status'] == "success") {
                            // Redirigir a la pantalla principal
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyHomePage(),
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
                        onPressed: () async {
                          UsuarioModel? user = await AuthService()
                              .signInWithGoogle(context);
                          if (user != null) {
                            // Guardar usuario en la base de datos MySQL
                            await guardarUsuarioEnMySQL();

                            // Mostrar mensaje de bienvenida
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Bienvenido, ${user.name}!"),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            // Redirigir a MyHomePage después del mensaje
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyHomePage(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Error al iniciar sesión. Inténtalo de nuevo.",
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
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
                          backgroundColor: AppColors.blueDark,
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

                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: Colors.grey, // Color de la línea
                        thickness: 1, // Grosor de la línea
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "O puedes ↓ ",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.blue[900]!,
                              width: 2,
                            ), // Define el color y el ancho del borde
                            borderRadius: BorderRadius.circular(
                              20,
                            ), // Opcional: para bordes redondeados
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyHomePage(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Seguir sin logear",
                            style: TextStyle(color: Colors.blue[900]),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
