import 'package:flutter/foundation.dart';

class Token extends ChangeNotifier
{
  String value;

  void updateToken(String value) {
    this.value = value;
    notifyListeners();
  }
}