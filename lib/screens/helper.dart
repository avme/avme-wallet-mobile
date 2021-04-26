import 'package:flutter/material.dart';

mixin Helpers {
  void snack(texto, BuildContext context)
  {
    debugPrint('$texto');
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$texto')));
  }
}