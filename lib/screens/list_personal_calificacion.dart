import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/personal_model.dart';
import 'package:helfer/screens/comentario_screen.dart';
import 'package:http/http.dart' as http;

class RankingPersonalScreen extends StatefulWidget {
  const RankingPersonalScreen({super.key});

  @override
  State<RankingPersonalScreen> createState() => _RankingPersonalScreenState();
}

class _RankingPersonalScreenState extends State<RankingPersonalScreen> {
  List<PersonalCalificado> lista = [];

  @override
  void initState() {
    super.initState();
    cargarPersonales();
  }

  Future<void> cargarPersonales() async {
    final response = await http.get(
      Uri.parse('https://helfer.flatzi.com/app/get_ranking.php'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      setState(() {
        lista = data.map((e) => PersonalCalificado.fromJson(e)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        toolbarHeight: 120,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: Image.asset('assets/logo-blanco.png', scale: 2.5),
                ),
              ],
            ),
            SizedBox(height: 25),
            Text(
              "Ranking Helfer",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 25),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: AppColors.white,
        ),
        child: ListView.builder(
          itemCount: lista.length,
          itemBuilder: (context, index) {
            final p = lista[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://helfer.flatzi.com/img/personal/${p.foto}',
                  ),
                ),
                title: Text('${p.nombre} ${p.apellido}'),
                subtitle: Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < p.promedio.round() ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    );
                  }),
                ),
                trailing: Text('${p.promedio.toStringAsFixed(1)} ⭐'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ComentarioScreen(personal: p),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
