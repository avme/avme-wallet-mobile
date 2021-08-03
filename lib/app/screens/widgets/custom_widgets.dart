import 'dart:ffi';

import 'package:flutter/material.dart';

//Common text
Text commonText(String content)
{
  Text _commonText = Text(
    content,
    style: TextStyle(
        fontSize: 16
    ),

  );
  return _commonText;
}

//Simple list of ListView with padding...
ListView forms (List<Widget> elementos, {double horizontal = 20,double vertical = 40, double spacing = 10})
{
  List <Widget> outputItens = [];
  int index = 0;
  horizontal = horizontal / 2;
  vertical = vertical / 2;
  for(final widget in elementos)
  {
    var pad;
    if(index == 0)
    {
      pad = EdgeInsets.fromLTRB(vertical,horizontal,vertical,0);
    }
    else
    {
      pad = EdgeInsets.fromLTRB(0,horizontal,vertical,spacing);
    }
    outputItens.add(
        Padding(
          padding: pad,
          child: widget,
        )
    );
  }
  return ListView(children: outputItens,);
}

// Simple Password field
TextField passwordField (TextEditingController _controller, String _label) {
  return TextField(
      controller: _controller,
      obscureText: true,
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: _label
      )
  );
}

Text textCenter(String text)
{
  return Text(text, textAlign: TextAlign.center);
}

class SimpleWarning extends StatelessWidget {

  final String title;
  final String text;
  const SimpleWarning({this.title, this.text = 'Sample Text'});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title != null ? Text(title) : null,
      content: Text(text),
      actions: title != null ? [
        TextButton(
            onPressed: () {
              //Pops this alertDialog
              Navigator.pop(context);
            },
            child: Text("OK"))
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


class LoadingPopUp extends StatefulWidget {
  final String title;
  final String text;
  final BuildContext context;
  LoadingPopUp({this.title, this.text = 'Sample Text', this.context});
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
            child: Text("OK"))
      ] : null,
    );
  }
}

class LabelText extends StatelessWidget {
  final String text;
  LabelText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(this.text,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16)
    );
  }
}
