import 'package:flutter/material.dart';
import 'package:fl_business/displays/shr_local_config/view_models/view_models.dart';
import 'package:fl_business/models/models.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/themes/themes.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/utilities/utilities.dart';
import 'package:fl_business/view_models/view_models.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ErrorModel error =
        ModalRoute.of(context)?.settings.arguments as ErrorModel;

    DateTime date = error.date;

    final vm = Provider.of<ErrorViewModel>(context);
    final vmLogin = Provider.of<LoginViewModel>(context);
    final vmLocal = Provider.of<LocalSettingsViewModel>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => vm.createAndSavePDF(error, context),
        child: const Icon(Icons.share),
      ),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.error, "informe"),
          style: StyleApp.title,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${AppLocalizations.of(context)!.translate(BlockTranslate.general, "usuario")}: ${vmLogin.user}",
              ),
              const SizedBox(height: 10),
              Text(
                "${AppLocalizations.of(context)!.translate(BlockTranslate.fecha, "fecha")}: ${Utilities.formatearFecha(date)} ${date.hour}:${date.minute}:${date.second}",
              ),

              const SizedBox(height: 10),
              // const Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text("Documento:"),
              //         Text("185185"),
              //       ],
              //     ),
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.end,
              //       children: [
              //         const Text("Serie:"),
              //         Text("FEL10"),
              //       ],
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 20),
              Text(
                "${AppLocalizations.of(context)!.translate(BlockTranslate.localConfig, "empresa")}: ${vmLocal.selectedEmpresa?.empresaNombre} (${vmLocal.selectedEmpresa?.empresa})",
              ),
              const SizedBox(height: 10),
              Text(
                "${AppLocalizations.of(context)!.translate(BlockTranslate.localConfig, "estacion")}: ${vmLocal.selectedEstacion?.descripcion} (${vmLocal.selectedEstacion?.estacionTrabajo})",
              ),

              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(
                  context,
                )!.translate(BlockTranslate.error, "servicio"),
              ),
              Text(
                error.url ??
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.error, "indefinido"),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(
                  context,
                )!.translate(BlockTranslate.error, "origen"),
              ),
              Text(
                error.storeProcedure ??
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.error, "noAplica"),
              ),
              const SizedBox(height: 10),
              Text(
                "${AppLocalizations.of(context)!.translate(BlockTranslate.general, "descripcion")}:",
              ),
              Text(error.description),
              const SizedBox(height: 10),
              if (error.docEstructura != null &&
                  error.docEstructura!.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "JSON enviado:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: error.docEstructura!),
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('JSON copiado al portapapeles'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copiar'),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    error.docEstructura!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
              const Divider(),
              Text("Versión: ${SplashViewModel.versionLocal}"),
            ],
          ),
        ),
      ),
    );
  }
}
