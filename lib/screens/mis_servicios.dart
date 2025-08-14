import 'dart:convert';

import 'package:bebito/model/colors.dart';
import 'package:bebito/model/personal_model.dart';
import 'package:bebito/provider/auth_provider.dart' as local_auth_provider;
import 'package:bebito/provider/auth_provider.dart';
import 'package:bebito/provider/personal_provider.dart';
import 'package:bebito/screens/perfil_personal_screen2.dart';
import 'package:bebito/services/fetch_order_detalles.dart';
import 'package:bebito/services/functions.dart';
import 'package:bebito/services/get_calificacion.dart';
import 'package:bebito/widget/title_appbar.dart';
import 'package:bebito/widget/ventana_calificacion.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// FORMATO DE HORARIO
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }
}

class MisServicios extends StatefulWidget {
  const MisServicios({super.key});

  @override
  State<MisServicios> createState() => _MisServiciosState();
}

class _MisServiciosState extends State<MisServicios> {
  List<PersonalCalificado> lista = [];

  // Supongamos que tienes un método que obtiene PersonalModel por ID
  Future<PersonalModel?> fetchPersonalModel(int id) async {
    final url = Uri.parse(
      'https://helfer.flatzi.com/app/personal_datos.php?id=$id',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      if (jsonBody['success'] == true && jsonBody['data'] != null) {
        return PersonalModel.fromJson(jsonBody['data']);
      }
    }
    return null;
  }

  Map<int, double?> promedioPorPersonal = {};
  double? promedioCalificacion;

  Future<List<OrderDetalle>>? _orderDetallesFuture;
  int? _tileActivo;

  String _selectedStatus = 'agendado'; // Estado por defecto
  // Mapeo de estados internos a nombres de visualización para los botones
  final Map<String, String> _statusDisplayNames = {
    'agendado': 'Agendados',
    'activo': 'Activos',
    'finalizado': 'Finalizados',
    'cancelado': 'Cancelados',
    'recurrente': 'Recurrentes',
  };

  Map<String, Color> orderStatusColors = {
    'agendado': Colors.orange, // Pendiente
    'activo': Colors.teal, // En espera
    'finalizado': Colors.green, // Completado
    'cancelado': Colors.red, // Cancelado
    'recurrente': Colors.blue, // En proceso
  };
  Color getStatusColor(String status) {
    return orderStatusColors[status] ?? Colors.black; // Color predeterminado
  }

  late local_auth_provider.AuthProvider authProvider;
  int? userId;

  @override
  void initState() {
    super.initState();
    cargarPersonales();
    _setup();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});

      final personalProvider = Provider.of<PersonalProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<local_auth_provider.AuthProvider>(
        context,
        listen: false,
      );
      final int? usuarioId = authProvider.user?.id;
      if (usuarioId != null) {
        await personalProvider.obtenerUltimoServicioFinalizado(usuarioId);
      }
    });
  }

  // CARGA DE PERSONAL
  Future<void> cargarPersonales() async {
    final response = await http.get(
      Uri.parse('https://helfer.flatzi.com/app/get_ranking.php'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      setState(() {
        lista = data.map((e) => PersonalCalificado.fromJson(e)).toList();
      });
    }
  }

  void _setup() async {
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUser();
    final id = authProvider.user?.id;
    if (id != null) {
      setState(() {
        userId = id;
        _orderDetallesFuture = fetchOrderDetalles(id);
      });
    } else {
      print("El ID de usuario aún no está disponible");
    }
  }

  // funcion consultar siya fue calificado
  Future<bool> yaCalificado(int idReserva) async {
    final response = await http.get(
      Uri.parse(
        'https://helfer.flatzi.com/verificar_calificacion.php?id_reserva=$idReserva',
      ),
    );
    final data = jsonDecode(response.body);
    return data['success'] == true && data['calificado'] == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      appBar: AppBar(toolbarHeight: 100, title: TitleAppbar()),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FutureBuilder<List<OrderDetalle>>(
            future: _orderDetallesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else {
                final allDetalles = snapshot.data ?? [];
                final filteredDetalles =
                    allDetalles.where((detalle) {
                      return detalle.order.status == _selectedStatus;
                    }).toList();

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Mis servicios",
                            style: GoogleFonts.quicksand(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 10)),
                    SliverToBoxAdapter(
                      child: Card(
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _statusDisplayNames.length,
                            itemBuilder: (context, index) {
                              final statusKey = _statusDisplayNames.keys
                                  .elementAt(index);
                              final statusDisplayName = _statusDisplayNames
                                  .values
                                  .elementAt(index);
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: ChoiceChip(
                                  label: Text(statusDisplayName),
                                  selected: _selectedStatus == statusKey,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedStatus = statusKey;
                                        _tileActivo = null;
                                      });
                                    }
                                  },
                                  checkmarkColor: Colors.white,
                                  selectedColor: AppColors.greenDark,
                                  labelStyle: TextStyle(
                                    color:
                                        _selectedStatus == statusKey
                                            ? Colors.white
                                            : AppColors.greenDark,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 10)),
                    if (filteredDetalles.isNotEmpty)
                      SliverList(
                        delegate: SliverChildBuilderDelegate((
                          BuildContext context,
                          int index,
                        ) {
                          final detalle = filteredDetalles[index];
                          final order = detalle.order;
                          final personal = detalle.personal;
                          final idPersonal = personal.id;
                          final promedio = promedioPorPersonal[idPersonal];

                          if (!promedioPorPersonal.containsKey(idPersonal)) {
                            obtenerPromedioCalificacion(idPersonal).then((
                              valor,
                            ) {
                              setState(() {
                                promedioPorPersonal[idPersonal] = valor;
                              });
                            });
                          }

                          return Card(
                            elevation: 0,
                            child: ExpansionTile(
                              key: Key('tile_${order.id}'),
                              initiallyExpanded: _tileActivo == order.id,
                              onExpansionChanged: (expanded) {
                                setState(
                                  () =>
                                      _tileActivo = expanded ? order.id : null,
                                );
                              },
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundImage: NetworkImage(
                                  'https://helfer.flatzi.com/img/personal/${personal.foto}',
                                ),
                                child: ClipOval(
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/placeholder.jpg',
                                    image:
                                        'https://helfer.flatzi.com/img/personal/${personal.foto}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title:
                                  order.status == 'finalizado'
                                      ? Text(
                                        '${personal.nombre} ${personal.apellido}',
                                        style: TextStyle(fontSize: 12),
                                      )
                                      : Text(
                                        'Servicio #${order.id}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                              subtitle:
                                  order.status == 'finalizado'
                                      ? Text(
                                        promedio != null
                                            ? '${promedio.toStringAsFixed(1)} ⭐ - #${order.id}'
                                            : 'Sin calificación',
                                        style: const TextStyle(fontSize: 12),
                                      )
                                      : Text(
                                        'Total. ₲${numberFormat(order.total.toString())}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                              trailing:
                                  order.status == 'finalizado'
                                      ? FutureBuilder<bool>(
                                        future: yaCalificado(order.id),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const SizedBox.shrink(); // spinner si querés
                                          }
                                          final fueCalificado = snapshot.data!;
                                          return ElevatedButton(
                                            onPressed:
                                                fueCalificado
                                                    ? null
                                                    : () => mostrarCalificacion(
                                                      context,
                                                    ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  fueCalificado
                                                      ? Colors.grey
                                                      : Colors.amber,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                            ),
                                            child: Text(
                                              fueCalificado
                                                  ? 'Calificado'
                                                  : 'Calificar',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                      : (order.status == 'agendado'
                                          ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: getStatusColor(
                                                order.status,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: GestureDetector(
                                              onTap: () async {
                                                final personalModel =
                                                    await fetchPersonalModel(
                                                      personal.id,
                                                    );
                                                if (personalModel == null) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'No se pudo cargar el perfil',
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                final double? promedio =
                                                    promedioPorPersonal[personal
                                                        .id];
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          _,
                                                        ) => PerfilPersonalScreen2(
                                                          personalModel:
                                                              personalModel, // Pasas el PersonalModel
                                                          promedioCalificacion:
                                                              promedio, // <-- ¡Pasas el promedio aquí!
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                'Ver perfil',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                          : Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: getStatusColor(
                                                order.status,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Text(
                                              _statusDisplayNames[order
                                                  .status]!,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),

                                      Row(
                                        children: [
                                          Icon(Iconsax.calendar_copy),
                                          SizedBox(width: 8),
                                          Text(
                                            'Solicitud: ${DateFormat('EEEE d MMMM y', 'es_PY').format(DateTime.parse(order.createdAt)).toString().capitalizeFirst()}',
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Iconsax.calendar),
                                          SizedBox(width: 8),
                                          Text(
                                            DateFormat('EEEE d MMMM y', 'es_PY')
                                                .format(
                                                  DateTime.parse(
                                                    order.fechaServicio,
                                                  ),
                                                )
                                                .toString()
                                                .capitalizeFirst(),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Iconsax.clock_copy),
                                          SizedBox(width: 8),
                                          Text(order.horarioRango),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Iconsax.rotate_left_copy),
                                          SizedBox(width: 8),
                                          Text(order.frecuenciaServicio),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Iconsax.box_copy),
                                          SizedBox(width: 8),
                                          Text('${order.paqueteHoras}  Horas.'),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      Text(
                                        'Personal asignado:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Iconsax.user_copy),
                                          SizedBox(width: 8),
                                          Text(
                                            '${personal.nombre} ${personal.apellido}',
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Iconsax.ranking_1_copy),
                                          SizedBox(width: 8),
                                          Text(
                                            promedio != null
                                                ? '${promedio.toStringAsFixed(1)} ⭐'
                                                : 'Sin calificación',
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Iconsax.broom_copy),
                                          SizedBox(width: 8),
                                          Text(
                                            '${personal.antiguedad} servicos realizados',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }, childCount: filteredDetalles.length),
                      )
                    else
                      // Si filteredDetalles está vacío, muestra este mensaje centrado
                      SliverFillRemaining(
                        hasScrollBody:
                            false, // Importante para centrar verticalmente
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.asset(
                                  'assets/box-pedidos.png',
                                  scale: 1.2,
                                ),
                              ),
                              Text(
                                "Aun no tienes Servicios ${_statusDisplayNames[_selectedStatus]}.",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

// **Función para mostrar el campo de comentario ahora es independiente**
Future<bool> _mostrarCampoComentario(
  BuildContext context,

  TextEditingController controller,
) async {
  final result = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true, // Para ajustar cuando el teclado aparezca
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: AppColors.white,
    builder: (BuildContext bc) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bc).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        color: Colors.grey[800],
                        iconSize: 26,
                      ),
                    ),
                    SizedBox(width: 10),
                    const Text(
                      'Deja tu comentario',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Haz tu reseña aquí...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide.none,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.pop(
                            context,
                            controller.text,
                          ); // Devuelve el texto
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ],
        ),
      );
    },
  );

  // Puedes hacer algo con el resultado si es necesario, por ejemplo mostrar un snackbar
  if (result != null && result.isNotEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Comentario guardado: "$result"')));
  }

  // Devuelve true si el resultado no es nulo y no está vacío, indicando que se cargó un comentario.
  return result != null && result.isNotEmpty;
}

void mostrarPopupCalificacion(
  BuildContext context, {
  required int idReserva,
  required int idPersonal,
}) {
  int calificacion = 0;
  TextEditingController comentarioController = TextEditingController();
  // Estado para las sugerencias seleccionadas
  List<String> _selectedSugerencias = [];
  // --- NUEVO ESTADO: Para saber si el comentario ha sido cargado ---
  bool _comentarioCargado = false; // Inicialmente false

  // Función auxiliar para obtener el texto de la calificación
  String getCalificacionText(int calificacion) {
    switch (calificacion) {
      case 1:
        return "Fatal";
      case 2:
        return "Aceptable";
      case 3:
        return "Bueno";
      case 4:
        return "Muy Bueno";
      case 5:
        return "¡Excelente!";
      default:
        return "";
    }
  }

  // Define las sugerencias aquí
  List<String> getSugerenciasPorCalificacion(int calificacion) {
    if (calificacion <= 3) {
      return [
        'Llegó tarde',
        'No quedó muy limpio',
        'Desatento',
        'Descuidado',
        'El personal no coincide',
      ];
    } else {
      return [
        'Excelente atención',
        'Puntual',
        'Atento',
        'Fino Cluidado',
        'Recomendado',
      ];
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: AppColors.white,

    builder: (BuildContext bc) {
      // Usamos StatefulBuilder para manejar el estado interno del bottom sheet
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          List<String> currentSugerencias = getSugerenciasPorCalificacion(
            calificacion,
          );

          if (comentarioController.text.isNotEmpty && !_comentarioCargado) {
            _comentarioCargado = true;
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bc).viewInsets.bottom,
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: const Text(
                          '¿Cómo fue el servicio?',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ⭐ Selector de estrellas y texto descriptivo
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return IconButton(
                                iconSize: 44,
                                icon: Image.asset(
                                  index < calificacion
                                      ? 'assets/star.png'
                                      : 'assets/star_line.png',
                                  width: 44,
                                  height: 44,
                                ),
                                onPressed: () {
                                  setState(() {
                                    calificacion = index + 1;
                                    // Limpiar sugerencias seleccionadas al cambiar calificación
                                    _selectedSugerencias.clear();
                                  });
                                  // No llamar a mostrarSugerencias aquí, ya se mostrarán dinámicamente
                                },
                              );
                            }),
                          ),
                          SizedBox(height: 10),
                          if (calificacion > 0)
                            Text(
                              getCalificacionText(calificacion),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          const SizedBox(height: 20),
                          if (calificacion > 0)
                            Divider(
                              height: 20,
                              thickness: 1, // Grosor de la línea
                              indent: 20, // Margen izquierdo
                              endIndent: 20, // Margen derecho
                              color: Colors.grey[400],
                            ),
                          const SizedBox(height: 20),
                          if (calificacion > 0)
                            Text(
                              "¿Quieres añadir algún comentario?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          SizedBox(height: 20),
                        ],
                      ),
                      // --- NUEVO: Chips de sugerencias ---
                      if (calificacion >
                          0) // Muestra las sugerencias solo si hay calificación
                        Align(
                          alignment: Alignment.center,
                          child: Wrap(
                            spacing: 8.0, // Espacio entre los chips
                            runSpacing: 8.0, // Espacio entre las filas de chips
                            alignment: WrapAlignment.center,
                            children: [
                              ...currentSugerencias.map((sugerencia) {
                                final isSelected = _selectedSugerencias
                                    .contains(sugerencia);
                                return ActionChip(
                                  label: Text(
                                    sugerencia,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? AppColors.greenStandar
                                              : AppColors.grayDark,
                                    ),
                                  ),
                                  backgroundColor:
                                      isSelected
                                          ? AppColors.greenLight
                                          : Colors.grey[100],
                                  side: BorderSide(
                                    width: 2,
                                    color:
                                        isSelected
                                            ? AppColors.greenStandar
                                            : Colors.transparent,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedSugerencias.remove(sugerencia);
                                      } else {
                                        _selectedSugerencias.add(sugerencia);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                              // Botón "Deja un comentario" como un chip
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ActionChip(
                                    avatar: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color:
                                          _comentarioCargado
                                              ? AppColors.greenStandar
                                              : AppColors
                                                  .grayDark, // Color del icono
                                    ),
                                    label: Text(
                                      'Deja un comentario',
                                      style: TextStyle(
                                        color:
                                            _comentarioCargado
                                                ? AppColors.greenStandar
                                                : AppColors
                                                    .grayDark, // Color del texto
                                      ),
                                    ),
                                    backgroundColor:
                                        _comentarioCargado
                                            ? AppColors.greenLight
                                            : AppColors
                                                .grayLight, // Color de fondo
                                    side: BorderSide(
                                      width: 2,
                                      color:
                                          _comentarioCargado
                                              ? AppColors.greenStandar
                                              : Colors
                                                  .transparent, // Color del borde
                                    ),
                                    onPressed: () async {
                                      // Captura el resultado de _mostrarCampoComentario
                                      final bool comentarioGuardado =
                                          await _mostrarCampoComentario(
                                            context,
                                            comentarioController,
                                          );
                                      setState(() {
                                        _comentarioCargado = comentarioGuardado;
                                        // Si el comentario se eliminó (quedó vacío), también resetear el estado
                                        if (comentarioController.text.isEmpty) {
                                          _comentarioCargado = false;
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AppColors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide.none,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Listo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () async {
                                final comentario =
                                    comentarioController.text.trim();

                                // Validaciones
                                if (calificacion == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Seleccioná al menos 1 estrella',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                final resultado = await enviarCalificacion(
                                  idReserva: idReserva,
                                  idPersonal: idPersonal,
                                  calificacion: calificacion,
                                  comentario: comentario,
                                  sugerenciasSeleccionadas:
                                      _selectedSugerencias,
                                );
                                // 👇 Acá va tu bloque de validación
                                if (resultado['status'] == 'error') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        resultado['message'] ??
                                            'Error desconocido',
                                      ),
                                    ),
                                  );
                                  return; // 💡 Evita continuar si hubo error
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      resultado['message'] ??
                                          'Error al calificar',
                                    ),
                                  ),
                                );

                                await Future.delayed(
                                  const Duration(milliseconds: 500),
                                );
                                Navigator.pop(
                                  context,
                                ); // Cierra el bottom sheet
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 70),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Fondo blanco
                      shape: BoxShape.circle, // Forma circular para el botón
                      boxShadow: [
                        // Sombra
                        BoxShadow(
                          color: const Color.fromARGB(22, 0, 0, 0),
                          spreadRadius: 2, // Cuánto se extiende la sombra
                          blurRadius: 2, // Qué tan difuminada está la sombra
                          offset: const Offset(
                            0,
                            0,
                          ), // Desplazamiento de la sombra (eje X, Y)
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.grey[800],
                      iconSize: 26,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
