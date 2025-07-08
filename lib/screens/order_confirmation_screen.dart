import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/mapa_city.dart';
import 'package:helfer/model/usuario_model.dart';
import 'package:helfer/provider/auth_provider.dart' as local_auth;
import 'package:helfer/provider/auth_provider.dart';
import 'package:helfer/provider/cart_provider.dart';
import 'package:helfer/provider/payment_provider.dart';
import 'package:helfer/screens/add_address_screen.dart';
import 'package:helfer/screens/home.dart';
import 'package:helfer/services/functions.dart';
import 'package:helfer/services/generar_cupones.dart';
import 'package:helfer/services/obtener_usuario.dart';
import 'package:helfer/services/ubicacion_service.dart';
import 'package:helfer/widget/select_metod_pay.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final List cartItems;
  final double totalAmount;
  final double totalConDescuento;
  final int cuponesParaGenerar;
  final int freeShipping;
  final List<dynamic> cuponesSeleccionados;
  final int cuponSeleccionado;
  final double montoMinimoCupon;

  const OrderConfirmationScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.totalConDescuento,
    required this.cuponesParaGenerar,
    required this.freeShipping,
    required this.cuponesSeleccionados,
    required this.cuponSeleccionado,
    required this.montoMinimoCupon,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  String? selectedCityId; //  Guardará el ID de la ciudad seleccionada
  String callePrincipal = "";
  bool tieneUbicacionesGuardadas = true; // Cambia según
  bool isLoading = true; // Estado inicial que indica cargando
  double subtotal = 0;
  int shippingCost = 0;
  late double total;
  String ciudadSelect = "";
  String? selectedLocation;
  String? selectedUbicacion;

  // Controladores de texto
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController barrioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController razonSocialController = TextEditingController();
  final TextEditingController rucController = TextEditingController();
  final TextEditingController nombreUbicacionController =
      TextEditingController();
  final TextEditingController numeroCasaController = TextEditingController();
  final TextEditingController ciudadController = TextEditingController();
  final TextEditingController calleController = TextEditingController();
  final TextEditingController latitudController = TextEditingController();
  final TextEditingController longitudController = TextEditingController();

  void clearFormFields() {
    nameController.clear();
    lastNameController.clear();
    addressController.clear();
    cityController.clear();
    barrioController.clear();
    emailController.clear();
    phoneController.clear();
    razonSocialController.clear();
    rucController.clear();
  }

  @override
  void dispose() {
    // Libera los recursos de los controladores
    nameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    barrioController.dispose();
    emailController.dispose();
    phoneController.dispose();
    razonSocialController.dispose();
    rucController.dispose();
    super.dispose();
  }

  Future<void> sendOrder(BuildContext globalContext) async {
    try {
      final authProvider = Provider.of<local_auth.AuthProvider>(
        context,
        listen: false,
      );

      if (authProvider.userId == null) {
        ScaffoldMessenger.of(globalContext).showSnackBar(
          const SnackBar(
            content: Text("Error: No se pudo identificar al usuario"),
          ),
        );
        return;
      }

      final paymentProvider = Provider.of<PaymentProvider>(
        globalContext,
        listen: false,
      );

      final Map<String, dynamic> orderData = {
        'user_id': authProvider.userId, // Antes era 'customer_id'
        'payment_method': paymentProvider.selectedMethod,
        'shipping_cost': shippingCost.toStringAsFixed(0),
        'total': (widget.totalConDescuento + shippingCost).toInt(),
        'direccion': addressController.text,
        'ciudad': selectedCityId ?? '',
        'barrio': barrioController.text,
        'tel': phoneController.text,
        'razonsocial': razonSocialController.text,
        'ruc': rucController.text,
        'ubicacion_id': selectedUbicacion,
        'productos':
            widget.cartItems.map((item) {
              return {'product_id': item.id, 'quantity': item.quantity};
            }).toList(),
        'ubicacion':
            selectedUbicacion != null
                ? {
                  'nombre_ubicacion': nombreUbicacionController.text,
                  'numero_casa': numeroCasaController.text,
                  'ciudad': ciudadController.text,
                  'nombre_calle': calleController.text,
                  'latitud': latitudController.text,
                  'longitud': longitudController.text,
                }
                : null,
      };
      // print('ORDERDATA : ');
      // print(jsonEncode(orderData)); // Verifica que se genera correctamente
      // print("Ciudad antes de enviar: $selectedCityId");

      final response = await http.post(
        Uri.parse("https://farma.staweno.com/insert_order.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          // Vaciar el carrito
          Provider.of<CartProvider>(globalContext, listen: false).clearCart();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pedido enviado exitosamente")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error del servidor: ${responseData['message']}"),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error al enviar el pedido: Código ${response.statusCode}",
            ),
          ),
        );
      }

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(globalContext).showSnackBar(
          const SnackBar(content: Text("Pedido enviado exitosamente")),
        );

        // Redirigir después de 2 segundos
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushAndRemoveUntil(
            globalContext,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
            (route) => false,
          );
        });
      } else {
        ScaffoldMessenger.of(globalContext).showSnackBar(
          SnackBar(
            content: Text("Error al enviar el pedido: ${response.body}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        globalContext,
      ).showSnackBar(SnackBar(content: Text("Error inesperado: $e")));
    }
  }

  dynamic _obtenerUbicaciones;
  List<UbicacionModel> ubicaciones = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _obtenerUbicaciones = obtenerUbicaciones();

    // Llamar a la función para extraer los datos
    actualizarUbicacionSeleccionada();

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isLoading = false; // Indica que los datos ya se cargaron
      });
    });
    subtotal = widget.cartItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );

    // if (widget.freeShipping == 1) {
    //   shippingCost = 0;
    // } else {
    //   shippingCost;
    // }

    shippingCost;
    total = subtotal + shippingCost;
    ciudadSelect;
    // Inicialización correcta
  }

  // CARGAR DATOS DEL USUARIO
  void _cargarDatosUsuario() async {
    UsuarioModel? usuario = await obtenerUsuarioDesdeMySQL();
    if (usuario != null) {
      setState(() {
        nameController.text =
            usuario.name.isNotEmpty ? usuario.name : "Nombre no disponible";
        lastNameController.text =
            usuario.lastName.isNotEmpty
                ? usuario.lastName
                : "Apellido no disponible";
        emailController.text =
            usuario.email.isNotEmpty ? usuario.email : "Email no disponible";
        phoneController.text =
            usuario.phone.isNotEmpty ? usuario.phone : "Teléfono no disponible";
        // addressController.text =
        //     callePrincipal.isNotEmpty
        //         ? usuario.address
        //         : "Address no disponible";

        addressController.text = usuario.address;

        barrioController.text =
            usuario.barrio.isNotEmpty ? usuario.barrio : "Barrio no disponible";
        razonSocialController.text =
            usuario.razonsocial.isNotEmpty
                ? usuario.razonsocial
                : "RazonS no disponible";
        rucController.text =
            usuario.ruc.isNotEmpty ? usuario.ruc : "R.U.C no disponible";
      });
    } else {
      print("Error: No se pudo obtener los datos del usuario.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final userId =
        Provider.of<local_auth.AuthProvider>(context, listen: false).userId;

    var outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
    );

    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.blueLight,
      appBar: AppBar(
        backgroundColor: AppColors.blueLight,
        surfaceTintColor: Colors.transparent,
        title: const Text('Detalles del pedido'),
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
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // DATOS BASICO DEL USUARIO
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Datos del usuario",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isLoading ||
                                nameController.text.isEmpty ||
                                lastNameController.text.isEmpty
                            ? Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Row(
                                children: [
                                  const Icon(Icons.person),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 100, // Ancho de placeholder
                                    height: 20, // Alto de placeholder
                                    color:
                                        Colors
                                            .grey, // Placeholder para el texto
                                  ),
                                ],
                              ),
                            )
                            : Row(
                              children: [
                                const Icon(Icons.person),
                                const SizedBox(width: 10),
                                Text(
                                  '${nameController.text} ${lastNameController.text}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                        const SizedBox(height: 10), // Espaciado entre filas
                        // Segundo Row
                        isLoading ||
                                emailController.text.isEmpty ||
                                phoneController.text.isEmpty
                            ? Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Row(
                                children: [
                                  const Icon(Icons.email),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 100,
                                    height: 20,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 20),
                                  const Icon(Icons.phone),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 100,
                                    height: 20,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            )
                            : Row(
                              children: [
                                const Icon(Icons.email),
                                const SizedBox(width: 10),
                                Text(
                                  emailController.text,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                      ],
                    ),
                  ],
                ),

                Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Campos existentes
                      const SizedBox(height: 10),

                      userId == null
                          ? Column(
                            children: [
                              // NOMBRE
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Nombre',
                                  prefixIcon: const Icon(Icons.person),
                                  border: outlineInputBorder,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa tu nombre';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // APELLIDO
                              TextFormField(
                                controller: lastNameController,
                                decoration: InputDecoration(
                                  labelText: 'Apellido',
                                  prefixIcon: const Icon(Icons.person),
                                  border: outlineInputBorder,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa tu apellido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    "Datos de Contacto",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email),
                                  border: outlineInputBorder,
                                ),

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa tu email';
                                  } else if (!RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+',
                                  ).hasMatch(value)) {
                                    return 'Por favor ingresa un email válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Teléfono',
                                  prefixIcon: const Icon(Icons.phone),
                                  border: outlineInputBorder,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa tu teléfono';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          )
                          : const Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Dirección de envío ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                      FutureBuilder<List<UbicacionModel>>(
                        future: _obtenerUbicaciones,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (snapshot.hasData) {
                            ubicaciones = snapshot.data!;
                            return buildDropdown();
                          } else {
                            return const Center(
                              child: Text('No hay ubicaciones disponibles'),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.grayLight,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const AddAddressScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Agregar dirección',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible:
                            selectedUbicacion == null ||
                            !tieneUbicacionesGuardadas,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            // Dropdown para seleccionar la ciudad/localidad
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.location_city),
                                border: outlineInputBorder,
                                labelText: 'Seleccione una Localidad / Ciudad',
                              ),
                              value:
                                  selectedLocation != null
                                      ? ciudadSelect
                                      : selectedCityId,
                              items:
                                  cities.map((city) {
                                    return DropdownMenuItem<String>(
                                      value: city['name'], // ID de la ciudad
                                      child: Text(
                                        city['name']!,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCityId = value;
                                  // Buscar el costo de envío de la ciudad seleccionada
                                  var selectedCity = cities.firstWhere(
                                    (city) => city['name'] == value,
                                  );

                                  shippingCost =
                                      widget.freeShipping == 1
                                          ? 0
                                          : int.parse(
                                            selectedCity['costoEnvio']!,
                                          );
                                });
                              },
                              validator: (value) {
                                // Si hay una ubicación seleccionada, no es obligatorio
                                if (selectedLocation != null) {
                                  return null;
                                }

                                // Validación estándar si no hay ubicación seleccionada
                                if (value == null || value.isEmpty) {
                                  return 'Por favor selecciona una ciudad';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Campo para dirección
                            TextFormField(
                              controller: addressController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.place),
                                border: outlineInputBorder,
                                labelText:
                                    'Nombre de la calle y número de casa',
                              ),
                              validator: (value) {
                                // Si hay una ubicación seleccionada, este campo no es obligatorio
                                if (selectedUbicacion != null) {
                                  return null;
                                }

                                // Validación estándar
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu dirección';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Campo para barrio
                            TextFormField(
                              controller: barrioController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.map),
                                border: outlineInputBorder,
                                labelText: 'Barrio',
                              ),
                              validator: (value) {
                                // Si hay una ubicación seleccionada, este campo no es obligatorio
                                if (selectedUbicacion != null) {
                                  return null;
                                }

                                // Validación estándar
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu Barrio ';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      // NUMERO DE CONTACTO
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Número de Contacto",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          prefixIcon: const Icon(Icons.phone),
                          border: outlineInputBorder,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu teléfono';
                          }
                          return null;
                        },
                      ),

                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Datos de Facturación",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Nuevos campos para facturación
                      TextFormField(
                        controller: razonSocialController,
                        decoration: InputDecoration(
                          labelText: 'Razón Social',
                          prefixIcon: const Icon(Icons.person_pin_rounded),
                          border: outlineInputBorder,
                        ),
                        validator: (value) {
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: rucController,
                        decoration: InputDecoration(
                          labelText: 'RUC/Cédula',
                          prefixIcon: const Icon(Icons.info),
                          border: outlineInputBorder,
                        ),
                        validator: (value) {
                          // Este campo tampoco es obligatorio
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Metodo de Pago",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // SELECTOR DE METODO DE PAGO
                const SelectMetodPay(),

                // Resumen de Costo
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Resumen de costos ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: const Border(
                      top: BorderSide(color: Colors.grey, width: 1),
                      bottom: BorderSide(color: Colors.grey, width: 3),
                    ),
                  ),
                  // RESUMEN DEL CARRITO
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Subtotal:",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "₲. ${numberFormat(widget.totalConDescuento.toStringAsFixed(0))}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Envío:", style: TextStyle(fontSize: 16)),
                          Text(
                            "₲. ${numberFormat(shippingCost.toStringAsFixed(0))}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "₲. ${numberFormat((widget.totalConDescuento + shippingCost).toStringAsFixed(0))}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueDark,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () async {
                          final authProvider =
                              Provider.of<local_auth.AuthProvider>(
                                context,
                                listen: false,
                              );
                          final clienteId =
                              Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              ).userId;
                          if (clienteId == null) {
                            return;
                          }
                          // ASIGNAR CUPON AL CLIENTE
                          if (paymentProvider.selectedMethod == "Pago Online" &&
                              widget.cuponesSeleccionados.isNotEmpty &&
                              authProvider.userId != null) {
                            if (subtotal >= widget.montoMinimoCupon) {
                              int totalAsignados = 0;
                              for (
                                int i = 0;
                                i < widget.cuponesParaGenerar;
                                i++
                              ) {
                                await asignarCuponParaCliente(
                                  clienteId,
                                  widget.cuponesSeleccionados.first,
                                );
                                totalAsignados++;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '🎉 Se asignaron $totalAsignados cupones al cliente',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            } else {
                              // 🚫 No se cumple el mínimo
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '⚠️ La compra debe superar ₲${widget.montoMinimoCupon.toInt()} para recibir cupones',
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }

                          // VALIDAR METODO DE PAGO
                          if (paymentProvider.selectedMethod == "/" ||
                              paymentProvider.selectedMethod.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                // validadcion de metodo de pago
                                content: Text(
                                  "Por favor seleccioná un método de pago",
                                ),
                              ),
                            );
                            return; // Evita que continúe si no hay método
                          }

                          if (formKey.currentState!.validate() &&
                              (selectedCityId != null ||
                                  selectedUbicacion != null)) {
                            await sendOrder(context);

                            // DESCONTAR CUPON UTILIZADO
                            // if (widget.cuponSeleccionado != null) {
                            await http.post(
                              Uri.parse(
                                'https://farma.staweno.com/cupones/marcar_cupon_utilizado.php',
                              ),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'cliente_cupon_id': widget.cuponSeleccionado,
                              }),
                            );
                            // }

                            // Vacía el formulario después de enviar el pedido
                            clearFormFields();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Por favor completa los campos requeridos antes de enviar el pedido",
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Enviar Pedido',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.white,
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
    );
  }

  void actualizarUbicacionSeleccionada() {
    if (selectedUbicacion != null) {
      var ubicacionSeleccionada = ubicaciones.firstWhere(
        (ubicacion) => ubicacion.id.toString() == selectedUbicacion,
        orElse:
            () => UbicacionModel(
              id: -1,
              nombreUbicacion: '',
              numeracion: '',
              ciudad: '',
              callePrincipal: '',
              latitud: 0.0,
              longitud: 0.0,
              costo: 0,
              userId: 0,
            ),
      );

      if (ubicacionSeleccionada.id != -1) {
        setState(() {
          nombreUbicacionController.text =
              ubicacionSeleccionada.nombreUbicacion;
          numeroCasaController.text = ubicacionSeleccionada.numeracion;
          ciudadController.text = ubicacionSeleccionada.ciudad.toString();
          calleController.text = ubicacionSeleccionada.callePrincipal;
          latitudController.text = ubicacionSeleccionada.latitud.toString();
          longitudController.text = ubicacionSeleccionada.longitud.toString();
          shippingCost =
              widget.freeShipping == 1 ? 0 : ubicacionSeleccionada.costo;
        });

        print(
          "Ubicación actualizada: ${ubicacionSeleccionada.nombreUbicacion}",
        );
      }
    }
  }

  Widget buildDropdown() {
    final outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
    );
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value:
                selectedUbicacion, // Asigna la opción seleccionada al Dropdown
            decoration: InputDecoration(
              labelText: 'Ubicaciones guardadas',
              border: outlineInputBorder,
            ),
            items:
                ubicaciones.map((ubicacion) {
                  return DropdownMenuItem<String>(
                    value: ubicacion.id.toString(),
                    child: Text(ubicacion.nombreUbicacion),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                selectedUbicacion = value;

                var ubicacionSeleccionada = ubicaciones.firstWhere(
                  (ubicacion) => ubicacion.id.toString() == selectedUbicacion,
                  orElse:
                      () => UbicacionModel(
                        id: -1,
                        nombreUbicacion: '',
                        numeracion: '',
                        ciudad: '',
                        callePrincipal: '',
                        latitud: 0.0,
                        longitud: 0.0,
                        costo: 0,
                        userId: 0,
                      ),
                );

                if (ubicacionSeleccionada.id != -1) {
                  ciudadSelect = ubicacionSeleccionada.ciudad.toString();
                  addressController.text =
                      ubicacionSeleccionada.callePrincipal.toString();
                  barrioController.text = "Sin especificar";
                }

                print('Ubicación ID: $selectedUbicacion');
                actualizarUbicacionSeleccionada(); //  Ahora ejecutamos la función separada
              });
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            color: Color.fromARGB(255, 203, 53, 56),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.clear,
              color: Colors.white,
              size: 24,
            ), // Ícono de "X"
            onPressed: () {
              setState(() {
                selectedUbicacion = null; // Limpiar selección
              });
            },
          ),
        ),
      ],
    );
  }
}
