import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/personal_model.dart';
import 'package:helfer/model/solicitud_servicio_model.dart';
import 'package:helfer/provider/auth_provider.dart' as local_auth;
import 'package:helfer/provider/auth_provider.dart';
import 'package:helfer/provider/payment_provider.dart';
import 'package:helfer/screens/home.dart';
import 'package:helfer/services/functions.dart';
import 'package:helfer/widget/select_metod_pay.dart';
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
        'user_id': authProvider.userId, // Antes era 'customer_id'
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

      print(jsonEncode('ORDERDATA: $orderData'));

      final response = await http.post(
        Uri.parse("https://helfer.flatzi.com/app/insert_order.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          // Vaciar el carrito

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

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final costoTotal = calcularPrecioServicio(widget.solicitud.duracionHoras);

    var outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
    );

    return Scaffold(
      backgroundColor: AppColors.blueDark,
      appBar: AppBar(
        leading: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        title: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Pago y Facturacion",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                child: Image.asset('assets/logo-blanco.png', scale: 4),
              ),
            ],
          ),
        ],

        backgroundColor: AppColors.blueDark,
        toolbarHeight: 120,
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? AppColors.blueBlak
                  : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            children: [
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
                            "${widget.personal.nombre} ${widget.personal.apellido} ",
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
                                    color: AppColors.blueDark,
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
                        padding: EdgeInsets.fromLTRB(20, 20, 10, 10),
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
                            const SizedBox(height: 10),
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
                            TextFormField(
                              controller: razonSocialController,
                              decoration: InputDecoration(
                                labelText: 'Razón Social',
                                prefixIcon: const Icon(
                                  Icons.person_pin_rounded,
                                ),
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
                            TextFormField(
                              controller: datoAdhicionalController,
                              decoration: InputDecoration(
                                labelText: 'Tocar timbre, limpiar bien los...',
                                prefixIcon: const Icon(
                                  Icons.person_pin_rounded,
                                ),
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
                                "Resumen general",
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
                                  textoIzquierdo: "Horas de servicio:",
                                  textoDerecho:
                                      '${widget.solicitud.duracionHoras}',
                                  colorFondo: AppColors.grayLight,
                                ),

                                DatoEnDosColumnas(
                                  textoIzquierdo: "Frecuencia:",
                                  textoDerecho: widget.solicitud.frecuencia,
                                  colorFondo: AppColors.white,
                                ),

                                DatoEnDosColumnas(
                                  textoIzquierdo: "Fecha de Inicio:",
                                  textoDerecho:
                                      DateFormat('EEEE d MMMM y', 'es_PY')
                                          .format(widget.solicitud.fecha)
                                          .toString()
                                          .capitalizeFirst(),
                                  colorFondo: AppColors.grayLight,
                                ),

                                DatoEnDosColumnas(
                                  textoIzquierdo: "Horarios:",
                                  textoDerecho:
                                      '${widget.solicitud.rangoHorario.start.round()}:00 a ${widget.solicitud.rangoHorario.end.round()}:00',
                                  colorFondo: AppColors.white,
                                ),

                                DatoEnDosColumnas(
                                  textoIzquierdo: "Ubicación:",
                                  textoDerecho:
                                      widget
                                          .solicitud
                                          .ubicacion
                                          .nombreUbicacion,
                                  colorFondo: AppColors.grayLight,
                                ),

                                DatoEnDosColumnas(
                                  textoIzquierdo: "Costo diario:",
                                  textoDerecho:
                                      '₲. ${numberFormat(costoTotal.toStringAsFixed(0))}',
                                  colorFondo: AppColors.white,
                                ),

                                Container(
                                  color: Color.fromARGB(255, 182, 208, 231),

                                  child: DatoEnDosColumnas(
                                    textoIzquierdo: "Total + IVA:",
                                    textoDerecho:
                                        '₲. ${numberFormat(costoTotal.toStringAsFixed(0))}',
                                    colorFondo: Colors.transparent,
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
                                      backgroundColor: AppColors.blueDark,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    onPressed: () async {
                                      print('Costo : $costoTotal ');
                                      // final authProvider =
                                      //     Provider.of<local_auth.AuthProvider>(
                                      //       context,
                                      //       listen: false,
                                      //     );
                                      final clienteId =
                                          Provider.of<AuthProvider>(
                                            context,
                                            listen: false,
                                          ).userId;
                                      if (clienteId == null) {
                                        return;
                                      }
                                      // VALIDAR METODO DE PAGO
                                      if (paymentProvider.selectedMethod ==
                                              "/" ||
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
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // BOTONERA INFERIOR
            ],
          ),
        ),
      ),
    );
  }
}

class DatoEnDosColumnas extends StatelessWidget {
  final String textoIzquierdo;
  final String textoDerecho;
  final Color colorFondo;

  const DatoEnDosColumnas({
    super.key,
    required this.textoIzquierdo,
    required this.textoDerecho,
    required this.colorFondo,
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
            Expanded(child: Text(textoDerecho, textAlign: TextAlign.end)),
          ],
        ),
      ),
    );
  }
}
