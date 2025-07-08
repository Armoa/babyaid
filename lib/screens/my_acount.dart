import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/provider/auth_provider.dart' as local_auth_provider;
import 'package:helfer/provider/auth_provider.dart';
import 'package:helfer/screens/address_screen.dart';
import 'package:helfer/screens/my_orders.dart';
import 'package:helfer/screens/notification_screen.dart';
import 'package:helfer/screens/perfil_screen.dart';
import 'package:helfer/services/logout_user.dart';
import 'package:helfer/services/obtener_usuario.dart';
import 'package:helfer/widget/appbar.dart';
import 'package:helfer/widget/drawer.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class MyAcount extends StatefulWidget {
  const MyAcount({super.key});

  @override
  State<MyAcount> createState() => _MyAcountState();
}

class _MyAcountState extends State<MyAcount> {
  String? photoUrl;
  String? nombre;
  int? _idUser;

  late AuthProvider authProvider;

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
      nombre = datosPerfil?.name;
      photoUrl = datosPerfil?.photo;
      _idUser = datosPerfil?.id;
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

    print("Nombre : $nombre");
    print("Foto : $photoUrl");

    return Scaffold(
      backgroundColor: AppColors.blueLight,
      appBar: const NewAppBar(),
      drawer: const NewDrawer(),
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
                        border: Border.all(
                          color: const Color.fromARGB(255, 253, 226, 229),
                          width: 2,
                        ),
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
                              fontSize: 20,
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
                _widgetBloque2(context, _idUser),
                const SizedBox(height: 20),
                _widgetBloque3(context),

                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueAcua,
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
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
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

// Bloque 2
Widget _widgetBloque2(BuildContext context, dynamic idUser) {
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
              leading: const Icon(Icons.payment_sharp),
              title: const Text('Métodos de Pago'),
              onTap: () {},
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.list_rounded),
              title: const Text('Mis Pedidos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyOrders(userId: idUser),
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
          ],
        ),
      ],
    ),
  );
}
