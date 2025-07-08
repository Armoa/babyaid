import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/screens/cart.dart';

class NewFloatingActionButton extends StatelessWidget {
  const NewFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartScreenView()),
        );
      },
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? AppColors.blueLight
              : AppColors.blueDark,
      shape: const CircleBorder(), // Color de fondo del botón
      child: Icon(
        Icons.shopping_cart_outlined,
        color:
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.blueDark
                : AppColors.blueLight,
      ), // Icono de carrito
    );
  }
}
