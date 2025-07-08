import 'package:flutter/material.dart';
import 'package:helfer/model/card_model.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/product_model.dart';
import 'package:helfer/provider/auth_provider.dart';
import 'package:helfer/provider/cart_provider.dart';
import 'package:helfer/provider/cupon_provider.dart';
import 'package:helfer/screens/login.dart';
import 'package:helfer/screens/product_detail.dart';
import 'package:helfer/services/fetch_product.dart';
import 'package:helfer/services/functions.dart';
import 'package:helfer/widget/boton_agregar_wishList.dart';
import 'package:helfer/widget/floating_action_button.dart';
import 'package:provider/provider.dart' show Provider;

class ListCategoria extends StatefulWidget {
  final int id;
  final String nombre;

  const ListCategoria(this.id, this.nombre, {super.key});

  @override
  State<ListCategoria> createState() => _ListCategoriaState();
}

class _ListCategoriaState extends State<ListCategoria> {
  bool _isLoading = false;
  List<dynamic> _products = [];

  int _currentPage = 1;
  bool _isLoadingMore = false;
  // Paginacion  Inicio
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    cargarProductos();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore) {
        cargarMasProductos();
      }
    });
  }

  Future<void> cargarMasProductos() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      List<Product> nuevosProductos = await fetchProductsPaginatorCategory(
        _currentPage + 1,
        widget.id.toString(),
      );

      if (nuevosProductos.isNotEmpty) {
        setState(() {
          _products.addAll(nuevosProductos);
          _currentPage++;
        });
      }
    } catch (error) {
      print("Error al cargar más productos: $error");
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> cargarProductos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _products = await fetchProductsPaginatorCategory(
        _currentPage,
        widget.id.toString(),
      );
    } catch (error) {
      print("Error al cargar los productos: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedQuantity = 1;
    return Scaffold(
      backgroundColor: AppColors.blueLight,
      appBar: AppBar(
        title: Text(
          widget.nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child:
              _products.isEmpty && !_isLoading
                  ? const Center(child: Text("No hay productos disponibles"))
                  : CustomScrollView(
                    controller:
                        _scrollController, // Vincula el controlador al scroll
                    slivers: [
                      SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 0,
                              crossAxisSpacing: 0,
                              childAspectRatio: 0.60,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          if (index < _products.length) {
                            final product = _products[index];

                            final cuponProvider = Provider.of<CuponProvider>(
                              context,
                            );
                            final tieneCupon = cuponProvider.productoTieneCupon(
                              product.id,
                            );
                            return Padding(
                              padding: const EdgeInsets.all(5),
                              child: InkWell(
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ProductDetail(
                                              data: product,
                                              // backgroundColor:
                                              //     getSequentialColor(index),
                                            ),
                                      ),
                                    ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: getSequentialColor(index),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Container(
                                          // width: double.infinity,
                                          height: 180,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(14),
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                product.image?.isNotEmpty ==
                                                        true
                                                    ? product.image
                                                    : 'https://via.placeholder.com/50',
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // CUPONES
                                      if (tieneCupon)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            width: 50,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(0),
                                                topRight: Radius.circular(20),
                                                bottomLeft: Radius.circular(20),
                                                bottomRight: Radius.circular(0),
                                              ),
                                              color: const Color.fromARGB(
                                                166,
                                                255,
                                                255,
                                                255,
                                              ),
                                            ),

                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Icon(
                                                Icons.card_giftcard_rounded,
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                          ),
                                        ),

                                      // FAVORITOS
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        child: Container(
                                          width: 50,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(0),
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(20),
                                            ),
                                            color: const Color.fromARGB(
                                              166,
                                              255,
                                              255,
                                              255,
                                            ),
                                          ),

                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: BotonAgregarWishList(
                                              product: product,
                                            ),
                                          ),
                                        ),
                                      ),

                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 50,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(0),
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(20),
                                            ),
                                            color: const Color.fromARGB(
                                              166,
                                              255,
                                              255,
                                              255,
                                            ),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              final authProvider =
                                                  Provider.of<AuthProvider>(
                                                    context,
                                                    listen: false,
                                                  );

                                              if (!authProvider
                                                  .isAuthenticated) {
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
                                                price: double.parse(
                                                  product.price,
                                                ),
                                                image: product.image,
                                                quantity: 1,
                                              );
                                              Provider.of<CartProvider>(
                                                context,
                                                listen: false,
                                              ).addToCart(
                                                cartItem,
                                                selectedQuantity,
                                              );

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
                                            child: Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Icon(
                                                Icons.shopping_cart_outlined,
                                                size: 26,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // CATEGORIA
                                      Positioned(
                                        bottom: 95,
                                        left: 16,
                                        width: 160,
                                        child: Text(
                                          product.categoryName,
                                          style: TextStyle(
                                            color: AppColors.grayDark,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),

                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // TITULO
                                      Positioned(
                                        bottom: 55,
                                        left: 16,
                                        width: 150,
                                        height: 42,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(
                                                height: 1.1,
                                                fontSize: 11,
                                                color: AppColors.grayLight,
                                                // fontWeight: FontWeight.bold,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // PRECIO
                                      Positioned(
                                        bottom: 16,
                                        left: 16,
                                        child: Row(
                                          children: [
                                            Text(
                                              "₲${numberFormat(product.price)}",
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }, childCount: _products.length),
                      ),

                      // Indicador de carga centrado
                      SliverToBoxAdapter(
                        child:
                            _isLoadingMore
                                ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),
                    ],
                  ),
        ),
      ),
      floatingActionButton: const NewFloatingActionButton(),
    );
  }
}
