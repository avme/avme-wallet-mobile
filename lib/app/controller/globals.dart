library avme_wallet;

import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:avme_wallet/app/controller/wallet_manager.dart';
import 'package:avme_wallet/app/database/account_item.dart';
import 'package:web3dart/credentials.dart';

List<AccountItem> accountList = [];

WalletManager walletManager;
String appTitle = "AVME Wallet";
Wallet wallet;
EthereumAddress eAddress;
FileManager fileManager;
bool dashboardLoad = false;

void setWalletManager(FileManager fileManager)
{
  walletManager = new WalletManager();
  walletManager.setFileManager(fileManager);
}