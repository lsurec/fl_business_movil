import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/services/language_service.dart';

class UsuarioSearchWidget extends StatefulWidget {
  final Function(Usuario?) onSeleccionar;
  final TextEditingController? controller; // Controlador opcional

  const UsuarioSearchWidget({
    Key? key,
    required this.onSeleccionar,
    this.controller,
  }) : super(key: key);

  @override
  State<UsuarioSearchWidget> createState() => _UsuarioSearchWidgetState();
}

class _UsuarioSearchWidgetState extends State<UsuarioSearchWidget> {
  late final TextEditingController _controller;
  List<Usuario> _resultados = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    // Si el padre pasa un controller, lo usamos; si no, creamos uno propio
    _controller = widget.controller ?? TextEditingController();
  }

  void _buscar(String texto) async {
    if (texto.isEmpty) {
      setState(() => _resultados = []);
      return;
    }

    setState(() => _cargando = true);

    try {
      // Usamos el servicio con Preferences directamente
      final List<Usuario> response = await UsuarioService().buscarUsuarios(
        filtro: texto,
      );

      setState(() {
        _resultados = response;
      });
    } catch (e) {
      print("Error al buscar usuario: $e");
    } finally {
      setState(() => _cargando = false);
    }
  }

  void clear() {
    _controller.clear();
    setState(() => _resultados = []);
    widget.onSeleccionar(null); // Notifica que no hay usuario seleccionado
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: _buscar,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.tablero, 'BuscUsuario'),
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
                final usuario = _resultados[index];
                return ListTile(
                  title: Text("${usuario.userName} ${usuario.name}"),
                  subtitle: Text(usuario.email),
                  onTap: () {
                    widget.onSeleccionar(usuario);
                    setState(() {
                      _controller.text = "${usuario.userName} ${usuario.name}";
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
