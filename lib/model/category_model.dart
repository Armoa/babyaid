class Category {
  final String id;
  final String nombre;
  final String images;

  Category({required this.id, required this.nombre, required this.images});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      nombre: json['nombre'],
      images: 'https://farma.staweno.com/images/category/${json['images']}',
    );
  }
}
