import 'package:bebito/widget/gradient_background.dart';
import 'package:bebito/widget/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Índice del ícono seleccionado

  final List<Widget> _pages = [
    // Aquí puedes poner las pantallas que se mostrarán al tocar cada ícono
    HomeWidget(),
    const Center(child: Text('Recompensas')),
    const Center(child: Text('Escanear')),
    const Center(child: Text('Bebé')),
    const Center(child: Text('Guía')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Grandiente
      body: GradientBackground(
        child: Stack(
          children: [
            // Contenido principal de la pantalla.
            Positioned.fill(
              top: 16,
              bottom: 0.0, // Espacio para la barra de navegación
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 50),
                  Expanded(
                    child: _pages[_selectedIndex],
                  ), // Muestra la página seleccionada
                ],
              ),
            ),

            // AppBar transparente
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset("assets/placeholder.jpg"),
                      ),
                    ),
                  ],
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hola!", style: TextStyle(fontSize: 12)),
                    Text(
                      "Edgardo Saul",
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ],
                ),
                centerTitle: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: IconButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                            side: const BorderSide(
                              color: Colors.white, // Color del borde
                              width: 1.0, // Ancho del borde
                            ),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromARGB(131, 255, 255, 255),
                        ),
                      ),
                      icon: const Icon(
                        Iconsax.notification_bing_copy,
                        color: Colors.black,
                        size: 28,
                      ),
                      onPressed: () {
                        // Lógica para el botón de búsqueda
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Barra de navegación flotante, ahora dentro del Stack
            Positioned(
              bottom: 50.0,
              left: 40.0,
              right: 40.0,
              child: Container(
                decoration: BoxDecoration(
                  // Usa un color semi-transparente si quieres que se vea algo del gradiente
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(50.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Iconsax.home_copy, 0),
                      _buildNavItem(Iconsax.gift_copy, 1),
                      _buildNavItem(Iconsax.scan_copy, 2),
                      _buildNavItem(Icons.child_care, 3),
                      _buildNavItem(Iconsax.book_saved_copy, 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir cada ítem de navegación (sin cambios)
  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.black : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.black45,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black45,
          size: 26,
        ),
      ),
    );
  }
}
