import 'dart:convert';

import 'package:bebito/model/colors.dart';
import 'package:bebito/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VerificacionScreen extends StatefulWidget {
  final String phone;
  const VerificacionScreen({super.key, required this.phone});

  @override
  State<VerificacionScreen> createState() => _VerificacionScreenState();
}

class _VerificacionScreenState extends State<VerificacionScreen> {
  final TextEditingController _codigoController = TextEditingController();
  bool _validando = false;

  Future<void> verificarCodigo() async {
    final codigo = _codigoController.text.trim();

    if (codigo.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('El código debe tener 6 dígitos')));
      return;
    }

    setState(() => _validando = true);

    final url = Uri.parse('https://helfer.flatzi.com/app/verify_code.php');
    final response = await http.post(
      url,
      body: {'phone': widget.phone, 'code': codigo},
    );

    setState(() => _validando = false);

    try {
      final data = jsonDecode(response.body);
      if (data['status'] == 'verified') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cuenta verificada 🎉')));
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Código incorrecto')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de servidor: ${response.body}')),
      );
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
              "Activacion de cuenta",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 25),
          ],
        ),

        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Ingresa el código recibido por WhatsApp',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _codigoController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Código de 6 dígitos',
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                      ),
                      onPressed: _validando ? null : verificarCodigo,
                      icon: Icon(Icons.check, color: Colors.white),
                      label: Text(
                        _validando ? 'Verificando...' : 'Confirmar',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
