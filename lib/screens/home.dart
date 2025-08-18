import 'dart:io';

import 'package:bebito/model/colors.dart';
import 'package:bebito/model/servicios.dart';
import 'package:bebito/provider/auth_provider.dart' as local_auth_provider;
import 'package:bebito/provider/notificaciones_provider.dart';
import 'package:bebito/provider/personal_provider.dart';
import 'package:bebito/screens/care_screen.dart';
import 'package:bebito/screens/estado_cuenta.dart';
import 'package:bebito/screens/kids_screen.dart';
import 'package:bebito/screens/mis_servicios.dart';
import 'package:bebito/screens/my_acount.dart';
import 'package:bebito/screens/notification_screen.dart';
import 'package:bebito/screens/plus_screen.dart';
import 'package:bebito/screens/selector_ubicacion.dart';
import 'package:bebito/screens/show_promo_banner.dart';
import 'package:bebito/services/fetch_active_banner.dart';
import 'package:bebito/services/verificar_perfil_usuario.dart';
import 'package:bebito/widget/ventana_calificacion.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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
      viewportFraction: 0.45,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});

      final notificacionesProvider = Provider.of<NotificacionesProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<local_auth_provider.AuthProvider>(
        context,
        listen: false,
      );

      if (authProvider.user != null) {
        final int usuarioId = authProvider.user!.id;
        notificacionesProvider.obtenerNotificaciones(usuarioId);
      }

      final personalProvider = Provider.of<PersonalProvider>(
        context,
        listen: false,
      );

      final int? usuarioId = authProvider.user?.id;
      if (usuarioId != null) {
        await personalProvider.obtenerUltimoServicioFinalizado(usuarioId);
        print('Servicio pendiente: ${personalProvider.servicioPendiente}');
        if (personalProvider.servicioPendiente != null) {
          mostrarCalificacion(context);
        }
      }
      // Verifica si hay un banner activo al iniciar
      _checkForPromoBanner();
      // Vefifica y el usuario completo su perfil
      verificarPerfilUsuario(context);
    });
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
          prefs.setBool('bannerShown', true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: IndexedStack(
        index: Seccion.values.indexOf(_seccionActual),
        children: [
          HomeMainScreen(
            controller: _controller,
            serviciosLoop: serviciosLoop,
            servicios: servicios,
          ),
          const MisServicios(),
          const EstadoCuenta(),
          const MyAcount(),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: CurvedNavigationBar(
          index: Seccion.values.indexOf(_seccionActual),
          items: [
            CurvedNavigationBarItem(
              child: Icon(Iconsax.home_copy, color: Colors.white, size: 30),
            ),
            CurvedNavigationBarItem(
              child: Icon(
                Iconsax.task_square_copy,
                color: Colors.white,
                size: 30,
              ),
            ),
            CurvedNavigationBarItem(
              child: Icon(Iconsax.wallet_1_copy, color: Colors.white, size: 30),
            ),
            CurvedNavigationBarItem(
              // child: Icon(Icons.person, color: Colors.white, size: 30),
              child: Icon(
                Iconsax.profile_circle_copy,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
          color: AppColors.secundario,
          buttonBackgroundColor: AppColors.primario,
          backgroundColor: Colors.white,

          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
          onTap: (index) => _navegarA(Seccion.values[index]),
          letIndexChange: (index) => true,
        ),
      ),
    );
  }
}

class HomeMainScreen extends StatelessWidget {
  final PageController controller;
  final List<Servicio> serviciosLoop;
  final List<Servicio> servicios;

  const HomeMainScreen({
    required this.controller,
    required this.serviciosLoop,
    required this.servicios,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<local_auth_provider.AuthProvider>(
      context,
      listen: false,
    );
    final nombre = authProvider.user?.name ?? 'Usuario';

    return Scaffold(
      backgroundColor: AppColors.primario,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    exit(0);
                  },
                  icon: Icon(Iconsax.arrow_left_copy),
                ),

                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationScreen(),
                          ),
                        );
                      },
                      icon: Icon(Iconsax.notification_bing_copy),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Consumer<NotificacionesProvider>(
                        builder: (context, notificacionesProvider, child) {
                          return Visibility(
                            visible: notificacionesProvider.totalNoLeidas > 0,
                            child: Container(
                              padding: EdgeInsets.all(1),
                              alignment: Alignment.center,
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Text(
                                '${notificacionesProvider.totalNoLeidas}',
                                style: TextStyle(fontSize: 9),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              "!Hola $nombre!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("¿Cómo podemos ayudare?", style: TextStyle(fontSize: 16)),
            SizedBox(height: 30),
          ],
        ),
        toolbarHeight: 180,
      ),
      body: HomeMain(
        controller: controller,
        serviciosLoop: serviciosLoop,
        servicios: servicios,
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
      2: (_) => KidsScreen(),
      3: (_) => PlusScreen(),
      4: (_) => CareScreen(),
    };
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color:
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.secundario
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
