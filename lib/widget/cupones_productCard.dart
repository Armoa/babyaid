import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helfer/model/card_model.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/cupon_model.dart';
import 'package:helfer/provider/auth_provider.dart';
import 'package:helfer/provider/cart_provider.dart';
import 'package:helfer/screens/login.dart';
import 'package:helfer/screens/product_detail.dart';
import 'package:helfer/services/functions.dart';
import 'package:helfer/services/get_cupones.dart';
import 'package:helfer/widget/boton_agregar_wishList.dart';
import 'package:provider/provider.dart';

class CuponProductCard extends StatefulWidget {
  const CuponProductCard({super.key});

  @override
  State<CuponProductCard> createState() => _CuponProductCardState();
}

class _CuponProductCardState extends State<CuponProductCard> {
  @override
  Widget build(BuildContext context) {
    int selectedQuantity = 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      height: 240.0,
      child: FutureBuilder<List<ProductoConCupon>>(
        future: fetchProductosConCupon(),
        builder: (context, featured) {
          if (featured.hasData) {
            if (featured.data!.isEmpty) {
              return const Center(child: Text("0 Productos Destacados"));
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: featured.data?.length,
              itemBuilder: (context, i) {
                final productoConCupon = featured.data![i];
                final product = productoConCupon.producto;
                final cupon = productoConCupon.cupon;
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ProductDetail(data: product, cupon: cupon),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 150, // Ancho fijo para cada tarjeta
                        height: 190,
                        margin: const EdgeInsets.fromLTRB(4, 4, 14, 0),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(
                                (0.1 * 255).toInt(),
                                60,
                                60,
                                60,
                              ),
                              spreadRadius: 3, // Extensión de la sombra
                              blurRadius: 4, // Desenfoque
                              offset: Offset(0, 0), // Posición (x, y)
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: <Widget>[
                                  AspectRatio(
                                    aspectRatio:
                                        10 / 10, // Proporción para la imagen
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                          child: Image.network(
                                            product.image,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return const Center(
                                                child: Text(
                                                  'Error al cargar la imagen',
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // if (cupon != null)
                                  Positioned(
                                    top: 8,
                                    left: 0,
                                    child: SizedBox(
                                      width: 60,
                                      child: Image.asset('assets/cupon.png'),
                                    ),
                                  ),

                                  Positioned(
                                    top: 8.0,
                                    right: 8.0,
                                    child: BotonAgregarWishList(
                                      product: product,
                                    ),
                                  ),

                                  // PRECIOS
                                  if (product.onSale == 1)
                                    Positioned(
                                      bottom: 30,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          0,
                                          0,
                                        ),
                                        child: Text(
                                          '₲${numberFormat(product.price)}',
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Theme.of(context).hintColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Mostrar precio final (ya sea de oferta o regular)
                                  Positioned(
                                    bottom: 8,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        0,
                                        0,
                                      ),
                                      child: Text(
                                        '₲${numberFormat(product.onSale == 1 ? product.priceSale : product.price)}',
                                        style: TextStyle(
                                          color:
                                              product.onSale == 1
                                                  ? Colors.pink
                                                  : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.shopping_cart_outlined,
                                      ),
                                      onPressed: () {
                                        final authProvider =
                                            Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            );

                                        if (!authProvider.isAuthenticated) {
                                          // Si el usuario no está logeado, redirigirlo a LoginScreen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const LoginScreen(),
                                            ),
                                          );
                                          return; // Detiene la ejecución
                                        }

                                        final cartItem = CartItem(
                                          id: product.id,
                                          name: product.name,
                                          price: double.parse(product.price),
                                          image: product.image,
                                          quantity: 1,
                                        );
                                        Provider.of<CartProvider>(
                                          context,
                                          listen: false,
                                        ).addToCart(cartItem, selectedQuantity);

                                        // Mostrar el SnackBar después de agregar el producto
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "${product.name} añadido al carrito",
                                            ),
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 138,
                        child: Text(
                          product.name.toUpperCase() +
                              product.name.substring(1).toLowerCase(),
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (featured.hasError) {
            return Center(child: Text(featured.error.toString()));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
