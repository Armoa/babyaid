import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/provider/auth_provider.dart' as local_auth_provider;
import 'package:helfer/provider/auth_provider.dart';
import 'package:helfer/screens/address_screen.dart';
import 'package:helfer/screens/home.dart';
import 'package:helfer/screens/list_personal_calificacion.dart';
import 'package:helfer/screens/notification_screen.dart';
import 'package:helfer/screens/perfil_screen.dart';
import 'package:helfer/services/logout_user.dart';
import 'package:helfer/services/obtener_usuario.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAcount extends StatefulWidget {
  const MyAcount({super.key});

  @override
  State<MyAcount> createState() => _MyAcountState();
}

class _MyAcountState extends State<MyAcount> {
  String? photoUrl;
  String? nombre;
  // int? _idUser;

  String appVersion = "Cargando...";

  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _cargarDatosPerfil();
  }

  // Funcion mostrar version del la App
  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  Future<void> _cargarDatosPerfil() async {
    final datosPerfil = await obtenerUsuarioDesdeMySQL();

    // Rellenar los controladores con los datos obtenidos
    setState(() {
      nombre = datosPerfil?.name;
      photoUrl = datosPerfil?.photo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<local_auth_provider.AuthProvider>(
      context,
      listen: false,
    );

    final nombre = authProvider.user?.name ?? 'Usuario';
    final photoUrl =
        (authProvider.user?.photo != null &&
                authProvider.user!.photo.isNotEmpty)
            ? authProvider.user!.photo
            : 'https://cdn-icons-png.flaticon.com/512/64/64572.png';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Icon(Icons.arrow_back),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: Image.asset('assets/logo-blanco.png', scale: 2.5),
                ),
              ],
            ),
            SizedBox(height: 25),
            Text(
              "Mi cuenta",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 25),
          ],
        ),
      ),

      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: AppColors.white,
        ),
        child: SingleChildScrollView(
          // Por si el contenido es más largo que la pantalla
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch, // Para que los bloques se estiren horizontalmente
              children: <Widget>[
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(52.0),
                        border: Border.all(color: AppColors.blueSky, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(photoUrl),
                          child:
                              authProvider.user == null
                                  ? Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.grey[300],
                                    ),
                                  )
                                  : CircleAvatar(
                                    radius: 40,
                                    backgroundImage: NetworkImage(photoUrl),
                                  ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Hola, ", style: TextStyle(fontSize: 14)),
                        SizedBox(
                          child: Text(
                            nombre,
                            style: const TextStyle(
                              fontSize: 19,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _widgetBloque1(context),
                const SizedBox(height: 20),
                _widgetBloque2(context),
                const SizedBox(height: 20),
                _widgetBloque3(context),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueDark,
                        ),
                        onPressed: () async {
                          await logoutUser(context);
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 24,
                        ), // Aquí defines el icono que quieres mostrar
                        label: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Cerrar sesión",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueSky,
                        ),
                        onPressed: () async {
                          final uri = Uri.parse(
                            "https://helfer.flatzi.com/delete_request.html",
                          );
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("No se pudo abrir el enlace"),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 24,
                        ), // Aquí defines el icono que quieres mostrar
                        label: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Eliminar cuenta ",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Text(
                      "Versión $appVersion",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
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

// Bloque 1
Widget _widgetBloque1(context) {
  return Card(
    elevation: 0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mi Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.place),
              title: const Text('Direcciones'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressScreen(),
                  ),
                );
              },
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Mis Facturas'),
              onTap: () {},
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
          ],
        ),
      ],
    ),
  );
}

// Bloque 3
Widget _widgetBloque2(BuildContext context) {
  return Card(
    elevation: 0,
    child: Column(
      children: [
        ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text(
                'Alertas y notificaciones',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text(
                'Información del servicio',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {},
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.hotel_class_sharp),
              title: const Text(
                'Los mejores Helfer',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RankingPersonalScreen(),
                  ),
                );
              },
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
          ],
        ),
      ],
    ),
  );
}

// Bloque 3
Widget _widgetBloque3(BuildContext context) {
  return Card(
    elevation: 0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text(
                'Preguntas frecuentes',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {},
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.verified),
              title: const Text(
                'Política de calidad',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {},
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text(
                'Política de privacidad',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {},
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.error_outline_sharp),
              title: const Text(
                'Términos y condiciones',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {},
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
          ],
        ),
      ],
    ),
  );
}
