import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WishlistService {
  Future<void> saveWishlistToLocalStorage(
    String userId,
    List<WishlistItem> wishlistItems,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = wishlistItems.map((item) => item.toJson()).toList();
    prefs.setString(
      'wishlist_$userId',
      json.encode(wishlistJson),
    ); // Guardar usando el userId
  }

  Future<List<WishlistItem>> loadWishlistFromLocalStorage(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = prefs.getString('wishlist_$userId');
    if (wishlistJson != null) {
      final List<dynamic> decodedJson = json.decode(wishlistJson);
      return decodedJson.map((item) => WishlistItem.fromJson(item)).toList();
    }
    return []; // Retornar una lista vacía si no hay datos
  }
}

// Defini el modelo para los elementos del Wishlist
class WishlistItem {
  final String id;
  final String name;
  final String image;
  final double price;

  WishlistItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
  });

  // Convertir a JSON para guardarlo localmente o enviarlo al servidor
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image': image, 'price': price};
  }

  // Crear un objeto a partir de un JSON

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }
}

// Gestionar almacenamiento local con Shared_Preferences
Future<void> saveWishlistToLocalStorage(
  String userId,
  List<WishlistItem> wishlistItems,
) async {
  final prefs = await SharedPreferences.getInstance();
  final wishlistJson = wishlistItems.map((item) => item.toJson()).toList();
  prefs.setString(
    'wishlist_$userId',
    json.encode(wishlistJson),
  ); // Usar el userId recibido para guardar la lista
}

// Guardar con el ID del usuario
Future<List<WishlistItem>> getWishlistFromLocalStorage() async {
  final prefs = await SharedPreferences.getInstance();
  final wishlistJson = prefs.getString('wishlist');
  if (wishlistJson == null) return [];
  return (json.decode(wishlistJson) as List)
      .map((item) => WishlistItem.fromJson(item))
      .toList();
}

List<WishlistItem> wishlist = []; // Definición de la lista
// Crear las funciones de CRUD
void addToWishlist(String userId, WishlistItem item) {
  wishlist.add(item);
  saveWishlistToLocalStorage(userId, wishlist);
}

void removeFromWishlist(String userId, String productId) {
  wishlist.removeWhere((item) => item.id == productId);
  saveWishlistToLocalStorage(userId, wishlist);
}

List<WishlistItem> getWishlist() {
  return wishlist;
}
