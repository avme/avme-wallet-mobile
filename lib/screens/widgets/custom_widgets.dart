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