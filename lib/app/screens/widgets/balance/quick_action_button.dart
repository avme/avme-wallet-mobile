import 'package:flutter/material.dart';

class QuickActionButton extends StatelessWidget {
  QuickActionButton({
    @required this.buttonColor,
    @required this.buttonLabel,
    @required this.buttonIcon,
    @required this.onPressed
  });

  final Color buttonColor;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onPressed;

  final ButtonStyle _roundedButton = new ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
  );
  final List<double> _btnDimensions = [70, 70];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _btnDimensions[0],
          width: _btnDimensions[1],
          child: ElevatedButton(
            onPressed: onPressed,
            child: Icon(buttonIcon),
            style: _roundedButton.copyWith(
              backgroundColor:
              MaterialStateProperty.all<Color>(this.buttonColor),
            ),
          ),
        ),
        SizedBox(
          height: 14,
        ),
        Text(this.buttonLabel,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}