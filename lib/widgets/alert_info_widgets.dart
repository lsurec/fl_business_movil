import 'package:fl_business/services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_business/themes/themes.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';

class AlertInfoWidget extends StatelessWidget {
  const AlertInfoWidget({
    Key? key,
    required this.title,
    required this.description,
    this.textOk,
    required this.onOk,
  }) : super(key: key);

  final String title;
  final String description;
  final String? textOk;
  final Function onOk;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.isDark()
          ? AppTheme.darkBackroundColor
          : AppTheme.backroundColor,
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(
          child: Text(
            textOk ??
                AppLocalizations.of(
                  context,
                )!.translate(BlockTranslate.botones, 'aceptar'),
          ),
          onPressed: () => onOk(),
        ),
      ],
    );
  }
}
