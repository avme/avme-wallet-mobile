import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final IconData iconData;
  final double height;
  final MainAxisAlignment mainAxisAlignment;
  final double paddingBetweenIcons;

  const AppButton({
    @required this.onPressed,
    @required this.text,
    this.iconData,
    @required this.mainAxisAlignment,
    @required this.paddingBetweenIcons,
    this.height = 45});
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
      Text(text, style: TextStyle(
        color: Colors.white
      ),)
    );

    return SizedBox(
      height: this.height,
      child: ElevatedButton(
        onPressed: this.onPressed,
        child: Row(
          mainAxisAlignment: this.mainAxisAlignment ?? MainAxisAlignment.spaceAround,
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
