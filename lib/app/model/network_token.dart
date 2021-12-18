import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

class NetworkToken extends ChangeNotifier
{
  Decimal _value = Decimal.zero;

  void updateToken(Decimal value) {
    this._value = value;
    notifyListeners();
  }

  String get value => this._value.toString();
  Decimal get decimal => this._value;
}