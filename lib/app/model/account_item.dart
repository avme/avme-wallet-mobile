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

  double networkBalance = 0;
  double currencyTokenBalance = 0;

  ///List must follow this architecture...
  ///{<BigInt> wei:00000000, <Double>balance:1000.00}
  Map<String,Map<String,dynamic>> tokensBalanceList = {};

  void updateTokens(String key, Map tokenBalance) {
    tokensBalanceList[key] = tokenBalance;
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

  BigInt get waiBalance => _weiBalance;
  BigInt get rawTokenBalance => _tokenWeiBalance;
}

