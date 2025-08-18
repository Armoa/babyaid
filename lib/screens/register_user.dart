import 'dart:convert';

import 'package:bebito/model/colors.dart';
import 'package:bebito/screens/verificacion_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _diaController = TextEditingController();
  final TextEditingController _mesController = TextEditingController();
  final TextEditingController _anioController = TextEditingController();

  final FocusNode _diaFocusNode = FocusNode();
  final FocusNode _mesFocusNode = FocusNode();
  final FocusNode _anioFocusNode = FocusNode();

  @override
  void dispose() {
    _diaController.dispose();
    _mesController.dispose();
    _anioController.dispose();
    _diaFocusNode.dispose();
    _mesFocusNode.dispose();
    _anioFocusNode.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _userlastname = '';
  String _email = '';
  // String _password = '';
  String _tipoDocumento = 'CI';
  String _ci = '';
  String _celular = '';
  String _dia = '';
  String _mes = '';
  String _anio = '';
  bool _obscureText = true;

  // NUEVA FUNCION PARA REGISTRAR
  Future<void> enviarRegistro() async {
    final fecha = '$_anio-$_mes-$_dia';

    // Validar la fecha antes de enviar
    if (DateTime.tryParse(fecha) == null) {
      print('Fecha inválida: $fecha');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La fecha de nacimiento no es válida')),
      );
      return;
    }

    final url = Uri.parse('https://helfer.flatzi.com/app/user_register.php');
    final response = await http.post(
      url,
      body: {
        'name': _username,
        'last_name': _userlastname,
        'tipo_ci': _tipoDocumento,
        'ci': _ci,
        'phone': _celular,
        'date_birth': '$_anio-$_mes-$_dia',
        'email': _email,
        'password': _passwordController.text,
      },
    );

    try {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Registro exitoso! Bienvenido 🎉'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Esperar brevemente antes de redirigir
        await Future.delayed(Duration(seconds: 2));

        // Redirigir al Verificacion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificacionScreen(phone: _celular),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Error al registrar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error al decodificar JSON: $e');
      print('Respuesta recibida: ${response.body}');
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
              "Área de Registro",
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
        child: SingleChildScrollView(
          child: SizedBox(
            // height: MediaQuery.of(context).size.height * 0.87,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            color: AppColors.primario,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Icon(
                              Icons.app_registration,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    Text(
                      'Tipo de documento:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 2, 15, 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0, // Grosor del borde (aquí lo haces fino)
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('CI'),
                              value: 'CI',
                              groupValue: _tipoDocumento,
                              onChanged: (value) {
                                setState(() {
                                  _tipoDocumento = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('DNI'),
                              value: 'DNI',
                              groupValue: _tipoDocumento,
                              onChanged: (value) {
                                setState(() {
                                  _tipoDocumento = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText:
                            _tipoDocumento == 'CI'
                                ? 'Cédula de Identidad'
                                : 'Documento de identidad',

                        prefixIcon: const Icon(Icons.credit_card),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce numero de documento';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _ci = value!;
                      },
                    ),

                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nombres',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce un nombre de usuario';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _username = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Apellidos',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce el apellido';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        _userlastname = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Fecha de nacimiento:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 7, 15, 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0, // Grosor del borde (aquí lo haces fino)
                        ),
                      ),
                      child: Row(
                        children: [
                          // Día
                          Expanded(
                            child: TextFormField(
                              controller: _diaController,
                              focusNode: _diaFocusNode,
                              decoration: const InputDecoration(
                                hintText: 'dd',
                                counterText: '',
                                border: InputBorder.none,
                              ),
                              maxLength: 2,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                if (value.length == 2) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_mesFocusNode);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Día requerido';
                                }
                                int? day = int.tryParse(value);
                                if (day == null || day < 1 || day > 31) {
                                  return 'Día inválido';
                                }
                                return null;
                              },
                              onSaved: (value) => _dia = value!,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text('/', style: TextStyle(fontSize: 18)),
                          ),

                          // Mes
                          Expanded(
                            child: TextFormField(
                              controller: _mesController,
                              focusNode: _mesFocusNode,
                              decoration: InputDecoration(
                                hintText: 'mm',
                                counterText: '',
                                border: InputBorder.none,
                              ),
                              maxLength: 2,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                if (value.length == 2) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_anioFocusNode);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Mes requerido';
                                }
                                int? month = int.tryParse(value);
                                if (month == null || month < 1 || month > 12) {
                                  return 'Mes inválido';
                                }
                                return null;
                              },
                              onSaved: (value) => _mes = value!,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text('/', style: TextStyle(fontSize: 18)),
                          ),

                          // Año
                          Expanded(
                            child: TextFormField(
                              controller: _anioController,
                              focusNode: _anioFocusNode,
                              decoration: InputDecoration(
                                hintText: 'aaaa',
                                counterText: '',
                                border: InputBorder.none,
                              ),
                              maxLength: 4,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                if (value.length == 4) {
                                  _anioFocusNode.unfocus();
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Año requerido';
                                }
                                int? year = int.tryParse(value);
                                if (year == null ||
                                    year < 1900 ||
                                    year > DateTime.now().year) {
                                  return 'Año inválido';
                                }
                                return null;
                              },
                              onSaved: (value) => _anio = value!,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        // Permite solo dígitos. Esto evitará espacio sentr  carácter que no sea un número.
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'WhatsApp',
                        // Ícono del teléfono a la izquierda
                        prefixIcon: const Icon(Icons.phone_android_rounded),
                        // Prefijo estático con la bandera y el código
                        prefix: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/paraguay_flag.png',
                              width: 24, // Ajusta el tamaño de la bandera
                              height: 24,
                            ),
                            const SizedBox(
                              width: 8,
                            ), // Espacio entre la bandera y el texto
                            const Text('+595 '), // El texto del código de país
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce un número de WhatsApp válido';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // Aquí solo se guarda lo que el usuario escribió, sin el prefijo.
                        _celular = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce un correo electrónico';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Por favor, introduce un correo válido';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureText,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce una contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                      // onSaved: (value) {
                      //   if (value != null) _password = value;
                      // },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmController,
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      obscureText: _obscureText,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, confirma tu contraseña';
                        }
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppColors.primario,
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                enviarRegistro(); // tu función para enviar al backend
                              }
                            },

                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Registrarse',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
