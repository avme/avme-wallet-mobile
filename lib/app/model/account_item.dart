import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:web3dart/credentials.dart';
class AccountObject
{
  AccountObject({
    this.walletObj,
    this.address,
    this.slot,
    this.derived,
    this.title
  });

  Wallet walletObj;
  String address;
  BigInt _weiBalance;
  BigInt _tokenWeiBalance;

  int slot;
  int derived;
  String title;

  double _currencyBalance = 0;
  double _currencyTokenBalance = 0;

  set currencyBalance(double value)
  {
    _currencyBalance = value;
  }

  set currencyTokenBalance(double value)
  {
    _currencyTokenBalance = value;
  }

  set updateTokenBalance(BigInt value)
  {
    _tokenWeiBalance = value;
  }

  set updateAccountBalance(BigInt value)
  {
    _weiBalance = value;
  }

  String get tokenBalance
  {
    if(_tokenWeiBalance == null) return null;
    if(_tokenWeiBalance.toDouble() != 0) return weiToFixedPoint(_tokenWeiBalance.toString());
    else return "0";
  }

  String get balance {
    if(_weiBalance == null) return null;
    if(_weiBalance.toDouble() != 0) return weiToFixedPoint(_weiBalance.toString());
    else return "0";
  }

  double get currencyTokenBalance
  {
    return _currencyTokenBalance;
  }

  double get currencyBalance
  {
    return _currencyBalance;
  }

  BigInt get waiBalance => _weiBalance;
  BigInt get rawTokenBalance => _tokenWeiBalance;
}

