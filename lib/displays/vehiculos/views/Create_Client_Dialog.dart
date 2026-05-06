import 'package:fl_business/displays/prc_documento_3/models/cuenta_correntista_model.dart';
import 'package:fl_business/displays/prc_documento_3/services/cuenta_service.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/document_view_model.dart';
import 'package:fl_business/displays/shr_local_config/view_models/local_settings_view_model.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:fl_business/view_models/menu_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateClientDialog extends StatefulWidget {
  const CreateClientDialog();

  @override
  State<CreateClientDialog> createState() => _CreateClientDialogState();
}
class _CreateClientDialogState extends State<CreateClientDialog> {
  final formKey = GlobalKey<FormState>();

  final Map<String, dynamic> formValues = {
    "nombre": "",
    "direccion": "",
    "telefono": "",
    "correo": "",
    "nit": "",
  };

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nuevo cliente"),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Nombre"),
                onChanged: (v) => formValues["nombre"] = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "NIT"),
                onChanged: (v) => formValues["nit"] = v,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: loading
              ? null
              : () async {
                  await _createClient(context);
                },
          child: loading
              ? const CircularProgressIndicator()
              : const Text("Guardar"),
        ),
      ],
    );
  }

  Future<void> _createClient(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final localVM = Provider.of<LocalSettingsViewModel>(context, listen: false);
    final documentVM = Provider.of<DocumentViewModel>(context, listen: false);
    final menuVM = Provider.of<MenuViewModel>(context, listen: false);

    CuentaService service = CuentaService();

    CuentaCorrentistaModel cuenta = CuentaCorrentistaModel(
      cuentaCuenta: "",
      grupoCuenta: 0,
      cuenta: 0,
      nombre: formValues["nombre"],
      direccion: formValues["direccion"],
      telefono: formValues["telefono"],
      correo: formValues["correo"],
      nit: formValues["nit"],
    );

    final res = await service.postCuenta(
      loginVM.user,
      localVM.selectedEmpresa!.empresa,
      loginVM.token,
      cuenta,
      localVM.selectedEstacion!.estacionTrabajo,
    );

    if (!res.succes) {
      setState(() => loading = false);
      return;
    }

    final resClient = await service.getCuentaCorrentista(
      localVM.selectedEmpresa!.empresa,
      cuenta.nit,
      loginVM.user,
      loginVM.token,
      menuVM.app,
      localVM.selectedEstacion!.estacionTrabajo,
    );

    setState(() => loading = false);

    if (!resClient.status || resClient.data.isEmpty) return;

    final client = resClient.data.first;

    // 🔥 AQUÍ SE SELECCIONA AUTOMÁTICAMENTE
    documentVM.selectClient(true, client, context);

    Navigator.pop(context); // cerrar dialog
  }
}