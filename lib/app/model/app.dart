import 'dart:collection';

import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:avme_wallet/app/controller/wallet_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:web3dart/credentials.dart';

import 'account_item.dart';

class AppLoadingState extends ChangeNotifier{
  int _progress = 0;
  int _total = 0;
  bool _inProgress = true;
  bool _loadedAccounts = false;

  set progress (int value)
  {
    _progress = value;
    notifyListeners();
  }

  set total (int value)
  {
    _total = value;
    notifyListeners();
  }

  set inProgress (bool value)
  {
    _inProgress = value;
    notifyListeners();
  }

  set loadedAccounts (bool value)
  {
    _loadedAccounts = value;
    notifyListeners();
  }

  int get progress => _progress;
  int get total => total;
  bool get accountsWasLoaded => _loadedAccounts;
}

class AvmeWallet extends ChangeNotifier
{
  FileManager _fileManager = new FileManager();
  FileManager get fileManager => _fileManager;

  WalletManager _walletManager = new WalletManager();
  WalletManager get walletManager => _walletManager;

  Wallet _w3dartWallet;
  Wallet get getW3DartWallet => _w3dartWallet;
  set w3dartWallet (Wallet value) => _w3dartWallet = value;

  EthereumAddress _eAddress;
  set eAddress (EthereumAddress value) => _eAddress = value;

  Map<int,AccountItem> _accountList = {};
  set setAccountList (Map<int,AccountItem> value) => _accountList = value;
  Map get accountList => _accountList;

  String appTitle = "AVME Wallet";

  //Implement some init functions here
  void init()
  {
    _walletManager.setFileManager(fileManager);
  }

  void addToAccountList(int pos,AccountItem account)
  {
    accountList[pos] = account;
    //First we get an ordered list of keys, and rebuild in loop the entire list...
    List keys = accountList.keys.toList()..sort();
    Map<int,AccountItem> localAccountList = {};
    keys.forEach((key) => localAccountList[key] = accountList[key]);
    setAccountList = localAccountList;
  }
}