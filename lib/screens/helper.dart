import 'dart:math';
import 'dart:typed_data';
import 'package:hex/hex.dart';
import 'package:flutter/material.dart';

mixin Helpers {
  void snack(texto, BuildContext context)
  {
    debugPrint('$texto');
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$texto')));
  }
}

String hexRandBytes({int size = 4}) {
  final rng = Random.secure();
  final bytes = Uint8List(size);
  for (var i = 0; i < size; i++) {
    bytes[i] = rng.nextInt(255);
  }
  return HEX.encode(bytes);
}