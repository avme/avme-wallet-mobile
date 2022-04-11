import 'dart:isolate';

import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:avme_wallet/app/controller/wallet_manager.dart';
import 'package:avme_wallet/app/model/token.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'active_contracts.dart';
import 'network_token.dart';
import 'transaction_information.dart';
import 'package:web3dart/credentials.dart';
import 'account_item.dart';
import 'accounts_state.dart';

class AvmeWallet extends ChangeNotifier
{
  final FileManager fileManager;
  WalletManager walletManager;
  Wallet _w3dartWallet;
  Map<int,AccountObject> _accountList = {};
  String appTitle = "AVME Wallet";
  int _currentWalletId;
  Map<String, Isolate> services = {};
  // Token token = Token();
  NetworkToken networkToken = NetworkToken();
  AccountsState accountsState = AccountsState();
  bool debugMode = false;
  bool debugPanel = false;
  final ActiveContracts activeContracts;

  AvmeWallet(this.fileManager, this.activeContracts){
    this.debugMode = env["DEBUG_MODE"] == "TRUE" ? true : false;
    this.walletManager = WalletManager(this.fileManager);
  }

  Wallet get getW3DartWallet => _w3dartWallet;

  Map<int,AccountObject> get accountList => _accountList;

  AccountObject get currentAccount => _accountList[currentWalletId];

  int get currentWalletId => _currentWalletId;

  set w3dartWallet (Wallet value) => _w3dartWallet = value;

  set setAccountList (Map<int,AccountObject> value) {
    _accountList = value;
    notifyListeners();
  }

  set changeCurrentWalletId (int value){
    _currentWalletId = value;
    notifyListeners();
  }

  TransactionInformation lastTransactionWasSucessful = new TransactionInformation();

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
  void watchNetworkTokenValueChanges()
  {
    networkToken.addListener(() {
      notifyListeners();
    });
  }

  void watchAccountsStateChanges()
  {
    accountsState.addListener(() {
      notifyListeners();
    });
  }

  void updateAccountObject(id, AccountObject accountObject)
  {
    accountList[id] = accountObject;
    notifyListeners();
  }

  void setCurrentWallet(int id)
  {
    changeCurrentWalletId = id;
    walletManager.restartTokenServices(this);
  }

  void toggleDebugPanel()
  {
    debugPanel = !debugPanel;
    notifyListeners();
  }

  Future<bool> login(String password, BuildContext context, {bool display = false}) async {
    bool auth = false;
    ValueNotifier<int> percentage = ValueNotifier(0);
    ValueNotifier<String> label = ValueNotifier("Loading...");
    List<ValueNotifier> loadingNotifier = [
      percentage,
      label
    ];
    if(display)
      await showDialog(context: context, builder: (_) =>
        StatefulBuilder(
          builder: (builder, setState){
            return ProgressPopup(
              listNotifier: loadingNotifier,
              future: _initFirstLogin(context, password, loadingNotifier, display)
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
    else
      auth = (await _initFirstLogin(context, password, loadingNotifier, display))[0];
    return auth;
  }

  Future<List> _initFirstLogin(BuildContext context, String password, List<ValueNotifier> loadingNotifier, bool display) async
  {
    loadingNotifier[0].value = 10;
    loadingNotifier[1].value = "Authenticating...";
    Map authMap = await walletManager.authenticate(password, this);
    if(authMap["status"] == 200)
    {
      loadingNotifier[0].value = 90;
      loadingNotifier[1].value = "Retrieving data from Web...";
      await walletManager.restartTokenServices(this);
      await Future.delayed(Duration(milliseconds: 250));
      if(display)
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

class WalletInterface {

  static BuildContext _currentContext = NavigationService.globalContext.currentContext;

  AvmeWallet _wallet;

  List<String> _enabledTokens = [];
  Decimal _avaxRaw = Decimal.zero;
  String _avaxValue = '';
  NetworkToken _networkToken;
  Token _tokens;
  List<AccountObject> _accounts;

  final bool listen;

  WalletInterface({this.listen = true}) {
    this._wallet = Provider.of<AvmeWallet>(_currentContext, listen: this.listen);
    _enabledTokens = this.wallet.activeContracts.tokens;
    _networkToken = this.wallet.networkToken;
    _avaxRaw = this._networkToken.decimal;
    _avaxValue = this._networkToken.value;
    _tokens = this.wallet.activeContracts.token;
    _accounts = this.wallet.accountList.entries.map((e) => e.value).toList();
  }

  AvmeWallet get wallet => this._wallet;
  List<String> get enabledTokens => this._enabledTokens;

  Decimal get avaxRaw => this._avaxRaw;
  String get avaxValue => this._avaxValue;
  String tokenValue(String tokenName) => _tokens.tokenValue(tokenName);
  Decimal tokenRaw(String tokenName) => _tokens.decimal(tokenName);
  List<AccountObject> get accounts => this._accounts;
}