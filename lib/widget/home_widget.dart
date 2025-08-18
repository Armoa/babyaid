import 'package:bebito/model/colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            MyBalanceCard(balance: '1.00'),

            MyBalanceCard2(balance: '1.00'),

            Text(
              "2- Moth Old Baby",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            MyBalanceCard3(),
            SizedBox(height: 10),
            MyBalanceCard3(),
          ],
        ),
      ),
    );
  }
}

// Primera tarjeta
class MyBalanceCard extends StatelessWidget {
  final String balance;

  const MyBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 250, 250, 250),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(16), // Esquinas redondeadas
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("My Balance", style: TextStyle(fontSize: 16)),
                    Row(
                      children: [
                        const Icon(
                          Icons.star, // El ícono de estrella o moneda
                          color: Color(0xFFF5B900),
                          size: 24,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '\$$balance',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Icono de regalo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE6E0),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Color(0xFFE94E2C), // Color del borde
                      width: 2.0, // Ancho del borde (fino)
                    ),
                  ),

                  child: const Icon(
                    Iconsax.gift_copy,
                    size: 30,
                    color: Color(0xFFE94E2C),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: const Row(
                  children: [
                    SizedBox(width: 10),
                    Text(
                      'See Your Claimed Rewards',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_outlined,
                      color: Colors.black87,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Segunda tarjeta
class MyBalanceCard2 extends StatelessWidget {
  final String balance;

  const MyBalanceCard2({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ocupa todo el ancho disponible
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 250, 250, 250),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        // Cambiado a Column para que el botón esté debajo del texto
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Unloack Gs. 10 Reward",
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Scan 10 diaper, erar Gs. 10 Pampers Carch.",
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
          SizedBox(height: 100),
          // El botón ahora ocupa todo el ancho
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primario,
              ),
              onPressed: () {},
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.scan_copy, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Scan Now", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//Bloque 3
class MyBalanceCard3 extends StatelessWidget {
  const MyBalanceCard3({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 184, 220, 246),
                  Color.fromARGB(255, 234, 255, 255),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            height: 220,
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                Text(
                  "Feeding",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Positioned(
                  top: 5,
                  right: 0,
                  child: Image.asset("assets/mamadera.png", scale: 5.6),
                ),
                Positioned(
                  bottom: 0,
                  left: 6,
                  child: SizedBox(
                    width: 120,
                    height: 60,
                    child: Text("How much mil or formula does my dabay nned?"),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Color.fromARGB(255, 190, 190, 190),
                        width: 1.0,
                      ),
                    ),

                    child: const Icon(
                      Iconsax.arrow_right_1_copy,
                      size: 24,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 255, 181, 181),
                  Color.fromARGB(255, 255, 255, 255),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            height: 220,
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                Text(
                  "Sleep",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Positioned(
                  top: 5,
                  right: 0,
                  child: Image.asset("assets/sleep.png", scale: 4.6),
                ),
                Positioned(
                  bottom: 0,
                  left: 6,
                  child: SizedBox(
                    width: 120,
                    height: 60,
                    child: Text(
                      "When might my babe star sleeping longer durming?",
                    ),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Color.fromARGB(255, 190, 190, 190),
                        width: 1.0,
                      ),
                    ),

                    child: const Icon(
                      Iconsax.arrow_right_1_copy,
                      size: 24,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
