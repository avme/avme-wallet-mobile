import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:hive/hive.dart';

part 'token_chart.g.dart';

@HiveType(typeId: 0)
class TokenChart extends HiveObject
{
  @HiveField(0)
  Map<int, String> tokenList = {};

  void addToList(int unixDate, String priceUsd)
  {
    this.tokenList[unixDate] = priceUsd;
  }

  List<dynamic> getHighestValue()
  {
    double _highest = 0;
    int _key;
    double _value;
    tokenList.forEach((key, value) {
      _value = double.parse(value);
      if(_value > _highest)
      {
        _highest = _value;
        _key = key;
      }
    });
    return [_key, _highest];
  }

  List<dynamic> getHighestDay()
  {
    double _highest = 0;
    int _key = 0;
    double _value;
    tokenList.forEach((key, value) {
      _value = double.parse(value);
      if(key > _key)
      {
        _highest = _value;
        _key = key;
      }
    });
    return [_key, _highest];
  }
}