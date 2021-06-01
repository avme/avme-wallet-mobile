library avme_wallet;

import 'package:avme_wallet/app/controller/wallet_manager.dart';
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

List<AccountItem> accountList = [];

WalletManager walletManager = new WalletManager();
String appTitle = "AVME Wallet";
Wallet wallet;
EthereumAddress eAddress;
