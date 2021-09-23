import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppNeonButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final IconData iconData;
  final double height;
  final MainAxisAlignment mainAxisAlignment;
  final double paddingBetweenIcons;
  final TextStyle textStyle;
  final bool expanded;
  final bool enabled;
  final EdgeInsets paddingText;

  const AppNeonButton({
    @required this.onPressed,
    @required this.text,
    this.iconData,
    this.mainAxisAlignment,
    this.paddingBetweenIcons,
    this.height = 45,
    this.expanded = true,
    this.enabled = true,
    this.textStyle,
    this.paddingText = const EdgeInsets.all(0),
  });
  @override
  Widget build(BuildContext context) {

    List<Widget> children = [];

    if(this.iconData != null)
    {
      children.add(
        Icon(this.iconData, color: AppColors.purple,)
      );
    }

    if(this.mainAxisAlignment == MainAxisAlignment.start)
    {
      children.add(
        Padding(padding: EdgeInsets.only(left: this.paddingBetweenIcons ?? 8),)
      );
    }

    children.add(
      Padding(
        padding: this.paddingText,
        child: Text(text, style: this.textStyle ??
          TextStyle(
            color: AppColors.purple
          ),
        ),
      )
    );

    return SizedBox(
      height: this.height,
      child: ElevatedButton(
        onPressed: this.enabled ? this.onPressed : null,
        child: Row(
          mainAxisAlignment: this.mainAxisAlignment ?? MainAxisAlignment.spaceAround,
          mainAxisSize: this.expanded == true ? MainAxisSize.max : MainAxisSize.min,
          children: children
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
          shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
                side: BorderSide(width: 2, color: this.enabled ? AppColors.purple : Colors.grey)
            )
          )
        )
      ),
    );
  }
}
