class Product {
  final int id;
  final String name;
  final String description;
  final String shortDescription;
  final String price;
  final String priceSale;
  final int onSale;
  final String image;
  final int featured;
  final String gal1;
  final String gal2;
  final String gal3;
  final int stock;
  final int idUser;
  final int idCategory;
  final String categoryName;
  final String createDate;
  final int generaCupon;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.price,
    required this.priceSale,
    required this.onSale,
    required this.image,
    required this.featured,
    required this.gal1,
    required this.gal2,
    required this.gal3,
    required this.stock,
    required this.idUser,
    required this.idCategory,
    required this.categoryName,
    required this.createDate,
    required this.generaCupon,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    //  Mostrar como realmente viene el tipdo de la API
    // print("id tipo: ${json['id'].runtimeType}, valor: ${json['id']}");

    return Product(
      // recomendadiciomo Forzar a covertir a entero
      id: int.tryParse(json['id'].toString()) ?? 0,
      // recomendadiciomo Forzar a covertir a String
      name: json['name']?.toString() ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? '',
      price: json['price'],
      priceSale: json['price_sale']?.toString() ?? '',
      onSale: int.tryParse(json['on_sale'].toString()) ?? 0,
      image: json['image'] ?? '',
      featured: int.tryParse(json['featured'].toString()) ?? 0,
      gal1: json['gal1']?.toString() ?? '',
      gal2: json['gal2']?.toString() ?? '',
      gal3: json['gal3']?.toString() ?? '',
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      idUser: json['id_user'] ?? 0,
      idCategory: int.tryParse(json['id_category'].toString()) ?? 0,
      categoryName: json['category_name']?.toString() ?? '',
      createDate: json['create_date'] ?? '',
      generaCupon: int.tryParse(json['genera_cupon'].toString()) ?? 0,
    );
  }
}
