import 'package:flutter/material.dart';

///Generic Widgets without a specific place to put them...

class LabelText extends StatelessWidget {
  final String text;
  final double fontSize;
  LabelText(this.text, {this.fontSize = 16});
  @override
  Widget build(BuildContext context) {
    return Text(this.text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: this.fontSize
      )
    );
  }
}

class LoadingPopUp extends StatefulWidget {
  final String title;
  final String text;
  final BuildContext context;
  LoadingPopUp({required this.title, this.text = 'Sample Text', required this.context});
  @override
  LoadingPopUpState createState() => LoadingPopUpState();
}

class LoadingPopUpState extends State<LoadingPopUp> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title != null ? Text(widget.title) : null,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState)
        {
          return Text(widget.text);
        }
      ),
      actions: widget.title != null ? [
        TextButton(
          onPressed: () {
            //Pops this alertDialog
            Navigator.pop(context);
          },
          child: Text("OK")
        )
      ] : null,
    );
  }
}

class CircularLoading extends StatefulWidget {
  final String text;

  CircularLoading({this.text = "Loading."});

  @override
  _CircularLoadingState createState() => _CircularLoadingState();
}

class _CircularLoadingState extends State<CircularLoading> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 14),
            Text(widget.text),
          ],
        ),
      ),
    );
  }
}