import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/product_model.dart';
import 'package:helfer/screens/product_detail.dart';
import 'package:http/http.dart' as http;

class NewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NewAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      toolbarHeight: 80,
      actions: [
        // BUSCARDOR
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: Container(
            padding: EdgeInsets.zero,
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(26)),
              border: Border.all(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.blueLight
                        : AppColors.blueDark,

                width: 1, // Grosor de la línea
              ),
            ),

            child: IconButton(
              icon: const Icon(Icons.search, size: 24),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const ProductSearchDialog(),
                );
              },
            ),
          ),
        ),
      ],
      leading: Builder(
        builder: (context) {
          return InkWell(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.menu,
                size: 32.0, // Tamaño del icono
              ),
            ),
          );
        },
      ),
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            Theme.of(context).brightness == Brightness.dark
                ? 'assets/logoApbar-dark.png'
                : 'assets/logo-blanco.png',
            scale: 1.5,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}

class ProductSearchDialog extends StatefulWidget {
  const ProductSearchDialog({super.key});

  @override
  ProductSearchDialogState createState() => ProductSearchDialogState();
}

class ProductSearchDialogState extends State<ProductSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _products = [];
  bool _isLoading = false;
  final perPage = "per_page=20";
  // Función para buscar productos en WooCommerce
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _products = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String url =
          "https://farma.staweno.com/search_products.php?query=$query&limit=20";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _products = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception("Error al buscar productos: ${response.statusCode}");
      }
    } catch (error) {
      print("Error en búsqueda: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
              children: [
                // Campo de texto para búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Buscar productos...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.grayLight),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppColors.grayDark,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _products = [];
                          _isLoading = false;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    // Si el campo está vacío, no iniciar una búsqueda
                    if (value.isEmpty) {
                      setState(() {
                        _products = [];
                        _isLoading = false;
                      });
                      return;
                    }

                    searchProducts(
                      value,
                    ); // Realizar la búsqueda en tiempo real
                  },
                ),
                const SizedBox(height: 16.0),
                // Mostrar resultados o indicador de carga
                _isLoading
                    ? const CircularProgressIndicator()
                    : _searchController.text.isEmpty
                    ? const SizedBox() // Si aún no se ha iniciado una búsqueda, no mostrar nada
                    : _products.isEmpty
                    ? const Center(child: Text("No se encontraron productos."))
                    : LimitedBox(
                      maxHeight: 290,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                "${product['image'] ?? 'https://farma.staweno.com/sw-admin/uploads/placeholder.png'}",
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              product['name'] ?? "Producto sin nombre",
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              "₲. ${product['price'] ?? '0'}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetail(
                                        data: Product.fromJson(product),
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
              ],
            ),
          ),
          // Botón para cerrar la ventana emergente
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap:
                  () =>
                      Navigator.of(
                        context,
                      ).pop(), // Cerrar el cuadro de diálogo,
              child: ClipOval(
                child: Container(
                  width: 26,
                  height: 26,
                  color: AppColors.grayDark,
                  child: Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
