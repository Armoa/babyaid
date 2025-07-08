import 'dart:io';

import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/servicios.dart';
import 'package:helfer/provider/auth_provider.dart' as local_auth_provider;
import 'package:helfer/screens/detalles_servicios.dart';
import 'package:helfer/screens/my_acount.dart';
import 'package:helfer/screens/my_cupon.dart';
import 'package:helfer/screens/notification_screen.dart';
import 'package:helfer/screens/selector_ubicacion.dart';
import 'package:helfer/screens/show_promo_banner.dart';
import 'package:helfer/services/fetch_active_banner.dart';
import 'package:helfer/services/verificar_perfil_usuario.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Estado del Menu
enum Seccion { home, tareas, cartera, perfil }

class _MyHomePageState extends State<MyHomePage> {
  late final int initialLoopIndex;

  // Estado y funcion de la navegacion del menu
  Seccion _seccionActual = Seccion.home;
  void _navegarA(Seccion seccion) {
    setState(() => _seccionActual = seccion);
  }

  late final PageController _controller;

  late final List<Servicio> serviciosLoop = List.generate(
    repeticiones,
    (index) => servicios[index % servicios.length],
  );

  final int repeticiones = 1000;

  final List<Servicio> servicios = [
    Servicio(
      nombre: 'Limplieza del Hogar',
      imagen: 'assets/service-home.png',
      id: 1,
    ),
    Servicio(
      nombre: 'Cuidado de Niños/as',
      imagen: 'assets/service-kids.png',
      id: 2,
    ),
    Servicio(
      nombre: 'Limpieza de Tapizado',
      imagen: 'assets/service-plus.png',
      id: 3,
    ),
    Servicio(
      nombre: 'Cuidado de personas mayores',
      imagen: 'assets/service-care.png',
      id: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final int initialLoopIndex = (repeticiones / 2).floor();
    _controller = PageController(
      initialPage: initialLoopIndex,
      viewportFraction: 0.45, // 👈 Esto permite ver los ítems laterales
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {}); // 🔁 Fuerza actualización después del build inicial
    });
    // Verifica si hay un banner activo al iniciar
    _checkForPromoBanner();
    // Vefifica y el usuario completo su perfil
    verificarPerfilUsuario(context);
  }

  // POPUP BANNER
  void _checkForPromoBanner() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Solo restablecer si la app se ha reiniciado completamente
    bool bannerShown = prefs.getBool('bannerShown') ?? false;

    if (!bannerShown) {
      await Future.delayed(const Duration(seconds: 10));

      String? imagen = await fetchActiveBanner();
      if (imagen != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showPromoBanner(context);
          prefs.setBool(
            'bannerShown',
            true,
          ); // Guarda que el banner ha sido mostrado
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<local_auth_provider.AuthProvider>(
      context,
      listen: false,
    );
    final nombre = authProvider.user?.name ?? 'Usuario';
    return Scaffold(
      backgroundColor: AppColors.blueDark,
      appBar: AppBar(
        leading: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                exit(0);
              },
            ),
          ],
        ),
        title: Column(
          children: [
            Text(
              "!Hola $nombre!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text("¿Cómo podemos ayudare?", style: TextStyle(fontSize: 16)),
          ],
        ),
        toolbarHeight: 180,
      ),
      body: IndexedStack(
        index: Seccion.values.indexOf(_seccionActual),
        children: [
          HomeMain(
            controller: _controller,
            serviciosLoop: serviciosLoop,
            servicios: servicios,
          ),
          NotificationScreen(),
          CuponesScreen(),
          MyAcount(),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white),

        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color.fromARGB(255, 223, 223, 223),
            type: BottomNavigationBarType.fixed,
            currentIndex: Seccion.values.indexOf(_seccionActual),
            onTap: (index) => _navegarA(Seccion.values[index]),
            selectedItemColor: AppColors.blueSky, // Color activo
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: '●',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.checklist_outlined),
                activeIcon: Icon(Icons.checklist), // Podés usar otro si querés
                label: '●',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined),
                activeIcon: Icon(Icons.account_balance_wallet),
                label: '●',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: '●',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeMain extends StatelessWidget {
  const HomeMain({
    super.key,
    required this.controller,
    required this.serviciosLoop,
    required this.servicios,
  });

  final PageController controller;
  final List<Servicio> serviciosLoop;
  final List<Servicio> servicios;

  @override
  Widget build(BuildContext context) {
    final Map<int, WidgetBuilder> rutasServicios = {
      1: (_) => SelectorUbicacion(),
      2: (_) => SelectorUbicacion(),
      3: (_) => SelectorUbicacion(),
      4: (_) => SelectorUbicacion(),
    };
    return Container(
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
      child: PageView.builder(
        controller: controller,
        itemCount: serviciosLoop.length,
        itemBuilder: (context, index) {
          final servicio = serviciosLoop[index];

          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              double value = 1.0;
              if (controller.position.haveDimensions) {
                value =
                    ((controller.page ?? controller.initialPage).toDouble()) -
                    index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }

              return Center(
                child: GestureDetector(
                  onTap: () {
                    final servicioBase = servicios[index % servicios.length];
                    final builder = rutasServicios[servicioBase.id];

                    if (builder != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: builder),
                      );
                    } else {
                      // Fallback si no se encuentra
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => DetalleServicio(
                                id: servicioBase.id,
                                nombre: servicioBase.nombre,
                              ),
                        ),
                      );
                    }
                  },
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value.clamp(0.5, 1.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(servicio.imagen),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (value > 0.95)
                              SizedBox(
                                width: 160,
                                height: 100,
                                child: Text(
                                  servicio.nombre,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
