import 'package:flutter/material.dart';

class SimpleWarning extends StatelessWidget {

  final String title;
  final String text;
  const SimpleWarning({this.title = 'Title', this.text = 'Sample Text'});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () {
            //Pops this alertDialog
            Navigator.pop(context);
          },
          child: Text("OK"))
      ],
    );
  }
}
