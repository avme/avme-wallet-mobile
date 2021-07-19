import 'package:flutter/foundation.dart';

class Token extends ChangeNotifier
{
  String value = "0";

  void updateToken(String value) {
    this.value = value;
    notifyListeners();
  }
}