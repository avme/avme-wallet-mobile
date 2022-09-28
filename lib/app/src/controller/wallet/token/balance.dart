import 'package:avme_wallet/app/src/controller/wallet/token/token.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';
import 'package:flutter/material.dart';

abstract class BalanceInfo extends ChangeNotifier {
  final String name;
  final String symbol;
  final String address;
  final int decimals;
  double _inCurrency = 0.0;
  double _qtd = 0.0;
  BigInt _raw = BigInt.zero;

  double get inCurrency => _inCurrency;
  double get qtd => _qtd;
  BigInt get raw => _raw;

  set inCurrency(double newValue)
  {
    print("$name| BalanceInfo.inCurrency from \"$_inCurrency\" to \"$newValue\"");
    if(_inCurrency != newValue)
    {
      _inCurrency = newValue;
      notifyListeners();
    }
  }

  set qtd(double newValue)
  {
    print("$name| BalanceInfo.qtd from \"$_qtd\" to \"$newValue\"");
    if(_qtd != newValue)
    {
      _qtd = newValue;
      notifyListeners();
    }
  }

  set raw(BigInt newValue)
  {
    print("$name| BalanceInfo.raw from \"$_raw\" to \"$newValue\"");
    if(_raw != newValue)
    {
      _raw = newValue;
      notifyListeners();
    }
  }

  BalanceInfo(this.name, this.symbol, this.address, {required this.decimals});

  @override
  String toString(){
    return "BalanceInfo("
      "name: "
      "'${this.name}', "
      "symbol: "
      "'${this.symbol}', "
      "address: "
      "'${this.address}', "
      "inCurrency: "
      "'${this.inCurrency}', "
      "qtd: "
      "'${this.qtd}', "
      "raw: "
      "'${this.raw}', "
      "decimals: "
      "'${this.decimals}'"
    ;
  }

  Token get token => Coins.list.firstWhere((token) => token.name == this.name);

  factory BalanceInfo.fromToken(Token token) {
    throw UnimplementedError();
  }
}

///Default definition for every Coin besides the platform currency
class Balance extends BalanceInfo {
  Balance(String name, String symbol, String address, {required int decimals}) : super(name, symbol, address, decimals: decimals);

  @override
  factory Balance.fromToken(Token token) {
    return Balance(token.name, token.symbol, token.contractAddress, decimals: token.decimals);
  }

  @override
  String toString()
  {
    return super.toString().replaceFirst("BalanceInfo", "Balance");
  }
}

class PlatformBalance extends BalanceInfo {
  PlatformBalance(String name, String symbol, String address, {required int decimals}) : super(name, symbol, address, decimals: decimals);


  @override
  String toString()
  {
    return super.toString().replaceFirst("BalanceInfo", "PlatformBalance");
  }

  @override
  factory PlatformBalance.fromToken(Token token) {
    return PlatformBalance(token.name, token.symbol, token.contractAddress, decimals: token.decimals);
  }
}