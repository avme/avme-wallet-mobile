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
ListView forms (List<Widget> elementos)
{
  List <Widget> outputItens = [];
  int index = 0;
  for(final widget in elementos)
  {
    var pad;
    if(index == 0)
    {
      pad = EdgeInsets.fromLTRB(10,20,10,0);
    }
    else
    {
      pad = EdgeInsets.fromLTRB(0,20,10,10);
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