import 'package:flutter/foundation.dart';

class Token extends ChangeNotifier
{
  Map tokenValues = {};

  void updateToken(String key, String value) {
    tokenValues[key] = value;
    notifyListeners();
  }
}