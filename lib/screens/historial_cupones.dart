import 'dart:convert';

import 'package:babyaid/model/colors.dart';
import 'package:babyaid/provider/auth_provider.dart';
import 'package:babyaid/services/functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HistorialCuponesPage extends StatefulWidget {
  const HistorialCuponesPage({super.key});

  @override
  HistorialCuponesPageState createState() => HistorialCuponesPageState();
}

class HistorialCuponesPageState extends State<HistorialCuponesPage> {
  List<dynamic> cupones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    final clienteId = Provider.of<AuthProvider>(context, listen: false).userId;
    if (clienteId != null) {
      obtenerCuponesUtilizados();
    }
  }

  Future<void> obtenerCuponesUtilizados() async {
    final clienteId = Provider.of<AuthProvider>(context, listen: false).userId;

    final response = await http.post(
      Uri.parse('https://helfer.flatzi.com/app/cupones/cupones_utilizados.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cliente_id': clienteId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        cupones = data['cupones_utilizados'];
        cargando = false;
      });
    } else {
      setState(() {
        cargando = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al obtener cupones')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueLight,
      appBar: AppBar(
        backgroundColor: AppColors.blueLight,
        surfaceTintColor: Colors.transparent,
        title: Text('Historial de utilizados'),
      ),
      body:
          cargando
              ? Center(child: CircularProgressIndicator())
              : cupones.isEmpty
              ? Center(child: Text('No tenés cupones activos 😔'))
              : Container(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                child: ListView.builder(
                  itemCount: cupones.length,
                  itemBuilder: (context, index) {
                    final cupon = cupones[index];

                    final fechaExpiracion = DateTime.parse(
                      cupon['valido_hasta'],
                    );
                    final ahora = DateTime.now();
                    final diferencia = fechaExpiracion.difference(ahora).inDays;

                    String traducirTipo(String tipo) {
                      switch (tipo) {
                        case 'percentage':
                          return 'Porcentaje';
                        case 'fixed_cart':
                          return 'Descuento total';
                        case 'fixed_product':
                          return 'Desc. X Producto';
                        default:
                          return 'Desconocido';
                      }
                    }

                    return Container(
                      height: 108,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),

                      child: Stack(
                        children: [
                          // Imagen de fondo
                          Positioned.fill(
                            child: Image.asset(
                              'assets/cupon-background2.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 120,
                            child: Text(
                              '${cupon['codigo']}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // // Monto (por ejemplo, "G. 15.000")
                          Positioned(
                            top: 42,
                            left: 120,
                            child: Text(
                              '₲${numeroFormat.format(cupon['monto'])}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // // Mensaje adicional (por ejemplo, "Fijo en carrito")
                          Positioned(
                            top: 78,
                            left: 120,
                            child: Text(
                              traducirTipo(cupon['tipo']),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                          ),

                          // // Fecha de expiración
                          Positioned(
                            bottom: 12,
                            right: 20,
                            child: SizedBox(
                              width: 55,
                              child: Text(
                                textAlign: TextAlign.center,
                                diferencia > 0
                                    ? 'Expira en $diferencia ${diferencia == 1 ? 'día' : 'días'}'
                                    : (diferencia == 0
                                        ? 'Expira hoy'
                                        : 'Cupón vencido'),
                                style: TextStyle(
                                  color:
                                      diferencia <= 0
                                          ? Colors.yellowAccent
                                          : Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
