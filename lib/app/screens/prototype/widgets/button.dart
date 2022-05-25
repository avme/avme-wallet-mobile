// @dart=2.12
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? iconData;
  final double? height;
  final double? width;
  final double? size;
  final MainAxisAlignment? mainAxisAlignment;
  final double? paddingBetweenIcons;
  final TextStyle? textStyle;
  final EdgeInsets? buttonPadding;
  final bool expanded;
  final bool enabled;
  final EdgeInsets paddingText;
  final TextOverflow textOverflow;
  final int maxLines;
  final bool square;

  const AppButton({
    required this.onPressed,
    required this.text,
    this.iconData,
    this.mainAxisAlignment,
    this.paddingBetweenIcons,
    this.height,
    this.width,
    this.size,
    this.expanded = true,
    this.enabled = true,
    this.textStyle,
    this.paddingText = const EdgeInsets.all(0),
    this.textOverflow = TextOverflow.ellipsis,
    this.maxLines = 1,
    this.buttonPadding,
    this.square = false,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    List<Widget> children = [];

    if(this.iconData != null)
    {
      children.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: this.paddingBetweenIcons ?? SizeConfig.safeBlockHorizontal * 2.5),
            child: Icon(this.iconData, color: this.enabled ? Colors.white : Colors.grey,),
          )
      );
    }

    TextStyle btnStyle = this.textStyle ?? TextStyle(
      color: this.enabled ? Colors.white : AppColors.labelDisabledColor,
      fontSize: this.size ?? SizeConfig.spanSize * 1.6);

    btnStyle = btnStyle.copyWith(fontSize: this.size ?? SizeConfig.spanSize * 1.6);

    children.add(
        Flexible(
          child: Padding(
            padding: this.iconData != null ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 4),
            child: Text(text,style: this.textStyle ??
                btnStyle,
              textAlign: TextAlign.left,
              overflow: this.textOverflow,
              maxLines: this.maxLines,
            ),
          ),
        )
    );
    MainAxisAlignment itemsAlign = this.mainAxisAlignment ?? MainAxisAlignment.center;

    if(this.iconData != null)
      itemsAlign = MainAxisAlignment.start;

    return SizedBox(
      height: this.height ?? SizeConfig.safeBlockVertical * 6,
      child: ElevatedButton(
          onPressed: this.enabled ? this.onPressed : null,
          child: Row(
              mainAxisAlignment: itemsAlign,
              mainAxisSize: this.expanded == true ? MainAxisSize.max : MainAxisSize.min,
              children: children
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                if(states.contains(MaterialState.pressed))
                  return AppColors.purple;
                else if (states.contains(MaterialState.disabled))
                  return AppColors.violet;
              }),
              shape: !this.square
                ? null
                : MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero)
                  ),
              shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
          )
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {

  final double iconSize;
  final VisualDensity? visualDensity;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final Color? color;
  final VoidCallback? onPressed;
  final Widget icon;


  const AppIconButton(
    {
      this.iconSize = 24.0,
      this.visualDensity,
      this.padding = const EdgeInsets.all(8.0),
      this.alignment = Alignment.center,
      this.color,
      this.onPressed,
      required this.icon,
    }
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data:
        avmeTheme.copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: IconButton(
        color: this.color,
        alignment: this.alignment,
        padding: this.padding,
        onPressed: this.onPressed,
        icon: this.icon,
        iconSize: this.iconSize,
        visualDensity: this.visualDensity,
      ),
    );
  }
}

class AppDarkIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget text;
  final Widget icon;
  final EdgeInsets? padding;
  final bool centered;
  final double? height;
  final AlignmentGeometry? alignment;
  const AppDarkIconButton({
    Key? key,
    required this.onPressed,
    this.padding,
    this.centered = false,
    required this.text,
    required this.icon,
    this.height,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SizedBox(
      height: this.height ?? SizeConfig.safeBlockVertical * 6.5,
      child: ElevatedButton.icon(
        onPressed: this.onPressed,
        label: this.text,
        style: ButtonStyle(
          alignment: alignment,
          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            return AppColors.purpleDark3;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              )
          ),
          shadowColor: MaterialStateProperty.all<Color>(Colors.black),
          elevation: MaterialStateProperty.all(3),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(this.padding ?? const EdgeInsets.all(8.0)),
        ),
        icon: SizedBox(
          width: SizeConfig.safeBlockHorizontal * 8,
          child: Center(child: this.icon),
        ),
      ),
    );
  }
}

class AppDarkButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsets? padding;
  final bool centered;
  final double? height;
  final AlignmentGeometry? alignment;
  const AppDarkButton({
    Key? key,
    required this.onPressed,
    this.padding,
    this.centered = false,
    required this.child,
    this.height,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SizedBox(
      height: this.height ?? SizeConfig.safeBlockVertical * 6.5,
      child: ElevatedButton(
        onPressed: this.onPressed,
        child: this.child,
        style: ButtonStyle(
          alignment: alignment,
          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            return AppColors.purpleDark3;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              )
          ),
          shadowColor: MaterialStateProperty.all<Color>(Colors.black),
          elevation: MaterialStateProperty.all(3),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(this.padding ?? const EdgeInsets.all(8.0)),
        ),
      ),
    );
  }
}