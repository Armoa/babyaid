import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/usuario_model.dart';
import 'package:helfer/provider/auth_provider.dart';
import 'package:provider/provider.dart';

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
  // String _whatsapp = ''; // Ya no necesitas esta variable si usas el controller
  // String _ci = ''; // Ya no necesitas esta variable si usas el controller

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

    // Llama a _cargarDatosPerfilDesdeAuthProvider en el primer frame
    // para asegurar que el contexto esté disponible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosPerfilDesdeAuthProvider();
    });
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

  // --- NUEVO MÉTODO PARA CARGAR DATOS DESDE AUTHPROVIDER ---
  Future<void> _cargarDatosPerfilDesdeAuthProvider() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user =
        authProvider.user; // Obtén el objeto UsuarioModel del AuthProvider

    if (user != null) {
      setState(() {
        _nombreUsuarioController.text = user.name;
        _apellidoController.text = user.lastName;
        // _emailController.text = user.email; // El email no debería ser editable
        _direccionController.text = user.address;
        _ciudadController.text = user.city;
        _barrioController.text = user.barrio;
        _telefonoController.text = user.phone;
        _razonsocialController.text = user.razonsocial;
        _rucController.text = user.ruc;
        _tipoDocumento = user.tipoCi; // Asume 'CI' si es nulo
        _ciController.text = user.ci;
        _dateBirthController.text =
            user.dateBirth == '1990-01-01'
                ? ''
                : user.dateBirth; // Maneja el valor por defecto
      });
    } else {
      // Si el usuario es nulo, significa que no está logueado o hubo un error al cargar.
      // Puedes redirigir al login o mostrar un mensaje.
      print("DEBUG PerfilUpdate: Usuario no disponible en AuthProvider.");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo cargar el perfil. Inicia sesión nuevamente.',
            ),
          ),
        );
        // Opcional: Redirigir al login si el usuario no está disponible
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    }
  }

  void _actualizarUsuario() async {
    if (!_formKey.currentState!.validate()) {
      return; // No continuar si la validación falla
    }
    _formKey.currentState!.save(); // Guarda los valores de los campos

    // Obtén el AuthProvider para acceder al userId y al método makeAuthenticatedRequest si es necesario
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Aquí debes llamar a tu servicio para actualizar el usuario en MySQL
    // Necesitarás el ID del usuario para la actualización.
    // Asumo que tu servicio 'actualizarUsuarioEnMySQL' existe y espera estos parámetros.
    // También asumo que tu backend espera el userId para actualizar.

    // bool success = await PerfilService().actualizarUsuario(
    //   // <--- Asumo que tienes un PerfilService
    //   authProvider.userId!,
    //   _nombreUsuarioController.text,
    //   _apellidoController.text,
    //   _emailController.text,
    //   _direccionController.text,
    //   _ciudadController.text,
    //   _barrioController.text,
    //   _telefonoController.text,
    //   _razonsocialController.text,
    //   _rucController.text,
    //   _dateBirthController.text,
    //   _ciController.text,
    //   _tipoDocumento,
    // );

    // if (success) {
    //   if (context.mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text("Perfil actualizado correctamente"),
    //         duration: Duration(seconds: 2),
    //       ),
    //     );
    //     // Después de actualizar, recarga el usuario en el AuthProvider
    //     // para que los cambios se reflejen en toda la app.
    //     await authProvider.loadUser(); // <--- ¡IMPORTANTE!

    //     // Vuelve a la pantalla anterior (ProfileScreen)
    //     Navigator.pop(
    //       context,
    //     ); // Usamos pop para regresar a la pantalla anterior
    //   }
    // } else {
    //   if (context.mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text("Error al actualizar perfil"),
    //         duration: Duration(seconds: 2),
    //         backgroundColor: Colors.red,
    //       ),
    //     );
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    var outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
    );

    // Escucha el AuthProvider para que la UI se reconstruya si el usuario cambia
    final authProvider = Provider.of<AuthProvider>(context);
    final UsuarioModel? user = authProvider.user;

    // Si el usuario es nulo, muestra un indicador de carga o un mensaje.
    // Esto debería ser raro si la navegación es correcta.
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Actualizar perfil")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.green,
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
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.grayDark,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Tipo de documento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grayDark,
                        ),
                      ),
                      const SizedBox(width: 10),
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
                      border: Border.all(color: Colors.grey, width: 1.0),
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
                        return 'Por favor, introduce número de documento';
                      }
                      return null;
                    },
                    // onSaved: (value) { _ci = value!; }, // Ya no es necesario si usas el controller directamente
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
                        return 'Por favor, introduce un nombre';
                      }
                      return null;
                    },
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
                        return 'Por favor, introduce un apellido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _emailController,
                    enabled: false, // El email no debería ser editable
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
                  ),

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _dateBirthController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Fecha de nacimiento",
                      prefixIcon: const Icon(Icons.event),
                      border: outlineInputBorder,
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          _dateBirthController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'WhatsApp',
                      prefixIcon: const Icon(Icons.phone_android_rounded),
                      prefix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/paraguay_flag.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text('+595 '),
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
                    // onSaved: (value) { _whatsapp = value!; }, // Ya no es necesario
                  ),
                  const SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.grayDark,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Datos de Ubicación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grayDark,
                        ),
                      ),
                      const SizedBox(width: 10),
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
                      prefixIcon: const Icon(
                        Icons.place,
                      ), // Cambiado a Icons.place
                      border: outlineInputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce una dirección';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _ciudadController,
                    decoration: InputDecoration(
                      labelText: 'Ciudad',
                      prefixIcon: const Icon(
                        Icons.location_city,
                      ), // Cambiado a Icons.location_city
                      border: outlineInputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce una ciudad';
                      }
                      return null;
                    },
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
                        return 'Por favor, introduce un barrio';
                      }
                      return null;
                    },
                  ),
                  // RAZON SOCIAL
                  const SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.grayDark,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Datos de Facturación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grayDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(height: 2, color: AppColors.grayDark),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _razonsocialController,
                    decoration: InputDecoration(
                      labelText: 'Razón Social', // Corregido el typo
                      prefixIcon: const Icon(
                        Icons.business,
                      ), // Cambiado a Icons.business
                      border: outlineInputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce la razón social';
                      }
                      return null;
                    },
                  ),
                  // RUC
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _rucController,
                    decoration: InputDecoration(
                      labelText: 'C.I. / R.U.C.',
                      prefixIcon: const Icon(
                        Icons.credit_card,
                      ), // Cambiado a Icons.credit_card
                      border: outlineInputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce el C.I. / R.U.C.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // BOTON ACTUALAR DATOS DE PERFIL
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
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
