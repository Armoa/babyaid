import 'package:babyaid/model/colors.dart';
import 'package:babyaid/services/fetch_product.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BrandBox extends StatefulWidget {
  const BrandBox({super.key});

  @override
  State<BrandBox> createState() => _BrandBoxState();
}

class _BrandBoxState extends State<BrandBox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
      child: SizedBox(
        height: 100.0,
        child: FutureBuilder<List<String>?>(
          future: fetchShowBrand(),
          builder: (context, featured) {
            if (featured.hasData) {
              if (featured.data!.isEmpty) {
                return const Center(child: Text("0 Marcas disponibles"));
              }
              return Container(
                width: double.infinity,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.blueBlak
                        : Colors.white,
                child: CarouselSlider.builder(
                  itemCount: featured.data!.length,
                  options: CarouselOptions(
                    height: 100,
                    viewportFraction: 0.25,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 2),
                    enlargeCenterPage: false,

                    // viewportFraction: 0.8,
                  ),
                  itemBuilder: (context, i, realIdx) {
                    return InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            featured.data![i],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (featured.hasError) {
              return Center(child: Text(featured.error.toString()));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
