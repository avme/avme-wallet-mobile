import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:web3dart/credentials.dart';
class AccountObject extends ChangeNotifier
{
  AccountObject({
    this.accountPath,
    this.account,
    this.address,
  });

  String accountPath;
  Wallet account;
  String address;
  BigInt _weiBalance;

  set updateAccountBalance(BigInt value)
  {
    // print("BIG INT:"+value.toString());
    _weiBalance = value;
    notifyListeners();
  }

  String get balance {
    if(_weiBalance == null) return null;
    // print("balance:$_weiBalance");
    if(_weiBalance.toDouble() != 0) return weiToFixedPoint(_weiBalance.toString());
    else return "";
  }

  BigInt get waiBalance => _weiBalance;

}

