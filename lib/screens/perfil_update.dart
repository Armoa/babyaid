import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/usuario_model.dart';
import 'package:helfer/screens/home.dart';
import 'package:helfer/services/actualizar_usuario.dart';
import 'package:helfer/services/obtener_usuario.dart';

class PerfilUpdate extends StatefulWidget {
  const PerfilUpdate({super.key});

  @override
  PerfilUpdateState createState() => PerfilUpdateState();
}

class PerfilUpdateState extends State<PerfilUpdate> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos
  late TextEditingController _nombreUsuarioController;
  late TextEditingController _apellidoController;
  late TextEditingController _emailController;
  late TextEditingController _direccionController;
  late TextEditingController _ciudadController;
  late TextEditingController _barrioController;
  late TextEditingController _telefonoController;
  late TextEditingController _razonsocialController;
  late TextEditingController _rucController;
  late TextEditingController _dateBirthController;
  late TextEditingController _ciController;

  String _tipoDocumento = 'CI';
  String _whatsapp = '';
  String _ci = '';

  @override
  void initState() {
    super.initState();
    _nombreUsuarioController = TextEditingController();
    _apellidoController = TextEditingController();
    _emailController = TextEditingController();
    _telefonoController = TextEditingController();
    _direccionController = TextEditingController();
    _ciudadController = TextEditingController();
    _barrioController = TextEditingController();
    _razonsocialController = TextEditingController();
    _rucController = TextEditingController();
    _dateBirthController = TextEditingController();
    _ciController = TextEditingController();
    // Cargar datos iniciales del perfil
    _cargarDatosPerfil();
  }

  @override
  void dispose() {
    // Liberar controladores al cerrar la pantalla
    _nombreUsuarioController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _barrioController.dispose();
    _razonsocialController.dispose();
    _rucController.dispose();
    _dateBirthController.dispose();
    _ciController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosPerfil() async {
    UsuarioModel? datosPerfil = await obtenerUsuarioDesdeMySQL();
    if (datosPerfil != null) {
      // Rellenar los controladores con los datos obtenidos
      setState(() {
        _nombreUsuarioController.text = datosPerfil.name;
        _apellidoController.text = datosPerfil.lastName;
        _emailController.text = datosPerfil.email;
        _direccionController.text = datosPerfil.address;
        _ciudadController.text = datosPerfil.city;
        _barrioController.text = datosPerfil.barrio;
        _telefonoController.text = datosPerfil.phone;
        _razonsocialController.text = datosPerfil.razonsocial;
        _rucController.text = datosPerfil.ruc;
        _tipoDocumento = datosPerfil.tipoCi;
        _ciController.text = datosPerfil.ci;
        _dateBirthController.text =
            datosPerfil.dateBirth == '1990-01-01' ? '' : datosPerfil.dateBirth;
      });
    }
  }

  void _actualizarUsuario() async {
    bool success = await actualizarUsuarioEnMySQL(
      _nombreUsuarioController.text,
      _apellidoController.text,
      _emailController.text,
      _direccionController.text,
      _ciudadController.text,
      _barrioController.text,
      _telefonoController.text,
      _razonsocialController.text,
      _rucController.text,
      _dateBirthController.text,
      _ciController.text,
      _tipoDocumento,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Perfil actualizado correctamente"),
          duration: Duration(seconds: 2),
        ),
      );
      // Volver a ProfileScreen y forzar recarga
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al actualizar perfil"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
    );
    return Scaffold(
      backgroundColor: AppColors.blueDark,
      appBar: AppBar(title: const Text("Actualizar perfil")),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Rectángulo previo al título
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.grayDark,
                          borderRadius: BorderRadius.circular(
                            2,
                          ), // Si querés esquinas suaves
                        ),
                      ),
                      SizedBox(width: 10),
                      // Título centrado verticalmente
                      Text(
                        'Tipo de documento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grayDark,
                        ),
                      ),
                      SizedBox(width: 10),

                      // Línea que se extiende hacia la derecha
                      Expanded(
                        child: Container(height: 2, color: AppColors.grayDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

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
                    controller: _ciController,
                    keyboardType:
                        _tipoDocumento == 'CI'
                            ? TextInputType.phone
                            : TextInputType.name,
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
                      debugPrint('Número guardado: $_ci');
                    },
                  ),

                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nombreUsuarioController,
                    decoration: InputDecoration(
                      labelText: 'Nombres',
                      prefixIcon: const Icon(Icons.person),
                      border: outlineInputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce un nombre de usuario';
                      }
                      return null;
                    },
                    // onSaved: () {},
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _apellidoController,
                    decoration: InputDecoration(
                      labelText: 'Apellidos',
                      prefixIcon: const Icon(Icons.person),
                      border: outlineInputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce un nombre de usuario';
                      }
                      return null;
                    },
                    // onSaved: () {},
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _emailController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: const Icon(Icons.email),
                      border: outlineInputBorder,
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
                    // onSaved: (value) {_email = value!;                 },
                  ),

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _dateBirthController,
                    readOnly: true, // Hace que el campo sea solo lectura
                    decoration: InputDecoration(
                      labelText: "Fecha de nacimiento",
                      prefixIcon: const Icon(Icons.event),
                      border: outlineInputBorder,
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900), // Rango mínimo
                        lastDate: DateTime.now(), // Rango máximo
                      );

                      if (pickedDate != null) {
                        setState(() {
                          _dateBirthController.text =
                              "${pickedDate.toLocal()}".split(
                                ' ',
                              )[0]; // Formatear fecha
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor selecciona tu fecha de nacimiento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _telefonoController,
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
                      _whatsapp = value!;
                      debugPrint('Número guardado: $_whatsapp');
                    },
                  ),
                  const SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Rectángulo previo al título
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.grayDark,
                          borderRadius: BorderRadius.circular(
                            2,
                          ), // Si querés esquinas suaves
                        ),
                      ),
                      SizedBox(width: 10),
                      // Título centrado verticalmente
                      Text(
                        'Datos de Ubicación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grayDark,
                        ),
                      ),
                      SizedBox(width: 10),

                      // Línea que se extiende hacia la derecha
                      Expanded(
                        child: Container(height: 2, color: AppColors.grayDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _direccionController,
                    decoration: InputDecoration(
                      labelText: 'Dirección',
                      prefixIcon: const Icon(Icons.person),
                      border: outlineInputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce un nombre de usuario';
                      }
                      return null;
                    },
                    // onSaved: () {},
                  ),

                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _ciudadController,
                    decoration: InputDecoration(
                      labelText: 'Ciudad',
                      prefixIcon: const Icon(Icons.person),
                      border: outlineInputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce un nombre de usuario';
                      }
                      return null;
                    },
                    // onSaved: () {},
                  ),
                  const SizedBox(height: 30),
                  // BARRIO
                  TextFormField(
                    controller: _barrioController,
                    decoration: InputDecoration(
                      labelText: 'Barrio',
                      prefixIcon: const Icon(Icons.map),
                      border: outlineInputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce un nombre de usuario';
                      }
                      return null;
                    },
                    // onSaved: () {},
                  ),
                  // RAZON SOCIAL
                  const SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Rectángulo previo al título
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.grayDark,
                          borderRadius: BorderRadius.circular(
                            2,
                          ), // Si querés esquinas suaves
                        ),
                      ),
                      SizedBox(width: 10),
                      // Título centrado verticalmente
                      Text(
                        'Datos de Facturación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grayDark,
                        ),
                      ),
                      SizedBox(width: 10),
                      // Línea que se extiende hacia la derecha
                      Expanded(
                        child: Container(height: 2, color: AppColors.grayDark),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _razonsocialController,
                    decoration: InputDecoration(
                      labelText: 'Razon Social',
                      prefixIcon: const Icon(Icons.person),
                      border: outlineInputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce un nombre de usuario';
                      }
                      return null;
                    },
                    // onSaved: () {},
                  ),
                  // RUC
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _rucController,
                    decoration: InputDecoration(
                      labelText: 'C.I. / R.U.C.',
                      prefixIcon: const Icon(Icons.person),
                      border: outlineInputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce un nombre de usuario';
                      }
                      return null;
                    },
                    // onSaved: () {},
                  ),

                  const SizedBox(height: 30),

                  // BOTON  ACTUALAR DATOS DE PERFIL
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueDark,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _actualizarUsuario();
                            } else {
                              // No hacer nada, los errores se mostrarán automáticamente
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Actualizar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
