import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final IconData iconData;
  final double height;
  final double width;
  final MainAxisAlignment mainAxisAlignment;
  final double paddingBetweenIcons;
  final TextStyle textStyle;
  final bool expanded;
  final EdgeInsets paddingText;
  final TextOverflow textOverflow;
  final int maxLines;

  const AppButton({
    @required this.onPressed,
    @required this.text,
    this.iconData,
    this.mainAxisAlignment,
    this.paddingBetweenIcons,
    this.height = 45,
    this.width,
    this.expanded = true,
    this.textStyle,
    this.paddingText = const EdgeInsets.all(0),
    this.textOverflow = TextOverflow.fade,
    this.maxLines = 1,
  });
  @override
  Widget build(BuildContext context) {

    List<Widget> children = [];

    if(this.iconData != null)
    {
      children.add(
          Icon(this.iconData, color: Colors.white,)
      );
    }

    if(this.mainAxisAlignment == MainAxisAlignment.start)
    {
      children.add(
          Padding(padding: EdgeInsets.only(left: this.paddingBetweenIcons ?? 8),)
      );
    }

    children.add(
      Flexible(
        child: Padding(
          padding: this.paddingText,
          child: Text(text, style: this.textStyle ??
            TextStyle(
              color: Colors.white
            ),
            overflow: this.textOverflow,
            maxLines: this.maxLines,
          ),
        ),
      )
    );

    return SizedBox(
      height: this.height,
      width: this.width,
      child: ElevatedButton(
        onPressed: this.onPressed,
        child: Row(
          mainAxisAlignment: this.mainAxisAlignment ?? MainAxisAlignment.spaceAround,
          mainAxisSize: this.expanded == true ? MainAxisSize.max : MainAxisSize.min,
          children: children
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(AppColors.purple),
          shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
        )
      ),
    );
  }
}
