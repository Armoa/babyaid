import 'package:bebito/model/colors.dart';
import 'package:bebito/provider/auth_provider.dart' as local_auth_provider;
import 'package:bebito/provider/auth_provider.dart';
import 'package:bebito/screens/address_screen.dart';
import 'package:bebito/screens/notification_screen.dart';
import 'package:bebito/screens/perfil_screen.dart';
import 'package:bebito/screens/ranking_personal.dart';
import 'package:bebito/services/logout_user.dart';
import 'package:bebito/services/obtener_usuario.dart';
import 'package:bebito/widget/title_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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
      appBar: AppBar(toolbarHeight: 100, title: TitleAppbar()),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Mi Cuenta",
                      style: GoogleFonts.quicksand(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
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
                          backgroundColor: AppColors.green,
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
                          backgroundColor: AppColors.greenDark,
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
              leading: const Icon(Iconsax.profile_circle_copy),
              title: const Text('Mi Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              trailing: const Icon(Iconsax.arrow_right_1_copy),
            ),
            ListTile(
              leading: const Icon(Iconsax.location_copy),
              title: const Text('Direcciones'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressScreen(),
                  ),
                );
              },
              trailing: const Icon(Iconsax.arrow_right_1_copy),
            ),
            ListTile(
              leading: const Icon(Iconsax.stickynote_copy),
              title: const Text('Mis Facturas'),
              onTap: () {},
              trailing: const Icon(Iconsax.arrow_right_1_copy),
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
              leading: const Icon(Iconsax.notification_bing_copy),
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
              trailing: const Icon(Iconsax.arrow_right_1_copy),
            ),

            ListTile(
              leading: const Icon(Iconsax.star_copy),
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
              trailing: const Icon(Iconsax.arrow_right_1_copy),
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
              leading: const Icon(Iconsax.message_question_copy),
              title: const Text(
                'Preguntas frecuentes',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {},
              trailing: const Icon(Iconsax.arrow_right_1_copy),
            ),
            ListTile(
              leading: const Icon(Iconsax.verify_copy),
              title: const Text(
                'Política de calidad',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {},
              trailing: const Icon(Iconsax.arrow_right_1_copy),
            ),
            ListTile(
              leading: const Icon(Iconsax.security_copy),
              title: const Text(
                'Política de privacidad',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {},
              trailing: const Icon(Iconsax.arrow_right_1_copy),
            ),
            ListTile(
              leading: const Icon(Iconsax.info_circle_copy),
              title: const Text(
                'Términos y condiciones',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {},
              trailing: const Icon(Iconsax.arrow_right_1_copy),
            ),
          ],
        ),
      ],
    ),
  );
}
