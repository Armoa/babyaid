import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helfer/model/card_model.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/cupon_model.dart';
import 'package:helfer/model/usuario_model.dart';
import 'package:helfer/provider/auth_provider.dart';
import 'package:helfer/provider/cart_provider.dart';
import 'package:helfer/provider/cupon_provider.dart';
import 'package:helfer/screens/login.dart';
import 'package:helfer/screens/order_confirmation_screen.dart';
import 'package:helfer/screens/perfil_screen.dart';
import 'package:helfer/services/functions.dart';
import 'package:helfer/services/obtener_usuario.dart';
import 'package:helfer/services/validar_cupon.dart';
import 'package:helfer/services/verificar_datos_faltantes.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final numeroFormat = NumberFormat("#,###", "es_PY");

class CartScreenView extends StatefulWidget {
  const CartScreenView({super.key});

  @override
  State<CartScreenView> createState() => _CartScreenViewState();
}

class _CartScreenViewState extends State<CartScreenView> {
  Map<String, dynamic>? cuponAplicado;
  double totalConDescuento = 0;
  double totalOriginal = 0;

  List<CuponDisponible> cuponesDelCliente = [];
  CuponDisponible? cuponSeleccionado;

  Future<void> cargarCupones() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    final response = await http.post(
      Uri.parse(
        'https://helfer.flatzi.com/app/cupones/cupones_acumulados_cliente.php',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cliente_id': userId}),
    );

    final data = jsonDecode(response.body);
    // print('🧾 Cupones recibidos: ${jsonEncode(data)}');
    if (data['success'] == true) {
      setState(() {
        cuponesDelCliente =
            (data['cupones'] as List)
                .map((c) => CuponDisponible.fromJson(c))
                .toList();
      });
    } else {
      print('Error: ${data['mensaje']}');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      verificarPerfilUsuario(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    calcularTotalOriginal();
    print('🔄 Ejecutando cargarCupones()');
    cargarCupones();
  }

  void calcularTotalOriginal() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final List<CartItem> cartItems = cartProvider.cartItems;
    totalOriginal = cartItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );
    totalConDescuento = totalOriginal;
  }

  Future<void> verificarPerfilUsuario(BuildContext context) async {
    UsuarioModel? usuario = await obtenerUsuarioDesdeMySQL();
    if (usuario == null) return;
    List<String> datosFaltantes = verificarDatosFaltantes(usuario);
    if (datosFaltantes.isNotEmpty) {
      mostrarPopup(context, datosFaltantes);
    }
  }

  void mostrarPopup(BuildContext context, List<String> datosFaltantes) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Actualiza tu perfil"),
          content: Text("Falta completar: ${datosFaltantes.join(", ")}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cerrar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: Text("Actualizar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context);
    final List<CartItem> cartItems = cartProvider.cartItems;
    final subtotal = cartItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity, // Ya es un double
    );
    // const shippingCost = 0; // Costo de envío fijo
    // final total = subtotal + shippingCost;

    final cuponProvider = Provider.of<CuponProvider>(context, listen: false);
    int cuponesParaGenerar = 0;

    for (final item in cartItems) {
      if (cuponProvider.productoTieneCupon(item.id)) {
        cuponesParaGenerar += item.quantity;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Mi Carrito")),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child:
            cartItems.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sentiment_very_dissatisfied,
                        size: 90,
                        color: Colors.blueGrey,
                      ),
                      Text(
                        "¡Tu carrito está vacío!",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )
                : Column(
                  children: [
                    // Lista de productos en el carrito
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final CartItem item = cartItems[index];
                          final cuponProvider = Provider.of<CuponProvider>(
                            context,
                          );
                          final cupon = cuponProvider.obtenerCuponDeProducto(
                            item.id,
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  // Imagen del producto con bordes redondeados
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      item.image,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Información del producto
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "₲ ${numeroFormat.format(item.price)}",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: AppColors.blueDark,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            if (cupon != null)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                      0,
                                                      0,
                                                      10,
                                                      0,
                                                    ),
                                                child: SizedBox(
                                                  width: 40,
                                                  child: Image.asset(
                                                    'assets/cupon.png',
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Botones para modificar la cantidad
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Color del fondo
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromARGB(30, 0, 0, 0),
                                          spreadRadius: 1,
                                          blurRadius: 4, // Difuminado
                                          offset: Offset(
                                            2,
                                            2,
                                          ), // Desplazamiento (horizontal, vertical)
                                        ),
                                      ],
                                    ),

                                    child: Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.add, size: 18),
                                          onPressed: () {
                                            cartProvider.addToCart(item, 1);
                                          },
                                        ),
                                        Text(
                                          "${item.quantity}",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            item.quantity > 1
                                                ? Icons.remove
                                                : Icons.delete,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            if (item.quantity > 1) {
                                              cartProvider.addToCart(item, -1);
                                            } else {
                                              cartProvider.removeFromCart(
                                                item.id,
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Resumen del carrito
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppColors.blueBlak
                                : const Color.fromARGB(255, 248, 248, 248),

                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        border: const Border(
                          top: BorderSide(
                            color: Color.fromARGB(255, 201, 201, 201),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          if (cuponesDelCliente.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.card_giftcard,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<CuponDisponible>(
                                        value: cuponSeleccionado,
                                        hint: const Text(
                                          'Elegí un cupón para aplicar',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        isExpanded: true,
                                        icon: const Icon(Icons.arrow_drop_down),
                                        items:
                                            cuponesDelCliente.map((cupon) {
                                              return DropdownMenuItem(
                                                value: cupon,
                                                child: Text(
                                                  '${cupon.description} | ${cupon.code} ',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (cuponElegido) {
                                          if (cuponElegido != null) {
                                            final descuento = calcularDescuento(
                                              cupon: {
                                                'type': cuponElegido.type,
                                                'amount': cuponElegido.amount,
                                              },
                                              total: totalOriginal,
                                              cartItems: cartProvider.cartItems,
                                              context: context,
                                            );

                                            setState(() {
                                              cuponSeleccionado = cuponElegido;
                                              totalConDescuento =
                                                  totalOriginal - descuento;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),
                                  if (cuponSeleccionado != null)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          cuponSeleccionado = null;
                                          totalConDescuento = totalOriginal;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(
                                          Icons.close,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Subtotal:",
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                "₲${numberFormat(subtotal.toStringAsFixed(0).toString())}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (cuponSeleccionado != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Descuento aplicado:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "- ₲${numberFormat((totalOriginal - totalConDescuento).toStringAsFixed(0))}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              (cuponSeleccionado != null)
                                  ? Text(
                                    "Total con descuento:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[900],
                                    ),
                                  )
                                  : Text(
                                    "Total:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[900],
                                    ),
                                  ),

                              Text(
                                "₲. ${numberFormat(totalConDescuento.toStringAsFixed(0).toString())}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[900],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Botón para finalizar compra
                    Container(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.blueBlak
                              : Colors.white,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 40),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : AppColors.blueDark,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () {
                            if (!authProvider.isAuthenticated) {
                              // Mostrar mensaje con ScaffoldMessenger
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Para enviar el pedido debes iniciar sesión',
                                  ),
                                  duration: Duration(
                                    seconds: 2,
                                  ), // Duración del mensaje
                                ),
                              );

                              // Navegar a la pantalla de inicio de sesión
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // ignore: prefer_const_constructors
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            } else {
                              // Usuario logueado, proceder con la navegación
                              final cuponProvider = Provider.of<CuponProvider>(
                                context,
                                listen: false,
                              );

                              double? montoMinimoGlobal;
                              for (final item in cartItems) {
                                final cupon = cuponProvider
                                    .obtenerCuponDeProducto(item.id);
                                if (cupon != null && cupon.minimo != null) {
                                  if (montoMinimoGlobal == null ||
                                      cupon.minimo! < montoMinimoGlobal) {
                                    montoMinimoGlobal = cupon.minimo!;
                                  }
                                }
                                final double montoMinimo =
                                    montoMinimoGlobal ?? 0;

                                if (totalOriginal >= montoMinimo) {
                                  // ✅ Acreditar cupones
                                } else {
                                  // ❌ Mostrar advertencia al usuario
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '⚠️ La compra debe ser al menos ₲$montoMinimoGlobal para recibir cupones',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              }
                              // Recorremos los productos y obtenemos los cupones asociados
                              final cuponesSeleccionados =
                                  cartItems
                                      .map(
                                        (item) => cuponProvider
                                            .obtenerCuponDeProducto(item.id),
                                      )
                                      .where((cupon) => cupon != null)
                                      .map((cupon) => cupon!.id)
                                      .toSet()
                                      .toList();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => OrderConfirmationScreen(
                                        cartItems: cartItems,
                                        totalAmount: totalOriginal,
                                        totalConDescuento: totalConDescuento,
                                        cuponesParaGenerar: cuponesParaGenerar,
                                        cuponesSeleccionados:
                                            cuponesSeleccionados,
                                        freeShipping:
                                            cuponSeleccionado?.freeShipping ??
                                            0,
                                        cuponSeleccionado:
                                            cuponSeleccionado?.clienteCuponId ??
                                            0,
                                        montoMinimoCupon:
                                            montoMinimoGlobal ?? 0,
                                      ),
                                ),
                              );
                            }
                          },
                          iconAlignment: IconAlignment.end,
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.blueBlak
                                    : Colors.white,
                          ),

                          label: Text(
                            "Confirmar Pedido",
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.blueBlak
                                      : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
      ),
    );
  }
}
