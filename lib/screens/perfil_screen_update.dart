// import 'package:flutter/material.dart';
// import 'package:helfer/model/colors.dart';
// import 'package:helfer/model/usuario_model.dart';
// import 'package:helfer/screens/perfil_screen.dart';
// import 'package:helfer/services/actualizar_usuario.dart';
// import 'package:helfer/services/obtener_usuario.dart';

// class ProfileUpdateScreen extends StatefulWidget {
//   const ProfileUpdateScreen({super.key});

//   @override
//   ProfileUpdateScreenState createState() => ProfileUpdateScreenState();
// }

// class ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
//   //  final _formKey = GlobalKey<FormState>();

//   // Controladores para los campos
//   late TextEditingController _nombreUsuarioController;
//   late TextEditingController _apellidoController;
//   late TextEditingController _emailController;
//   late TextEditingController _direccionController;
//   late TextEditingController _ciudadController;
//   late TextEditingController _barrioController;
//   late TextEditingController _telefonoController;
//   late TextEditingController _razonsocialController;
//   late TextEditingController _rucController;
//   late TextEditingController _dateBirthController;

//   @override
//   void initState() {
//     super.initState();
//     _nombreUsuarioController = TextEditingController();
//     _apellidoController = TextEditingController();
//     _emailController = TextEditingController();
//     _telefonoController = TextEditingController();
//     _direccionController = TextEditingController();
//     _ciudadController = TextEditingController();
//     _barrioController = TextEditingController();
//     _razonsocialController = TextEditingController();
//     _rucController = TextEditingController();
//     _dateBirthController = TextEditingController();
//     // Cargar datos iniciales del perfil
//     _cargarDatosPerfil();
//   }

//   @override
//   void dispose() {
//     // Liberar controladores al cerrar la pantalla
//     _nombreUsuarioController.dispose();
//     _apellidoController.dispose();
//     _emailController.dispose();
//     _telefonoController.dispose();
//     _direccionController.dispose();
//     _ciudadController.dispose();
//     _barrioController.dispose();
//     _razonsocialController.dispose();
//     _rucController.dispose();
//     _dateBirthController.dispose();
//     super.dispose();
//   }

//   Future<void> _cargarDatosPerfil() async {
//     UsuarioModel? datosPerfil = await obtenerUsuarioDesdeMySQL();
//     if (datosPerfil != null) {
//       // Rellenar los controladores con los datos obtenidos
//       setState(() {
//         _nombreUsuarioController.text = datosPerfil.name;
//         _apellidoController.text = datosPerfil.lastName;
//         _emailController.text = datosPerfil.email;
//         _direccionController.text = datosPerfil.address;
//         _ciudadController.text = datosPerfil.city;
//         _barrioController.text = datosPerfil.barrio;
//         _telefonoController.text = datosPerfil.phone;
//         _razonsocialController.text = datosPerfil.razonsocial;
//         _rucController.text = datosPerfil.ruc;
//         _dateBirthController.text = datosPerfil.dateBirth;
//       });
//     }
//   }

//   void _actualizarUsuario() async {
//     bool success = await actualizarUsuarioEnMySQL(
//       _nombreUsuarioController.text,
//       _apellidoController.text,
//       _emailController.text,
//       _direccionController.text,
//       _ciudadController.text,
//       _barrioController.text,
//       _telefonoController.text,
//       _razonsocialController.text,
//       _rucController.text,
//       _dateBirthController.text,
//     );

//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Perfil actualizado correctamente"),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       // Volver a ProfileScreen y forzar recarga
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => ProfileScreen()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error al actualizar perfil"),
//           duration: Duration(seconds: 2),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var outlineInputBorder = OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16.0),
//     );
//     return Scaffold(
//       backgroundColor: AppColors.blueDark,
//       appBar: AppBar(title: const Text("Actualizar perfil")),
//       body: Container(
//         decoration: const BoxDecoration(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//           color: Color.fromARGB(255, 255, 255, 255),
//         ),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Form(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 30),
//                   TextFormField(
//                     controller: _nombreUsuarioController,
//                     decoration: InputDecoration(
//                       labelText: 'Nombre',
//                       prefixIcon: const Icon(Icons.person),
//                       border: outlineInputBorder,
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Por favor, introduce un nombre de usuario';
//                       }
//                       return null;
//                     },
//                     // onSaved: () {},
//                   ),
//                   const SizedBox(height: 30),
//                   TextFormField(
//                     controller: _apellidoController,
//                     decoration: InputDecoration(
//                       labelText: 'Apellido',
//                       prefixIcon: const Icon(Icons.person),
//                       border: outlineInputBorder,
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Por favor, introduce un nombre de usuario';
//                       }
//                       return null;
//                     },
//                     // onSaved: () {},
//                   ),
//                   const SizedBox(height: 20),

//                   TextFormField(
//                     controller: _emailController,
//                     decoration: InputDecoration(
//                       labelText: 'Correo Electrónico',
//                       prefixIcon: const Icon(Icons.email),
//                       border: outlineInputBorder,
//                     ),
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Por favor, introduce un correo electrónico';
//                       }
//                       if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                         return 'Por favor, introduce un correo válido';
//                       }
//                       return null;
//                     },
//                     // onSaved: (value) {_email = value!;                 },
//                   ),

//                   const SizedBox(height: 20),
//                   TextField(
//                     controller: _dateBirthController,
//                     readOnly: true, // Hace que el campo sea solo lectura
//                     decoration: InputDecoration(
//                       labelText: "Fecha de nacimiento",
//                       prefixIcon: const Icon(Icons.event),
//                       border: outlineInputBorder,
//                     ),
//                     onTap: () async {
//                       DateTime? pickedDate = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime(1900), // Rango mínimo
//                         lastDate: DateTime.now(), // Rango máximo
//                       );

//                       if (pickedDate != null) {
//                         setState(() {
//                           _dateBirthController.text =
//                               "${pickedDate.toLocal()}".split(
//                                 ' ',
//                               )[0]; // Formatear fecha
//                         });
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 20),

//                   TextFormField(
//                     controller: _telefonoController,
//                     decoration: InputDecoration(
//                       labelText: 'Telefono',
//                       prefixIcon: const Icon(Icons.person),
//                       border: outlineInputBorder,
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Por favor, introduce un nombre de usuario';
//                       }
//                       return null;
//                     },
//                     // onSaved: () {},
//                   ),
//                   const SizedBox(height: 30),
//                   TextFormField(
//                     controller: _direccionController,
//                     decoration: InputDecoration(
//                       labelText: 'Dirección',
//                       prefixIcon: const Icon(Icons.person),
//                       border: outlineInputBorder,
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Por favor, introduce un nombre de usuario';
//                       }
//                       return null;
//                     },
//                     // onSaved: () {},
//                   ),

//                   const SizedBox(height: 30),
//                   TextFormField(
//                     controller: _ciudadController,
//                     decoration: InputDecoration(
//                       labelText: 'Ciudad',
//                       prefixIcon: const Icon(Icons.person),
//                       border: outlineInputBorder,
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Por favor, introduce un nombre de usuario';
//                       }
//                       return null;
//                     },
//                     // onSaved: () {},
//                   ),
//                   const SizedBox(height: 30),
//                   // BARRIO
//                   TextFormField(
//                     controller: _barrioController,
//                     decoration: InputDecoration(
//                       labelText: 'Barrio',
//                       prefixIcon: const Icon(Icons.map),
//                       border: outlineInputBorder,
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Por favor, introduce un nombre de usuario';
//                       }
//                       return null;
//                     },
//                     // onSaved: () {},
//                   ),
//                   // RAZON SOCIAL
//                   const SizedBox(height: 30),
//                   TextFormField(
//                     controller: _razonsocialController,
//                     decoration: InputDecoration(
//                       labelText: 'Razon Social',
//                       prefixIcon: const Icon(Icons.person),
//                       border: outlineInputBorder,
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Por favor, introduce un nombre de usuario';
//                       }
//                       return null;
//                     },
//                     // onSaved: () {},
//                   ),
//                   // RUC
//                   const SizedBox(height: 30),
//                   TextFormField(
//                     controller: _rucController,
//                     decoration: InputDecoration(
//                       labelText: 'C.I. / R.U.C.',
//                       prefixIcon: const Icon(Icons.person),
//                       border: outlineInputBorder,
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Por favor, introduce un nombre de usuario';
//                       }
//                       return null;
//                     },
//                     // onSaved: () {},
//                   ),

//                   const SizedBox(height: 30),

//                   // BOTON  ACTUALAR DATOS DE PERFIL
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.blueDark,
//                           ),
//                           onPressed: () {
//                             _actualizarUsuario();
//                           },
//                           child: const Padding(
//                             padding: EdgeInsets.all(16),
//                             child: Text(
//                               'Actualizar datos',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
