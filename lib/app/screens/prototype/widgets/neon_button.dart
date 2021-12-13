import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppNeonButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final IconData iconData;
  final double height;
  final double size;
  final MainAxisAlignment mainAxisAlignment;
  final double paddingBetweenIcons;
  final TextStyle textStyle;
  final bool expanded;
  final bool enabled;
  final EdgeInsets paddingText;
  final TextOverflow textOverflow;
  final int maxLines;

  const AppNeonButton({
    @required this.onPressed,
    @required this.text,
    this.iconData,
    this.mainAxisAlignment,
    this.paddingBetweenIcons,
    this.height = 45,
    this.size,
    this.expanded = true,
    this.enabled = true,
    this.textStyle,
    this.paddingText = const EdgeInsets.all(0),
    this.textOverflow = TextOverflow.ellipsis,
    this.maxLines = 1,
  });
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    List<Widget> children = [];

    if(this.iconData != null)
    {
      children.add(
        Icon(this.iconData, color: this.enabled ? AppColors.purple : Colors.grey,)
      );
    }

    if(this.mainAxisAlignment == MainAxisAlignment.start)
    {
      children.add(
        Padding(padding: EdgeInsets.only(left: this.paddingBetweenIcons ?? 8),)
      );
    }

    TextStyle btnStyle = this.textStyle == null
        ? TextStyle(
        color: Colors.white,
        fontSize: this.size ?? SizeConfig.smallLabel)
        : this.textStyle.copyWith(fontSize: this.size ?? SizeConfig.smallLabel);

    children.add(
      Flexible(
        child: Padding(
          padding: this.paddingText,
          child: Text(text,style: this.textStyle ??
            btnStyle,
            overflow: this.textOverflow,
            maxLines: this.maxLines,
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
          backgroundColor: MaterialStateProperty.all<Color>(AppColors.darkBlue),
          shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
                side: BorderSide(width: 2, color: this.enabled ? AppColors.purple : AppColors.violet)
            )
          )
        )
      ),
    );
  }
}
