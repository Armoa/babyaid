import 'package:bebito/model/colors.dart';
import 'package:bebito/model/usuario_model.dart';
import 'package:bebito/provider/auth_provider.dart';
import 'package:bebito/screens/perfil_update.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../services/perfil_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosPerfilDesdeAuthProvider();
    });
  }

  Future<void> _cargarDatosPerfilDesdeAuthProvider() async {
    await Provider.of<AuthProvider>(context, listen: false).loadUser();
  }

  Future<void> seleccionarYSubirImagen(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagenSeleccionada = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (imagenSeleccionada != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final usuarioEmail =
          authProvider.email; // Obtén el email del AuthProvider

      if (usuarioEmail != null) {
        try {
          bool actualizado = await PerfilService().cargarImagenPerfil(
            usuarioEmail,
            imagenSeleccionada,
          );

          if (actualizado) {
            await authProvider
                .loadUser(); // <--- IMPORTANTE: Recarga el usuario en el AuthProvider
            if (context.mounted) {
              // Verificar si el contexto sigue válido
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Imagen de perfil actualizada exitosamente'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error al actualizar la imagen.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al actualizar la imagen: $e')),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario no disponible. Inicia sesión nuevamente.'),
            ),
          );
        }
      }
    } else {
      // print('No se seleccionó ninguna imagen.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtén la instancia del AuthProvider para acceder a los datos del usuario
    final authProvider = Provider.of<AuthProvider>(context);
    final UsuarioModel? user = authProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mi perfil")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Ahora usa los datos directamente del objeto 'user'
    var subTitle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    return Scaffold(
      backgroundColor: AppColors.green,
      appBar: AppBar(title: const Text("Mi perfil")),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(70),
                          border: Border.all(
                            color: const Color.fromARGB(255, 245, 216, 41),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(user.photo),
                            child:
                                // ignore: unnecessary_null_comparison
                                user.photo == null
                                    ? Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.grey[300],
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            AppColors.green,
                          ),
                          foregroundColor: WidgetStateProperty.all<Color>(
                            Colors.white,
                          ),
                        ),
                        onPressed: () => seleccionarYSubirImagen(context),
                        child: const Text(
                          'Actualizar foto',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                    child: Text(
                      "Datos Personales",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // NOMBRE DEL USUARIO
                  // Ya no necesitas la comprobación _nombreUsuarioPerfil != null
                  // Usas directamente user.name
                  cardPerfil(
                    subTitle,
                    "Nombre del usuario",
                    user.name, // <-- Usa user.name
                    Icons.lock,
                  ),
                  const SizedBox(height: 10),

                  // APELLIDO
                  Card(
                    elevation: 0,
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text(
                        "Apellido",
                        style: TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        user.lastName, // <-- Usa user.lastName
                        style: subTitle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // EMAIL
                  cardPerfil(
                    subTitle,
                    "Correo",
                    user.email, // <-- Usa user.email
                    Icons.email,
                  ),
                  const SizedBox(height: 10),

                  // TELEFONO
                  cardPerfil(
                    subTitle,
                    "Numero de celular",
                    user.phone, // <-- Usa user.phone
                    Icons.phone_android,
                  ),
                  const SizedBox(height: 10),
                  // DIRECCION
                  cardPerfil(
                    subTitle,
                    "Dirección",
                    user.address, // <-- Usa user.address
                    Icons.place,
                  ),
                  const SizedBox(height: 10),
                  // CIUDAD
                  cardPerfil(
                    subTitle,
                    "Ciudad", // Corregí el typo "Ciudada" a "Ciudad"
                    user.city, // <-- Usa user.city
                    Icons.location_city,
                  ),
                  const SizedBox(height: 10),
                  // Barrio
                  cardPerfil(
                    subTitle,
                    "Barrio",
                    user.barrio, // <-- Usa user.barrio
                    Icons.map,
                  ),
                  const SizedBox(height: 30),
                  // DATOS DE FACTURACION
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                    child: Text(
                      "Datos de facturación",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // RAZON SOCIAL
                  const SizedBox(height: 10),
                  cardPerfil(
                    subTitle,
                    "Nombre o Razón Social", // Corregí el typo "Rozón" a "Razón"
                    user.razonsocial, // <-- Usa user.razonsocial
                    Icons.info,
                  ),
                  const SizedBox(height: 10),

                  // RUC
                  Card(
                    elevation: 0,
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text(
                        "C.I. / R.U.C.",
                        style: TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        user.ruc, // <-- Usa user.ruc
                        style: subTitle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // BOTON ACTUALAR DATOS DE PERFIL
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PerfilUpdate(),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Actualizar datos',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Card cardPerfil(
    TextStyle subTitle,
    String titulo,
    String? nombre,
    IconData icono,
  ) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: Icon(icono),
        title: Text(titulo, style: const TextStyle(fontSize: 12)),
        subtitle: Text(nombre ?? '', style: subTitle),
      ),
    );
  }
}

class ShimmerWidget extends StatelessWidget {
  const ShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 0,
        child: ListTile(
          leading: Container(width: 24, height: 24, color: Colors.grey[300]),
          title: Container(width: 100, height: 12, color: Colors.grey[300]),
          subtitle: Container(width: 150, height: 12, color: Colors.grey[300]),
        ),
      ),
    );
  }
}
