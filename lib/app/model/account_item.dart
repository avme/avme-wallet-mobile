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
  double _balance;

  set updateAccountBalance(double value)
  {
    _balance = value;
    notifyListeners();
  }
  double get balance => _balance;
}

