import 'package:flutter/material.dart';
import 'package:fl_business/services/language_service.dart';
import '../models/referencia_model.dart';
import '../services/referencia_service.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';

class ReferenciaSearchWidget extends StatefulWidget {
  final String empresa;
  final Function(Referencia?) onSeleccionar;
  final TextEditingController? controller; // controlador opcional

  const ReferenciaSearchWidget({
    Key? key,
    required this.empresa,
    required this.onSeleccionar,
    this.controller,
  }) : super(key: key);

  @override
  State<ReferenciaSearchWidget> createState() => _ReferenciaSearchWidgetState();
}

class _ReferenciaSearchWidgetState extends State<ReferenciaSearchWidget> {
  late final TextEditingController _controller;
  List<Referencia> _resultados = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    // Si el padre pasa controller, lo usamos; sino creamos uno interno
    _controller = widget.controller ?? TextEditingController();
  }

  void _buscar(String texto) async {
    if (texto.isEmpty) {
      setState(() => _resultados = []);
      return;
    }

    setState(() => _cargando = true);

    try {
      final response = await ReferenciaService().buscarPorTexto(
        texto: texto,
        empresa: widget.empresa,
      );

      setState(() {
        _resultados = response.data;
      });
    } catch (e) {
      print("Error al buscar referencia: $e");
    } finally {
      setState(() => _cargando = false);
    }
  }

  void clear() {
    _controller.clear();
    setState(() => _resultados = []);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Input con solo borde inferior
        TextField(
          controller: _controller,
          onChanged: _buscar,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.tablero, 'BuscReferencia'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffCED4DA)), // gris claro
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xff134895),
                width: 2,
              ), // azul al enfocar
            ),
          ),
        ),

        const SizedBox(height: 6),

        if (_cargando)
          const Center(child: CircularProgressIndicator())
        else if (_resultados.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 150),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _resultados.length,
              itemBuilder: (context, index) {
                final ref = _resultados[index];
                return ListTile(
                  title: Text("${ref.descripcion}: (${ref.referencia})"),
                  subtitle: Text("ID: ${ref.referenciaId}"),
                  onTap: () {
                    widget.onSeleccionar(ref);
                    setState(() {
                      _controller.text = ref.descripcion;
                      _resultados = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
