import 'dart:convert';

import 'package:bebito/model/colors.dart';
import 'package:bebito/model/personal_model.dart';
import 'package:bebito/screens/comentario_screen.dart';
import 'package:bebito/screens/perfil_personal_screen.dart';
import 'package:bebito/widget/title_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Supongamos que tienes un método que obtiene PersonalModel por ID
  Future<PersonalModel?> fetchPersonalModel(int id) async {
    final url = Uri.parse(
      'https://helfer.flatzi.com/app/personal_datos.php?id=$id',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      if (jsonBody['success'] == true && jsonBody['data'] != null) {
        return PersonalModel.fromJson(jsonBody['data']);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        leading: null,
        title: TitleAppbar(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: AppColors.white,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Ranking Helfer",
                  style: GoogleFonts.quicksand(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: lista.length,
                itemBuilder: (context, index) {
                  final p = lista[index];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://helfer.flatzi.com/img/personal/${p.foto}',
                        ),
                      ),
                      title: Text(
                        '${p.nombre} ${p.apellido}',
                        style: TextStyle(fontSize: 14),
                      ),
                      subtitle: Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < p.promedio.round()
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                      ),
                      trailing: Column(
                        children: [
                          Text('${p.promedio.toStringAsFixed(1)} ⭐'),

                          GestureDetector(
                            onTap: () async {
                              final personalModel = await fetchPersonalModel(
                                p.id,
                              );
                              if (personalModel == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'No se pudo cargar el perfil',
                                    ),
                                  ),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PerfilPersonalScreen(
                                        personalRating: p,
                                        personalModel: personalModel,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 5),
                              padding: EdgeInsets.fromLTRB(14, 4, 15, 4),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Text(
                                "Ver Perfil",
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
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
          ],
        ),
      ),
    );
  }
}
