import 'dart:convert';

import 'package:bebito/model/colors.dart';
import 'package:bebito/model/personal_model.dart';
import 'package:bebito/model/solicitud_servicio_model.dart';
import 'package:bebito/model/usuario_model.dart';
import 'package:bebito/provider/auth_provider.dart' as local_auth;
import 'package:bebito/provider/auth_provider.dart';
import 'package:bebito/provider/payment_provider.dart';
import 'package:bebito/screens/home.dart';
import 'package:bebito/services/functions.dart';
import 'package:bebito/widget/select_metod_pay.dart';
import 'package:bebito/widget/title_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PagoFacturacion extends StatefulWidget {
  final SolicitudServicioModel solicitud;
  final PersonalModel personal;

  const PagoFacturacion({
    required this.solicitud,
    required this.personal,
    super.key,
  });

  @override
  State<PagoFacturacion> createState() => _PagoFacturacionState();
}

// COSTO DE SERVICOS POR HORA
int calcularPrecioServicio(int horas) {
  switch (horas) {
    case 4:
      return 155000;
    case 7:
      return 200000;
    case 9:
      return 230000;
    default:
      throw Exception("Cantidad de horas no válida: $horas");
  }
}

// FORMATO DE HORARIO
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }
}

class _PagoFacturacionState extends State<PagoFacturacion> {
  double costoTotal = 0;
  final TextEditingController razonSocialController = TextEditingController();
  final TextEditingController rucController = TextEditingController();
  final TextEditingController datoAdhicionalController =
      TextEditingController();

  void clearFormFields() {
    razonSocialController.clear();
    rucController.clear();
    datoAdhicionalController.clear();
  }

  @override
  void dispose() {
    // Libera los recursos de los controladores
    razonSocialController.dispose();
    rucController.dispose();
    datoAdhicionalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfilDesdeAuthProvider();
  }

  // DATOS DEL CLIENTE
  Future<void> _cargarDatosPerfilDesdeAuthProvider() async {
    await Provider.of<AuthProvider>(context, listen: false).loadUser();
  }

  // FUNCION DE ENVIO DE PEDIDO
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
        'user_id': authProvider.userId,
        'payment_method': paymentProvider.selectedMethod,
        'total': calcularPrecioServicio(widget.solicitud.duracionHoras),
        'razonsocial': razonSocialController.text,
        'ruc': rucController.text,
        'datoAdicional': datoAdhicionalController.text,
        'ubicacion_id': widget.solicitud.ubicacion.id,
        'personal': widget.personal.id,
        'horas': widget.solicitud.duracionHoras,
        'frecuencia': widget.solicitud.frecuencia,
        'fechaInicio': DateFormat('yyyy-MM-dd').format(widget.solicitud.fecha),
        'rangoHorario':
            '${widget.solicitud.rangoHorario.start.round()}:00 a ${widget.solicitud.rangoHorario.end.round()}:00',
      };

      final response = await http.post(
        Uri.parse("https://helfer.flatzi.com/app/insert_order.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(globalContext).showSnackBar(
            const SnackBar(content: Text("Pedido enviado exitosamente")),
          );

          Future.delayed(const Duration(seconds: 2), () {
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.of(globalContext).pushAndRemoveUntil(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 600),
                  pageBuilder: (_, __, ___) => const MyHomePage(),
                  transitionsBuilder: (_, animation, __, child) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    );

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0), // 👉 desde la derecha
                        end: Offset.zero,
                      ).animate(curved),
                      child: child,
                    );
                  },
                ),
                (route) => false,
              );
            });
          });
        } else {
          ScaffoldMessenger.of(globalContext).showSnackBar(
            SnackBar(
              content: Text("Error del servidor: ${responseData['message']}"),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(globalContext).showSnackBar(
          SnackBar(
            content: Text(
              "Error al enviar el pedido: Código ${response.statusCode}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        globalContext,
      ).showSnackBar(SnackBar(content: Text("Error inesperado: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtén la instancia del AuthProvider para acceder a los datos del usuario
    final authProvider = Provider.of<AuthProvider>(context);
    final UsuarioModel? user = authProvider.user;
    if (user != null) {
      setState(() {
        razonSocialController.text =
            user.razonsocial.isNotEmpty
                ? user.razonsocial
                : "Razons no disponible";
        rucController.text =
            user.ruc.isNotEmpty ? user.ruc : "R.U.C no disponible";
      });
    }

    final paymentProvider = Provider.of<PaymentProvider>(context);
    final costoTotal = calcularPrecioServicio(widget.solicitud.duracionHoras);

    var outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
    );

    return Scaffold(
      backgroundColor: AppColors.primario,
      appBar: AppBar(
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        leading: null,
        title: TitleAppbar(),
      ),

      // AppBar(
      //   automaticallyImplyLeading: false,
      //   leading: null,
      //   toolbarHeight: 120,
      //   title: Column(
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Padding(
      //             padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
      //             child: InkWell(
      //               onTap: () {
      //                 Navigator.pop(context);
      //               },
      //               child: Icon(Icons.arrow_back),
      //             ),
      //           ),
      //           Padding(
      //             padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
      //             child: Image.asset('assets/logo-blanco.png', scale: 2.5),
      //           ),
      //         ],
      //       ),
      //       SizedBox(height: 25),
      //       Text(
      //         "Finalizar pedido",
      //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      //       ),
      //       SizedBox(height: 25),
      //     ],
      //   ),

      //   backgroundColor: AppColors.primario,
      // ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? AppColors.black
                  : Colors.white,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Finalizar pedido",
                  style: GoogleFonts.quicksand(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(widget.personal.foto),
                          radius: 28,
                        ),
                        title: Text(
                          "${widget.personal.nombre} ${widget.personal.apellido}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 16,
                                  color:
                                      widget.personal.verificado == 1
                                          ? Colors.green
                                          : Colors.grey,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  widget.personal.verificado == 1
                                      ? 'Perfil Verificado'
                                      : 'Perfil sin verificar',
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Icon(Icons.home, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Servicios: ${widget.personal.antiguedad}',
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_outlined,
                                  size: 16,
                                  color: AppColors.primario,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${widget.personal.horaDesde.substring(0, 5)} a ${widget.personal.horaHasta.substring(0, 5)}',
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            Text(
                              widget.personal.calificacion.toStringAsFixed(1),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Metodo de Pago",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // SELECTOR DE METODO DE PAGO
                          const SelectMetodPay(),
                          const SizedBox(height: 20),
                          // Nuevos campos para facturación
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Datos de Facturacion",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
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
                          SizedBox(height: 20),

                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Datos adhicionales",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: datoAdhicionalController,
                            decoration: InputDecoration(
                              labelText: 'Tocar timbre, limpiar bien los...',
                              prefixIcon: const Icon(Icons.person_pin_rounded),
                              border: outlineInputBorder,
                            ),
                            validator: (value) {
                              return null;
                            },
                          ),

                          SizedBox(height: 30),

                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Resumen General",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),

                          Column(
                            children: [
                              DatoEnDosColumnas(
                                textoIzquierdo: "Horas:",
                                textoDerecho:
                                    '${widget.solicitud.duracionHoras}',
                                colorFondo: AppColors.primario,
                                fontSize: 14,
                              ),

                              DatoEnDosColumnas(
                                textoIzquierdo: "Frecuencia:",
                                textoDerecho: widget.solicitud.frecuencia,
                                colorFondo: Colors.white,
                                fontSize: 14,
                              ),

                              DatoEnDosColumnas(
                                textoIzquierdo: "Inicio:",
                                textoDerecho:
                                    DateFormat('EEEE d MMMM y', 'es_PY')
                                        .format(widget.solicitud.fecha)
                                        .toString()
                                        .capitalizeFirst(),
                                colorFondo: AppColors.primario,
                                fontSize: 12,
                              ),

                              DatoEnDosColumnas(
                                textoIzquierdo: "Horarios:",
                                textoDerecho:
                                    '${widget.solicitud.rangoHorario.start.round()}:00 a ${widget.solicitud.rangoHorario.end.round()}:00',
                                colorFondo: Colors.white,
                                fontSize: 14,
                              ),

                              DatoEnDosColumnas(
                                textoIzquierdo: "Ubicación:",
                                textoDerecho:
                                    widget.solicitud.ubicacion.nombreUbicacion,
                                colorFondo: AppColors.primario,
                                fontSize: 14,
                              ),

                              DatoEnDosColumnas(
                                textoIzquierdo: "Costo diario:",
                                textoDerecho:
                                    '₲. ${numberFormat(costoTotal.toStringAsFixed(0))}',
                                colorFondo: Colors.white,
                                fontSize: 14,
                              ),

                              Container(
                                color: Color.fromARGB(255, 182, 208, 231),

                                child: DatoEnDosColumnas(
                                  textoIzquierdo: "Total + IVA:",
                                  textoDerecho:
                                      '₲. ${numberFormat(costoTotal.toStringAsFixed(0))}',
                                  colorFondo: Colors.transparent,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 30),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primario,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final clienteId =
                                        Provider.of<AuthProvider>(
                                          context,
                                          listen: false,
                                        ).userId;
                                    if (clienteId == null) {
                                      return;
                                    }
                                    // VALIDAR METODO DE PAGO
                                    if (paymentProvider.selectedMethod == "/" ||
                                        paymentProvider
                                            .selectedMethod
                                            .isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          // validadcion de metodo de pago
                                          content: Text(
                                            "Por favor seleccioná un método de pago",
                                          ),
                                        ),
                                      );
                                      return; // Evita que continúe si no hay método
                                    }

                                    sendOrder(context);
                                    // Vacía el formulario después de enviar el pedido
                                    clearFormFields();
                                  },
                                  child: const Text(
                                    'Enviar Pedido',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // BOTONERA INFERIOR
          ],
        ),
      ),
    );
  }
}

class DatoEnDosColumnas extends StatelessWidget {
  final String textoIzquierdo;
  final String textoDerecho;
  final Color colorFondo;
  final int fontSize;

  const DatoEnDosColumnas({
    super.key,
    required this.textoIzquierdo,
    required this.textoDerecho,
    required this.colorFondo,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorFondo,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                textoIzquierdo,
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                textoDerecho,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: fontSize.toDouble()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
