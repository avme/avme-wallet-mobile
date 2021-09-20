import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:web3dart/credentials.dart';
class AccountObject extends ChangeNotifier
{
  AccountObject({
    this.account,
    this.address,
    this.slot,
    this.derived,
    this.title
  });

  Wallet account;
  String address;
  BigInt _weiBalance;
  BigInt _tokenWeiBalance;

  int slot;
  int derived;
  String title;

  double _currencyBalance;
  double _currencyTokenBalance;

  set currencyBalance(double value)
  {
    _currencyBalance = value;
    notifyListeners();
  }

  set currencyTokenBalance(double value)
  {
    _currencyTokenBalance = value;
    notifyListeners();
  }

  set updateTokenBalance(BigInt value)
  {
    _tokenWeiBalance = value;
    notifyListeners();
  }

  set updateAccountBalance(BigInt value)
  {
    _weiBalance = value;
    notifyListeners();
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

