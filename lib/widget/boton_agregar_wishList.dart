// BOTON AGREGAR LISTA DE DESEOS
import 'package:flutter/material.dart';
import 'package:helfer/provider/auth_provider.dart';
import 'package:helfer/provider/wishlist_provider.dart';
import 'package:helfer/screens/login.dart';
import 'package:helfer/services/wishlist_service.dart';
import 'package:provider/provider.dart';

class BotonAgregarWishList extends StatelessWidget {
  const BotonAgregarWishList({super.key, required this.product});
  final dynamic product;

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        return InkWell(
          onTap: () {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            print('AUTH : ${authProvider.isAuthenticated}');
            if (!authProvider.isAuthenticated) {
              // Si el usuario no está logeado, redirigirlo a LoginScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
              return; // Detiene la ejecución
            }

            final alreadyInWishlist = wishlistProvider.wishlist.any(
              (item) => item.id == product.id.toString(),
            );

            if (alreadyInWishlist) {
              // Eliminar si ya está en la lista
              wishlistProvider.removeFromWishlist(
                product.id.toString(),
                authProvider.userId!.toString(),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('El producto se eliminó de la lista de deseos'),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              // Agregar si no está en la lista
              final cleanedProduct = {
                'id': product.id.toString(),
                'name': product.name,
                // 'image': product.containsKey('images') && product.image.isNotEmpty
                'image':
                    product.image.isNotEmpty
                        ? product.image
                        : 'https://farma.staweno.com/sw-admin/uploads/placeholder.png', // Imagen predeterminada
                'price':
                    double.tryParse(product.price?.toString() ?? '0') ?? 0.0,
              };

              final wishlistItem = WishlistItem.fromJson(cleanedProduct);

              print(' MI USER ID:  ${authProvider.userId}');

              wishlistProvider.addItemToWishlist(
                wishlistItem,
                authProvider.userId.toString(),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${wishlistItem.name} se añadió a la lista de deseos',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Icon(
            wishlistProvider.wishlist.any(
                  (item) => item.id == product.id.toString(),
                )
                ? Icons
                    .favorite // Cambia a "favorite" si ya está en la lista
                : Icons
                    .favorite_border, // Cambia a "favorite_border" si no está en la lista
            color: const Color.fromARGB(255, 203, 53, 56),
          ),
        );
      },
    );
  }
}
