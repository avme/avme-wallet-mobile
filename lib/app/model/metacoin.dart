import 'package:flutter/foundation.dart';

class MetaCoin extends ChangeNotifier
{
  String value;

  void updateToken(String value) {
    this.value = value;
    notifyListeners();
  }
}