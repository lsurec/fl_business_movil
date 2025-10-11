import 'package:flutter/material.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/themes/themes.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';

class RegisterCountWidget extends StatelessWidget {
  const RegisterCountWidget({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "${AppLocalizations.of(context)!.translate(BlockTranslate.general, 'registro')} ($count)",
          style: StyleApp.normalBold,
        ),
      ],
    );
  }
}
