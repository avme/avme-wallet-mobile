import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppLabelText extends StatelessWidget {

  final String text;
  final TextStyle textStyle;
  final bool bold;
  final double fontSize;
  const AppLabelText(
    this.text,{
    Key key,
    this.bold = true,
    this.textStyle = const TextStyle(
      color: AppColors.labelDefaultColor
    ), this.fontSize = 16,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(this.text,
      style: this.textStyle.copyWith(
        fontWeight: this.bold == true ? FontWeight.bold : FontWeight.normal,
        fontSize: this.fontSize
      )
    );
  }
}
