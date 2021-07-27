import 'dart:isolate';

import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:avme_wallet/app/controller/wallet_manager.dart';
import 'package:avme_wallet/app/model/boxes.dart';
import 'package:avme_wallet/app/model/metacoin.dart';
import 'package:avme_wallet/app/model/token.dart';
import 'package:avme_wallet/app/model/token_chart.dart';
import 'package:avme_wallet/app/model/transaction_information.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:web3dart/credentials.dart';

import 'account_item.dart';

class AppLoadingState extends ChangeNotifier
{
  int _progress = 0;
  int _total = 0;
  bool _inProgress = true;
  bool _loadedAccounts = false;
  bool _defaultAccount = false;

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

  set defaultAccountLoaded (bool value)
  {
    _defaultAccount = value;
    notifyListeners();
  }

  int get progress => _progress;
  int get total => total;
  bool get accountsWasLoaded => _loadedAccounts;
  bool get defaultAccountWasLoaded => _defaultAccount;
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

  Map<int,AccountObject> _accountList = {};
  set setAccountList (Map<int,AccountObject> value) => _accountList = value;
  Map<int,AccountObject> get accountList => _accountList;

  AccountObject get currentAccount => accountList[currentWalletId];

  String appTitle = "AVME Wallet";

  int _currentWalletId;
  set changeCurrentWalletId (int value) => _currentWalletId = value;
  int get currentWalletId => _currentWalletId;

  Map<String, Isolate> services = {};

  TransactionInformation lastTransactionWasSucessful = new TransactionInformation();

  Token token = Token();
  MetaCoin metaCoin = MetaCoin();

  Box<TokenChart> dashboardBox = Boxes.getHistory();

  TokenChart dashboard = TokenChart();
  
  void init()
  {
    _walletManager.setFileManager(fileManager);
  }

  void displayTokenChart()
  {
    if(dashboardBox.length > 0)
    {
      dashboard = dashboardBox.values.elementAt(0);
    }
  }

  void wasLastTransactionInformationSuccessful()
  {
    lastTransactionWasSucessful.addListener(() {
      notifyListeners();
    });
  }

  void resetLastTransactionInformation()
  {
    this.lastTransactionWasSucessful = new TransactionInformation();
  }

  void addToAccountList(int pos,AccountObject account)
  {
    accountList[pos] = account;
    //First we get an ordered list of keys, and rebuild in loop the entire list...
    List keys = accountList.keys.toList()..sort();
    Map<int,AccountObject> localAccountList = {};
    keys.forEach((key) => localAccountList[key] = accountList[key]);
    setAccountList = localAccountList;
  }

  void killService(String key)
  {
    if(services.containsKey(key))
    {
      print("killService($key)");
      services[key].kill(priority: Isolate.immediate);

      services.remove(key);
    }
  }

  ///Listeners

  void watchBalanceUpdates()
  {
    currentAccount.addListener(() {
      notifyListeners();
    });
  }

  void watchMetaCoinValueChanges()
  {
    metaCoin.addListener(() {
      notifyListeners();
    });
  }

  void watchTokenValueChanges()
  {
    token.addListener(() {
      notifyListeners();
    });
  }

  void watchAccountBalanceUpdates(int pos)
  {
    accountList[pos].addListener(() {
      notifyListeners();
    });
  }
}