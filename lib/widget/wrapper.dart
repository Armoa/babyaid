import 'package:bebito/provider/auth_provider.dart';
import 'package:bebito/screens/home_screen.dart';
import 'package:bebito/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios en AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    // Imprime el estado actual para depuración
    print('DEBUG Wrapper: isLogged = ${authProvider.isLogged}');
    print('DEBUG Wrapper: user = ${authProvider.user?.email ?? 'null'}');

    // Basado en el estado de isLogged, decide qué pantalla mostrar
    if (authProvider.isLogged) {
      return const HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}
