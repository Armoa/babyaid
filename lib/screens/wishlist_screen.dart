import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/provider/wishlist_provider.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';

String numberFormat(String x) {
  List<String> parts = x.toString().split('.');
  RegExp re = RegExp(r'\B(?=(\d{3})+(?!\d))');
  parts[0] = parts[0].replaceAll(re, '.');
  if (parts.length == 1) {
    parts.add('');
  } else {
    parts[1] = parts[1].padRight(2, '0').substring(0, 2);
  }
  return parts.join('');
}

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  WishlistScreenState createState() => WishlistScreenState();
}

class WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Cargar la lista localmente
    wishlistProvider.loadWishlistFromLocalStorage(
      authProvider.userId!.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.blueLight,
      appBar: AppBar(
        backgroundColor: AppColors.blueLight,
        surfaceTintColor: Colors.transparent,
        title: const Text('Lista de Deseos'),
      ),
      body:
          wishlistProvider.wishlist.isEmpty
              ? Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                child: const Center(
                  child: Text('Tu lista de deseos está vacía'),
                ),
              )
              : Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListView.builder(
                    itemCount: wishlistProvider.wishlist.length,
                    itemBuilder: (context, index) {
                      final item = wishlistProvider.wishlist[index];
                      return ListTile(
                        leading: Image.network(item.image),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 13,
                            overflow: TextOverflow.ellipsis, // Acortar texto
                          ),
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          '₲. ${numberFormat(item.price.toStringAsFixed(0))}',
                        ),

                        // "₲. ${numberFormat(product['price'])}"
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );

                            wishlistProvider.removeFromWishlist(
                              item.id,
                              authProvider.userId!
                                  .toString(), // Pasar el userId
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
    );
  }
}
