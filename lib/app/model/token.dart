import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

class Token extends ChangeNotifier
{
  Map<String, Decimal> _tokenValues = {};

  void updateToken(String key, Decimal value) {
    if(this._tokenValues[key] != value)
    {
      _tokenValues[key] = value;
      notifyListeners();
    }
  }

  void removeToken(String key)
  {
    _tokenValues.remove(key);
  }

  Decimal decimal(String key) => _tokenValues[key];
  String tokenValue(String key) => _tokenValues[key].toString();
}