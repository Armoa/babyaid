import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/provider/auth_provider.dart';
import 'package:helfer/screens/perfil_update.dart';
import 'package:helfer/services/obtener_usuario.dart';
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
  String? _nombreUsuarioPerfil;
  String? _apellidoPerfil;
  String? _emailPerfil;
  String? _telefonoPerfil;
  String? _direccionPerfil;
  String? _ciudadPerfil;
  String? _barrioPerfil;
  String? _imagenPerfilUrl;
  String? _razonPerfil;
  String? _rucPerfil;

  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales del perfil
    _cargarDatosPerfil();
  }

  Future<void> _cargarDatosPerfil() async {
    final datosPerfil = await obtenerUsuarioDesdeMySQL();
    // Rellenar los controladores con los datos obtenidos
    setState(() {
      _nombreUsuarioPerfil = datosPerfil?.name;
      _imagenPerfilUrl = datosPerfil?.photo;
      _apellidoPerfil = datosPerfil?.lastName;
      _emailPerfil = datosPerfil?.email;
      _direccionPerfil = datosPerfil?.address;
      _telefonoPerfil = datosPerfil?.phone;
      _ciudadPerfil = datosPerfil?.city;
      _barrioPerfil = datosPerfil?.barrio;
      _razonPerfil = datosPerfil?.razonsocial;
      _rucPerfil = datosPerfil?.ruc;
    });
  }

  Future<void> seleccionarYSubirImagen(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagenSeleccionada = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (imagenSeleccionada != null) {
      final usuarioEmail =
          Provider.of<AuthProvider>(context, listen: false).email;
      // print("Usuario email en seleccionarYSubirImagen: $usuarioEmail");

      if (usuarioEmail != null) {
        try {
          bool actualizado = await PerfilService().cargarImagenPerfil(
            usuarioEmail,
            imagenSeleccionada,
          );

          if (actualizado) {
            await _cargarDatosPerfil(); // Recargar datos del perfil

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Imagen de perfil actualizada exitosamente'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al actualizar la imagen.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar la imagen: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario no disponible. Inicia sesión nuevamente.'),
          ),
        );
      }
    } else {
      // print('No se seleccionó ninguna imagen.');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            backgroundImage:
                                _imagenPerfilUrl != null
                                    ? NetworkImage(_imagenPerfilUrl!)
                                    : null,
                            child:
                                _imagenPerfilUrl == null
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
                  _nombreUsuarioPerfil != null
                      ? cardPerfil(
                        subTitle,
                        "Nombre del usuario",
                        _nombreUsuarioPerfil,
                        Icons.lock,
                      )
                      : const ShimmerWidget(),
                  const SizedBox(height: 10),

                  // NOMBRE Y APELLIDO
                  _nombreUsuarioPerfil != null
                      ? Card(
                        elevation: 0,
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text(
                            "Apellido",
                            style: TextStyle(fontSize: 12),
                          ),
                          subtitle: Text(
                            _apellidoPerfil.toString(),
                            style: subTitle,
                          ),
                        ),
                      )
                      : const ShimmerWidget(),
                  const SizedBox(height: 10),

                  // EMAIL
                  _nombreUsuarioPerfil != null
                      ? cardPerfil(
                        subTitle,
                        "Correo",
                        _emailPerfil,
                        Icons.email,
                      )
                      : const ShimmerWidget(),

                  const SizedBox(height: 10),

                  // TELEFONO
                  _nombreUsuarioPerfil != null
                      ? cardPerfil(
                        subTitle,
                        "Numero de celular",
                        _telefonoPerfil,
                        Icons.phone_android,
                      )
                      : const ShimmerWidget(),

                  const SizedBox(height: 10),
                  // DIRECCION
                  _nombreUsuarioPerfil != null
                      ? cardPerfil(
                        subTitle,
                        "Dirección",
                        _direccionPerfil,
                        Icons.place,
                      )
                      : const ShimmerWidget(),

                  const SizedBox(height: 10),
                  // CIUDAD
                  _nombreUsuarioPerfil != null
                      ? cardPerfil(
                        subTitle,
                        "Ciudada",
                        _ciudadPerfil,
                        Icons.location_city,
                      )
                      : const ShimmerWidget(),
                  const SizedBox(height: 10),
                  // Barrio
                  _nombreUsuarioPerfil != null
                      ? cardPerfil(subTitle, "Barrio", _barrioPerfil, Icons.map)
                      : const ShimmerWidget(),
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
                  _nombreUsuarioPerfil != null
                      ? cardPerfil(
                        subTitle,
                        "Nombre o Rozón Social",
                        _razonPerfil,
                        Icons.info,
                      )
                      : const ShimmerWidget(),
                  const SizedBox(height: 10),

                  // RUC
                  _nombreUsuarioPerfil != null
                      ? Card(
                        elevation: 0,
                        child: ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text(
                            "C.I. / R.U.C.",
                            style: TextStyle(fontSize: 12),
                          ),
                          subtitle: Text(
                            '${_rucPerfil.toString()} ',
                            style: subTitle,
                          ),
                        ),
                      )
                      : const ShimmerWidget(),
                  const SizedBox(height: 10),

                  // BOTON  ACTUALAR DATOS DE PERFIL
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
