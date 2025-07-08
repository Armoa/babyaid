import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/usuario_model.dart';
import 'package:intl/intl.dart';

class FrecuenciaServicio extends StatefulWidget {
  final UbicacionModel ubicacion;

  const FrecuenciaServicio({super.key, required this.ubicacion});

  @override
  State<FrecuenciaServicio> createState() => _FrecuenciaServicioState();
}

class _FrecuenciaServicioState extends State<FrecuenciaServicio> {
  String frecuencia = 'Única Vez';
  bool politicaAceptada = false;
  int duracionHoras = 4;
  int intervaloHoras = 4;
  int horaSeleccionada = 8;
  DateTime? fechaSeleccionada;

  RangeValues rangoHoras = const RangeValues(8, 12);

  @override
  Widget build(BuildContext context) {
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
              "¿Cuando vamos?",
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.place_outlined, size: 30),
                          SizedBox(width: 10),
                          Text(
                            widget.ubicacion.nombreUbicacion,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          SizedBox(width: 40),
                          Text(
                            widget.ubicacion.callePrincipal,
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      _selectorFrecuencia(),
                      const SizedBox(height: 20),
                      _checkboxPolitica(),
                      const SizedBox(height: 20),
                      _sliderDuracionServicio(),
                      const SizedBox(height: 20),
                      _rangeHorarioServicio(),
                      const SizedBox(height: 20),
                      // _sliderHoraInicio(),
                      const SizedBox(height: 20),
                      _selectorFecha(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              color: AppColors.grayLight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.graySoft,
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueSky,
                        ),
                        child: const Text(
                          'Aceptar',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Selector de frecuencia
  Widget _selectorFrecuencia() {
    const opciones = ['Única Vez', 'Semanal', 'Quincenal'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Frecuencia del Servicio",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children:
              opciones.map((opcion) {
                final activo = frecuencia == opcion;
                return Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: ChoiceChip(
                    label: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            opcion,
                            style: TextStyle(
                              fontSize: 20,
                              color: activo ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    selected: activo,
                    checkmarkColor: Colors.white, // Color del ícono de check
                    selectedColor: AppColors.blueDark,
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: activo ? AppColors.blueDark : Colors.grey[400]!,
                      ),
                    ),

                    onSelected: (_) => setState(() => frecuencia = opcion),
                  ),
                );
              }).toList(),
        ),
        if (frecuencia != 'Única Vez')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              frecuencia == 'Semanal'
                  ? "Permanencia mínima: 4 servicios o 1 mes."
                  : "Permanencia mínima: 2 servicios o 1 mes.",
              style: const TextStyle(color: AppColors.blueSky, fontSize: 13),
            ),
          ),
      ],
    );
  }

  // Checkbox Politica
  Widget _checkboxPolitica() {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: Colors.grey, // color del borde cuando está vacío
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.blueDark; // color del check activo
            }
            return Colors.grey; // color del borde inactivo
          }),
          checkColor: WidgetStateProperty.all<Color>(
            Colors.white,
          ), // color del icono interno
        ),
      ),
      child: CheckboxListTile(
        value: politicaAceptada,
        onChanged: (val) => setState(() => politicaAceptada = val ?? false),
        title: const Text(
          "Política de Cancelación +",
          style: TextStyle(fontSize: 16),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero, // elimina ese espacio extra
        dense: true, // hace más compacto el tile
      ),
    );
  }

  // Duración del Servicio
  Widget _sliderDuracionServicio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Duración del Servicio",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: duracionHoras.toDouble(),
          min: 4,
          max: 9,
          divisions: 2,
          label: "$duracionHoras hs.",
          onChanged: (val) => setState(() => duracionHoras = val.round()),
        ),
      ],
    );
  }

  // Rago de Horario
  Widget _rangeHorarioServicio() {
    final minHora = 8.0;
    final maxHora = 18.0;
    final duracionMinima = duracionHoras.toDouble();

    final rangoMin = minHora;
    final rangoMax = maxHora;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Horario en que puedes recibir el servicio",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: RangeSlider(
            values: rangoHoras,
            min: rangoMin,
            max: rangoMax,
            divisions: (rangoMax - rangoMin).toInt(),
            labels: RangeLabels(
              "${rangoHoras.start.round()}:00",
              "${rangoHoras.end.round()}:00",
            ),
            onChanged: (values) {
              setState(
                () =>
                    rangoHoras = RangeValues(
                      values.start.roundToDouble(),
                      values.end.roundToDouble(),
                    ),
              );
            },
            onChangeEnd: (values) {
              final diferencia = values.end - values.start;

              if (diferencia < duracionMinima) {
                _mostrarSnackHorarioInvalido();
                // Opcional: restaurar rango anterior válido
                setState(
                  () =>
                      rangoHoras = RangeValues(
                        values.start,
                        values.start + duracionMinima > maxHora
                            ? maxHora
                            : values.start + duracionMinima,
                      ),
                );
              }
            },
          ),
        ),

        Text(
          "Seleccionado: ${rangoHoras.start.round()}:00 a ${rangoHoras.end.round()}:00 (${rangoHoras.end.round() - rangoHoras.start.round()} hs.)",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  void _mostrarSnackHorarioInvalido() {
    final snackBar = SnackBar(
      content: Text('El horario debe ser al menos de $duracionHoras hs.'),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.redAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Selector de fecha Horizonal
  List<DateTime> generarFechasConFinesDeSemana() {
    final hoy = DateTime.now();
    final inicio = hoy.add(const Duration(days: 1));
    return List.generate(14, (i) => inicio.add(Duration(days: i)));
  }

  bool sonLaMismaFecha(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _selectorFecha() {
    final fechas = generarFechasConFinesDeSemana();
    final fechasTotales = generarFechasConFinesDeSemana();

    String formatearFechaElegante(DateTime fecha) {
      final dia = DateFormat.E('es_PY').format(fecha); // ej. "lun"
      final diaCapitalizado = dia[0].toUpperCase() + dia.substring(1); // "Lun"

      return "$diaCapitalizado "; // "Lun 7"
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Elige una fecha",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: fechas.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final fecha = fechasTotales[index];
              final esFinDeSemana =
                  fecha.weekday == DateTime.saturday ||
                  fecha.weekday == DateTime.sunday;
              // final esSeleccionada = fechaSeleccionada == fecha;
              final esSeleccionada =
                  fechaSeleccionada != null &&
                  sonLaMismaFecha(fechaSeleccionada!, fecha);

              final textoCalendario = formatearFechaElegante(fecha);

              Color fondo;
              Color texto;

              if (esFinDeSemana) {
                fondo = Colors.red[100]!;
                texto = Colors.red;
              } else if (esSeleccionada) {
                fondo = AppColors.blueDark; // Fondo resaltado
                texto = Colors.white;
              } else {
                fondo = Colors.grey[300]!;
                texto = Colors.black;
              }

              return GestureDetector(
                onTap:
                    esFinDeSemana
                        ? () {
                          final fecha = fechasTotales[index];
                          final dia = DateFormat.E('es_PY').format(fecha);
                          _mostrarSnackDiaInvalido(dia);
                        }
                        : () {
                          HapticFeedback.selectionClick();
                          setState(() => fechaSeleccionada = fecha);
                        },

                // ? null
                // : () => setState(() => fechaSeleccionada = fecha),
                child: Container(
                  width: 60,

                  padding: const EdgeInsets.symmetric(vertical: 0),
                  decoration: BoxDecoration(
                    color: fondo,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          esSeleccionada
                              ? AppColors.blueDark
                              : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(textoCalendario, style: TextStyle(color: texto)),
                      const SizedBox(height: 4),
                      Text(
                        fecha.day.toString(),
                        style: TextStyle(
                          color: texto,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (fechaSeleccionada != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Fecha seleccionada: ${DateFormat('EEEE d MMM', 'es').format(fechaSeleccionada!)}",
              style: const TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  void _mostrarSnackDiaInvalido(String dia) {
    final snackBar = SnackBar(
      content: Text('No se puede seleccionar $dia. Elige un día hábil.'),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.redAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
