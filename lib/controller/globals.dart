library avme_wallet;

import 'package:avme_wallet/controller/wallet_manager.dart';
import 'package:web3dart/credentials.dart';

WalletManager walletManager = new WalletManager();
String appTitle = "AVME Wallet";
Wallet wallet;
EthereumAddress eAddress;