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
  String address = "";
  BigInt _networkTokenBalance = BigInt.zero;

  int slot = 0;
  int derived = 0;
  String title = "title not set";

  double networkBalance = 0;
  double currencyTokenBalance = 0;


  Map<String,Map<String,dynamic>> tokensBalanceList = {};

  void updateTokens(String key, Map tokenBalance) {
    tokensBalanceList[key] = tokenBalance;
  }

  set updateAccountBalance(BigInt value)
  {
    _networkTokenBalance = value;
  }

  String tokenBalance({String name = "AVME testnet"})
  {
    if(tokensBalanceList.containsKey(name))
    {
      if(tokensBalanceList[name]['balance'].toDouble() != 0) return tokensBalanceList[name]['balance'].toString();
      else return "0.00";
    }
    return "0.00";
  }
  String tokenWei({String name = "AVME testnet"})
  {
    if(tokensBalanceList.containsKey(name))
    {
      if(tokensBalanceList[name]['wei'].toDouble() != 0) return weiToFixedPoint(tokensBalanceList[name]['wei'].toString());
      else return "0";
    }
    return "0";
  }

  String get balance {
    if(_networkTokenBalance.toDouble() != 0) return weiToFixedPoint(_networkTokenBalance.toString());
    else return "0";
  }

  BigInt get networkTokenBalance => _networkTokenBalance;
}

