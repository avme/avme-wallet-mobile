import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppNeonButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final IconData iconData;
  final double height;

  const AppNeonButton({@required this.onPressed, @required this.text, this.iconData, this.height = 45});
  @override
  Widget build(BuildContext context) {

    List<Widget> children = [];

    if(this.iconData != null)
    {
      children.add(
        Icon(this.iconData, color: AppColors.purple,)
      );
    }

    children.add(
      Text(text, style: TextStyle(
        color: AppColors.purple
      ),)
    );

    return SizedBox(
      height: this.height,
      child: ElevatedButton(
        onPressed: this.onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: children
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
          shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
                side: BorderSide(width: 2, color: AppColors.purple)
            )
          )
        )
      ),
    );
  }
}
