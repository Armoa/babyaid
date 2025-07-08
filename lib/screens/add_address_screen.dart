import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/mapa_city.dart';
import 'package:helfer/model/usuario_model.dart';
import 'package:helfer/screens/address_screen.dart';
import 'package:helfer/screens/mapaScreen.dart';
import 'package:helfer/services/obtener_usuario.dart';
import 'package:helfer/services/perfil_service.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  AddAddressScreenState createState() => AddAddressScreenState();
}

class AddAddressScreenState extends State<AddAddressScreen> {
  final _nombreUbicacionController = TextEditingController();
  final _numeracionController = TextEditingController();
  String? ciudadSeleccionada;
  final _calleController = TextEditingController();
  double? latitud;
  double? longitud;
  int shippingCost = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueAcua,
      appBar: AppBar(
        backgroundColor: AppColors.blueAcua,
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
                      Icons.person_2_outlined,
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
                      Icons.home_outlined,
                    ), // Icono a la izquierda
                    border: OutlineInputBorder(
                      // Borde para un aspecto más definido
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),

                // Selector de Ciudad
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Ciudad',
                    border: OutlineInputBorder(
                      // Agregamos un borde
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.blueGrey),
                    ),
                    prefixIcon: const Icon(Icons.location_city), //
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

                      // Buscar el costo de envío de la ciudad seleccionada
                      var selectedCity = cities.firstWhere(
                        (ciudad) => ciudad['name'] == value,
                      );
                      shippingCost = int.parse(selectedCity['costoEnvio']!);
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Campo de Calle principal y numero
                TextFormField(
                  controller: _calleController,
                  decoration: InputDecoration(
                    labelText: 'Calle principal y numero ',
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
                const SizedBox(height: 20),

                // Botón para Ubicar en Mapa
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.grayLight,
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
                          backgroundColor: AppColors.blueDark,
                        ),
                        onPressed: () async {
                          if (_validarCampos()) {
                            try {
                              UsuarioModel? usuario =
                                  await obtenerUsuarioDesdeMySQL();
                              int? userId = usuario?.id;

                              // Crear modelo `UbicacionModel` antes de enviarlo
                              final nuevaUbicacion = UbicacionModel(
                                id: 0, // La DB asignará el ID automáticamente
                                nombreUbicacion:
                                    _nombreUbicacionController.text,
                                callePrincipal: _calleController.text,
                                numeracion: _numeracionController.text,
                                ciudad: ciudadSeleccionada,
                                costo: shippingCost, // Asegurar que es int
                                latitud:
                                    double.tryParse(latitud.toString()) ?? 0.0,
                                longitud:
                                    double.tryParse(longitud.toString()) ?? 0.0,
                                userId: userId ?? 0,
                              );

                              bool guardado = await PerfilService()
                                  .crearUbicacion(nuevaUbicacion);

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
                                _limpiarFormulario();
                                setState(() {});
                                Navigator.pushReplacement(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddressScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              // ignore: use_build_context_synchronously
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
        latitud == null ||
        longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return false;
    }
    return true;
  }

  void _limpiarFormulario() {
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
