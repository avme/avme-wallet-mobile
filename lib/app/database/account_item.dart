import 'package:web3dart/credentials.dart';
class AccountItem {
  AccountItem({
    this.accountPath,
    this.account,
    this.address,
  });

  String accountPath;
  Wallet account;
  String address;
}