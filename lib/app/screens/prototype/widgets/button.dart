import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final IconData iconData;
  final double height;
  final double width;
  final double size;
  final MainAxisAlignment mainAxisAlignment;
  final double paddingBetweenIcons;
  final TextStyle textStyle;
  final EdgeInsets buttonPadding;
  final bool expanded;
  final bool enabled;
  final EdgeInsets paddingText;
  final TextOverflow textOverflow;
  final int maxLines;

  const AppButton({
    @required this.onPressed,
    @required this.text,
    this.iconData,
    this.mainAxisAlignment,
    this.paddingBetweenIcons,
    // this.height = 45,
    ///Uncomment the above parameter to use static height
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
  });

  // @override
  // Widget build(BuildContext context) {
  //   SizeConfig().init(context);
  //   List<Widget> children = [];
  //
  //   if(this.iconData != null)
  //   {
  //     children.add(
  //         Icon(this.iconData, color: Colors.white,)
  //     );
  //   }
  //
  //   if(this.mainAxisAlignment == MainAxisAlignment.start)
  //   {
  //     children.add(
  //         Padding(padding: EdgeInsets.only(left: this.paddingBetweenIcons ?? 8),)
  //     );
  //   }
  //
  //   TextStyle btnStyle = this.textStyle == null
  //     ? TextStyle(
  //       color: Colors.white,
  //       fontSize: this.size ?? SizeConfig.smallLabel)
  //     : this.textStyle.copyWith(fontSize: this.size ?? SizeConfig.smallLabel);
  //
  //   children.add(
  //     Flexible(
  //       child: Padding(
  //         padding: this.paddingText,
  //         child: Text(text, style: this.textStyle ??
  //           btnStyle,
  //           overflow: this.textOverflow,
  //           maxLines: this.maxLines,
  //         ),
  //       ),
  //     )
  //   );
  //
  //   return SizedBox(
  //     height: this.height,
  //     width: this.width,
  //     child: ElevatedButton(
  //       onPressed: this.onPressed,
  //       child: Row(
  //         mainAxisAlignment: this.mainAxisAlignment ?? MainAxisAlignment.spaceAround,
  //         mainAxisSize: this.expanded == true ? MainAxisSize.max : MainAxisSize.min,
  //         children: children
  //       ),
  //       style: ButtonStyle(
  //         backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
  //           if(states.contains(MaterialState.pressed))
  //             return AppColors.purple;
  //           else if (states.contains(MaterialState.disabled))
  //             return AppColors.violet;
  //           return null;
  //         }),
  //         shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
  //         padding: MaterialStateProperty.all<EdgeInsets>(
  //           this.buttonPadding
  //         ),
  //
  //       )
  //       // style: ButtonStyle(
  //       //   backgroundColor: MaterialStateProperty.all<Color>(AppColors.purple),
  //       //   shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
  //       // )
  //     ),
  //   );
  // }

  ///Remove the build method and uncomment the above method
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

    TextStyle btnStyle = this.textStyle == null
        ? TextStyle(
        color: this.enabled ? Colors.white : AppColors.labelDisabledColor,
        fontSize: this.size ?? SizeConfig.spanSize * 1.6)
        : this.textStyle.copyWith(fontSize: this.size ?? SizeConfig.spanSize * 1.6);

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
              backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                if(states.contains(MaterialState.pressed))
                  return AppColors.purple;
                else if (states.contains(MaterialState.disabled))
                  return AppColors.violet;
                return null;
              }),
              shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
          )
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {

  final double iconSize;
  final VisualDensity visualDensity;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final Color color;
  final Function onPressed;
  final Widget icon;


  const AppIconButton(
    {
      Key key,
      this.iconSize = 24.0,
      this.visualDensity,
      this.padding = const EdgeInsets.all(8.0),
      this.alignment = Alignment.center,
      this.color,
      @required this.onPressed,
      @required this.icon,
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

