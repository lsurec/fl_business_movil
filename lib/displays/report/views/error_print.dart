import 'package:fl_business/displays/prc_documento_3/models/models.dart';
import 'package:fl_business/displays/report/view_models/error_print_view_model.dart';
import 'package:fl_business/themes/app_theme.dart';
import 'package:fl_business/widgets/load_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ErrorPrintView extends StatelessWidget {
  const ErrorPrintView({
    super.key,
    required this.comandas,
    required this.indexOrder,
  });

  final List<ResComandaModel> comandas;
  final int indexOrder;

  @override
  Widget build(BuildContext context) {
    final ErrorPrintViewModel vm = Provider.of<ErrorPrintViewModel>(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text("Error")),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: comandas.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ResComandaModel comanda = comandas[index];

                    return ListTile(
                      title: Text(comanda.comanda.bodega),
                      trailing: Row(
                        mainAxisSize: MainAxisSize
                            .min, // 🔹 evita que el Row ocupe todo el ancho
                        children: [
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: AppTheme.backroundColor,
                                    title: const Text('Algo salió mal'),
                                    content: Text(comanda.error!),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cerrar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.error, color: Colors.red),
                          ),
                          IconButton(
                            onPressed: () => vm.printTCPIP(
                              context,
                              comanda,
                              indexOrder,
                              comandas,
                            ),
                            icon: Icon(Icons.wifi, color: Colors.green),
                          ),
                          IconButton(
                            onPressed: () => vm.printBT(
                              context,
                              comanda,
                              indexOrder,
                              comandas,
                            ),
                            icon: Icon(Icons.bluetooth, color: Colors.blue),
                          ),

                          IconButton(
                            onPressed: () => vm.sharePDF(
                              context,
                              comanda,
                              indexOrder,
                              comandas,
                            ),
                            icon: Icon(
                              Icons.picture_as_pdf,
                              color: Colors.orange,
                            ), // o compartir
                          ),
                          // Icon(Icons.share, color: Colors.orange),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () =>
                        vm.printTCPIPAlll(context, comandas, indexOrder),
                    icon: Icon(Icons.wifi, color: Colors.green),
                  ),
                  IconButton(
                    onPressed: () =>
                        vm.printBTAlll(context, comandas, indexOrder),
                    icon: Icon(Icons.bluetooth, color: Colors.blue),
                  ),

                  IconButton(
                    onPressed: () =>
                        vm.sharePDFAlll(context, comandas, indexOrder),
                    icon: Icon(
                      Icons.picture_as_pdf,
                      color: Colors.orange,
                    ), // o compartir
                  ),
                ],
              ),
            ],
          ),
        ),
        if (vm.isLoading)
          ModalBarrier(
            dismissible: false,
            // color: Colors.black.withOpacity(0.3),
            color: AppTheme.isDark()
                ? AppTheme.darkBackroundColor
                : AppTheme.backroundColor,
          ),
        if (vm.isLoading) const LoadWidget(),
      ],
    );
  }
}
