import 'package:bebito/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Pantalla principal de onboarding
class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  // 1. Declarar y inicializar el PageController
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Lista de datos para las pantallas
  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/image1.png',
      'title': 'Bienvenido a Bebito',
      'description': 'La App que te ayuda a cuidar y mantener feliz a tu bebe',
    },
    {
      'image': 'assets/image2.png',
      'title': 'Pañal Control',
      'description': 'Te avisamos cuando cuando hacer pedios de pañal.',
    },
    {
      'image': 'assets/image3.png',
      'title': 'Eventos, Shop y más',
      'description': 'Ofertas y promociones especiales para tu bebe.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 4. Implementar la navegación a la pantalla de inicio
  void _navigateToHome() {
    // Aquí defines la navegación a la siguiente pantalla
    // Por ejemplo:
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
    );
    // En este ejemplo, simplemente salimos del onboarding.
    print('Navegando a la pantalla de inicio');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, // Equivale a 360deg
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 215, 250, 246),
              Color.fromARGB(255, 253, 255, 229),
              Color(0xFFECFEFE),
            ],
          ),
        ),
        child: Stack(
          children: [
            // PageView para las pantallas de onboarding
            PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final data = onboardingData[index];
                return OnboardingPage(
                  image: data['image']!,
                  title: data['title']!,
                  description: data['description']!,
                );
              },
            ),

            // Botón "Saltar" en la esquina superior derecha
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 20,
              child: TextButton(
                onPressed: _navigateToHome,
                child: Text(
                  'Skip',
                  style: GoogleFonts.nunito(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              child: TextButton(
                onPressed: _navigateToHome,
                child: Image.asset('assets/logo.png', scale: 7),
              ),
            ),

            // Indicador de progreso y botón de siguiente
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicador de puntos (SmoothPageIndicator)
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: onboardingData.length,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: Colors.black,
                      dotColor: Colors.grey,
                      dotWidth: 10,
                      dotHeight: 10,
                    ),
                  ),
                  // Botón de siguiente o finalizar
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.black87, width: 2.0),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: FloatingActionButton(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      onPressed: () {
                        if (_currentPage < onboardingData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        } else {
                          _navigateToHome();
                        }
                      },
                      child: Icon(
                        _currentPage < onboardingData.length - 1
                            ? Icons.arrow_forward
                            : Icons.check,
                        size: 34,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de cada página de onboarding
class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 450),
        const SizedBox(height: 20),
        Text(
          title,
          style: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            description,
            style: GoogleFonts.nunito(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
