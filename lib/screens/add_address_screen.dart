import 'package:babyaid/model/colors.dart';
import 'package:babyaid/model/mapa_city.dart';
import 'package:babyaid/model/usuario_model.dart';
import 'package:babyaid/screens/mapaScreen.dart';
import 'package:babyaid/services/perfil_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  AddAddressScreenState createState() => AddAddressScreenState();
}

class AddAddressScreenState extends State<AddAddressScreen> {
  final _nombreUbicacionController = TextEditingController();
  final _numeracionController = TextEditingController();
  final _calleController = TextEditingController();
  final _calleSecundariaController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _phoneController = TextEditingController();
  String tel = '';

  String? ciudadSeleccionada;
  double? latitud;
  double? longitud;

  final PerfilService _perfilService = PerfilService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text("Agregar direcciones"),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                //Nombre de la Ubicación
                TextFormField(
                  controller: _nombreUbicacionController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de Ubicación',
                    prefixIcon: const Icon(
                      Iconsax.house_copy,
                    ), // Icono a la izquierda
                    border: OutlineInputBorder(
                      // Borde para un aspecto más definido
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ), // Bordes redondeados
                    ),
                  ),
                ),

                // Selector de Ciudad
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Ciudad',
                    border: OutlineInputBorder(
                      // Agregamos un borde
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.blueGrey),
                    ),
                    prefixIcon: const Icon(Iconsax.building_copy), //
                  ),
                  value: ciudadSeleccionada,
                  items:
                      cities.map((ciudad) {
                        return DropdownMenuItem<String>(
                          value: ciudad['name'],
                          child: Text(ciudad['name']!),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      ciudadSeleccionada = value;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Campo de Calle principal
                TextFormField(
                  controller: _calleController,
                  decoration: InputDecoration(
                    labelText: 'Calle principal',
                    prefixIcon: const Icon(
                      Iconsax.map_copy,
                    ), // Icono a la izquierda
                    border: OutlineInputBorder(
                      // Borde para un aspecto más definido
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ), // Bordes redondeados
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Campo de Calle secundaria
                TextFormField(
                  controller: _calleSecundariaController,
                  decoration: InputDecoration(
                    labelText: 'Calle secundaria',
                    prefixIcon: const Icon(
                      Iconsax.map_1_copy,
                    ), // Icono a la izquierda
                    border: OutlineInputBorder(
                      // Borde para un aspecto más definido
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ), // Bordes redondeados
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Campo de Numeración
                TextFormField(
                  controller: _numeracionController,
                  decoration: InputDecoration(
                    labelText: 'Número de Casa o Dpto.',
                    prefixIcon: const Icon(
                      Iconsax.route_square_copy,
                    ), // Icono a la izquierda
                    border: OutlineInputBorder(
                      // Borde para un aspecto más definido
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                // Referencia
                TextFormField(
                  controller: _referenciaController,
                  decoration: InputDecoration(
                    labelText: 'Referencia',
                    prefixIcon: const Icon(
                      Icons.room_outlined,
                    ), // Icono a la izquierda
                    border: OutlineInputBorder(
                      // Borde para un aspecto más definido
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ), // Bordes redondeados
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Número de Telefono',
                    prefixIcon: const Icon(Icons.phone_android_rounded),
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
                    tel = value!;
                  },
                ),

                const SizedBox(height: 20),

                // Botón para Ubicar en Mapa
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenDark,
                        ),
                        onPressed: () {
                          if (ciudadSeleccionada != null &&
                              _calleController.text.isNotEmpty) {
                            final direccion =
                                '$ciudadSeleccionada, ${_calleController.text}';
                            _mostrarMapa(context, direccion);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Por favor completa los campos'),
                              ),
                            );
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Ubicar en Mapa',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Botón para Guardar Ubicación
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                        ),
                        onPressed: () async {
                          if (_validarCampos()) {
                            try {
                              // En tu archivo add_address_screen.dart, dentro de onPressed:
                              final nuevaUbicacion = UbicacionModel(
                                id: 0,
                                nombreUbicacion:
                                    _nombreUbicacionController.text,
                                callePrincipal: _calleController.text,
                                numeracion: _numeracionController.text,

                                calleSecundaria:
                                    _calleSecundariaController.text,
                                referencia: _referenciaController.text,
                                tel: _phoneController.text,

                                ciudad: ciudadSeleccionada,
                                latitud: latitud ?? 0.0,
                                longitud: longitud ?? 0.0,
                                userId: 0,
                              );

                              bool guardado = await _perfilService
                                  .crearUbicacion(nuevaUbicacion);

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    guardado
                                        ? "Ubicación guardada exitosamente."
                                        : "Error al guardar la ubicación.",
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );

                              if (guardado) {
                                // Al regresar a la pantalla anterior, pasamos 'true'
                                // para indicarle que debe refrescar la lista.
                                Navigator.pop(context, true);
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Text(
                            'Guardar dirección',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validarCampos() {
    if (ciudadSeleccionada == null ||
        _calleController.text.isEmpty ||
        _nombreUbicacionController.text.isEmpty ||
        _numeracionController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        latitud == null ||
        longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return false;
    }
    return true;
  }

  void limpiarFormulario() {
    setState(() {
      ciudadSeleccionada = null;
      _calleController.clear();
      _nombreUbicacionController.clear();
      _numeracionController.clear();
      latitud = null;
      longitud = null;
    });
  }

  void _mostrarMapa(BuildContext context, String direccion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que la ventana ocupe más espacio
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9, // Ocupa el 90% de la pantalla
          minChildSize: 0.5, // El mínimo que puede ocupar (50%)
          maxChildSize: 1.0, // Ocupa toda la pantalla si es necesario
          builder: (context, scrollController) {
            return MapaScreen(
              direccion: direccion,
              onUbicacionConfirmada: (ubicacionConfirmada) {
                setState(() {
                  ciudadSeleccionada = ubicacionConfirmada['ciudad'];
                  _calleController.text = ubicacionConfirmada['calle'];
                  latitud = ubicacionConfirmada['latitud'];
                  longitud = ubicacionConfirmada['longitud'];
                });
              },
            );
          },
        );
      },
    );
  }
}
