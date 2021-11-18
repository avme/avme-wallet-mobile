import 'dart:isolate';

import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:avme_wallet/app/controller/wallet_manager.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'boxes.dart';
import 'metacoin.dart';
import 'token.dart';
import 'token_chart.dart';
import 'transaction_information.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:web3dart/credentials.dart';

import 'account_item.dart';
import 'accounts_state.dart';

class AvmeWallet extends ChangeNotifier
{
  final FileManager fileManager;
  WalletManager walletManager;

  AvmeWallet(this.fileManager){
    print("[AvmeWallet]");
    this.walletManager = WalletManager(this.fileManager);
  }

  Wallet _w3dartWallet;
  Wallet get getW3DartWallet => _w3dartWallet;
  set w3dartWallet (Wallet value) => _w3dartWallet = value;


  Map<int,AccountObject> _accountList = {};
  set setAccountList (Map<int,AccountObject> value) {
    _accountList = value;
    notifyListeners();
  }

  Map<int,AccountObject> get accountList => _accountList;

  AccountObject get currentAccount => _accountList[currentWalletId];

  String appTitle = "AVME Wallet";
  int _currentWalletId;

  set changeCurrentWalletId (int value){
    _currentWalletId = value;
    notifyListeners();
  }

  int get currentWalletId => _currentWalletId;

  Map<String, Isolate> services = {};

  TransactionInformation lastTransactionWasSucessful = new TransactionInformation();

  Token token = Token();
  MetaCoin metaCoin = MetaCoin();
  AccountsState accountsState = AccountsState();

  Box<TokenChart> dashboardBox = Boxes.getHistory();

  TokenChart dashboard = TokenChart();
  
  // void init()
  // {
  //   _walletManager.setFileManager(fileManager);
  // }

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

  void watchAccountsStateChanges()
  {
    accountsState.addListener(() {
      notifyListeners();
    });
  }

  void updateAccountBalance(id, AccountObject accountObject)
  {
    accountList[id] = accountObject;
    notifyListeners();
  }

  void setCurrentWallet(int id)
  {
    changeCurrentWalletId = id;
    walletManager.stopBalanceSubscription(this);
    walletManager.startBalanceSubscription(this);
  }

  Future<bool> login(String password, BuildContext context) async {
    bool auth = false;
    ValueNotifier <String> status = ValueNotifier("Loading - 0%");
    await showDialog(context: context, builder: (_) =>
      StatefulBuilder(
        builder: (builder, setState){
          return ProgressPopup(
            labelNotifier: status,
            future: _initFirstLogin(context, password, status)
              .then((result) {
                auth = result[0];
                return [Text(result[1])];
              }
            ),
            title: "Warning",
          );
        },
      )
    );
    return auth;
  }

  Future<List> _initFirstLogin(BuildContext context, String password, ValueNotifier label) async
  {
    label.value = "10% - Authenticating";
    Map authMap = await walletManager.authenticate(password, this);
    if(authMap["status"] == 200)
    {
      label.value = "90% - Retrieving data from Web";
      await walletManager.startBalanceSubscription(this);
      await Future.delayed(Duration(milliseconds: 250));
      Navigator.of(context).pop();
      return [true];
    }
    else
    {
      //...error
      return [false, authMap["message"]];
    }

  }
}