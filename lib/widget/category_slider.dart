import 'package:flutter/material.dart';
import 'package:helfer/model/category_model.dart';
import 'package:helfer/services/category_service.dart';
// import 'package:helfer/screens/list_categoria.dart';
import 'package:helfer/widget/category_widget.dart';

class CategorySlider extends StatelessWidget {
  final Future<List<dynamic>> Function()
  getCategory; // Función para obtener categorías

  const CategorySlider({super.key, required this.getCategory});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: FutureBuilder<List<Category>>(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final categories = snapshot.data!;
            if (categories.isEmpty) {
              return const Center(child: Text("0 Categoría a mostrar"));
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final cat = categories[i];
                return SizedBox(
                  width: 94.0,
                  child: CategoryCard(
                    imagePath:
                        cat.images.isNotEmpty
                            ? cat.images
                            : 'https://www.piletasyjuguetes.com/wp-content/uploads/2025/05/didactic.png',
                    label: cat.nombre,
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder:
                      //         (context) =>
                      //             ListCategoria(cat.id.toString(), cat.nombre),
                      //   ),
                      // );
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
