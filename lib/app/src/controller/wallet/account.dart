import 'dart:async';
import 'dart:convert';

import 'package:avme_wallet/app/src/controller/threads.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';
import 'package:flutter/cupertino.dart';
import 'package:web3dart/web3dart.dart';

import 'package:avme_wallet/app/src/controller/ui/popup.dart';
import 'package:avme_wallet/app/src/helper/enums.dart';
import 'package:avme_wallet/app/src/helper/file_manager.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/balance.dart';

class AccountData {
  final Wallet data;
  final String title;
  final int slot;
  final int derived;
  EthereumAddress? ethereumAddress;
  late String address;
  List<BalanceInfo> balance = [];
  /// Anywhere in the app you can wait if the information is ready
  ///to be used...
  /// You can also use : hasAddress.future.asStream
  Completer<bool> hasAddress = Completer();

  BalanceInfo get getPlatformBalance => balance.first;

  AccountData(this.data, this.title, this.slot, this.derived) {
    insert(data);
  }

  void updateToken(double qtd, double inCurrency, BigInt raw, int pos)
  {
    print("updateToken $qtd, $inCurrency, $raw");
    BalanceInfo balance = this.balance[pos];
    balance.qtd = qtd;
    balance.inCurrency = inCurrency;
    balance.raw = raw;
    Account.notify();
  }

  void insert(Wallet _data) async
  {
    ethereumAddress = await _data.privateKey.extractAddress();
    address = ethereumAddress!.hex;
    ///Some other useful data to know instantly
    ///Pull a list of tokens and set a list of Balance to track

    ///...code
    ///...code
    ///...code

    ///Finishing the completer in case anywhere is waiting for the data
    ///to be ready

    hasAddress.complete(true);
  }
}

class Account extends ChangeNotifier
{
  static final Account _self = Account._internal();

  factory Account() => _self;

  List<AccountData> accounts = [];
  Completer<List> rawAccounts = Completer();

  static const String filename = 'accounts.json';
  static final String folder = AppRootFolder.Accounts.name;

  int selected = 0;

  Account._internal() {
    _init();
  }

  void _init() async {
    bool exists = await FileManager.fileExists(folder, filename);
    Print.warning("$folder/$filename: $exists");
    if(!exists)
    {
      await FileManager.writeString(folder, filename, []/*jsonEncode([])*/);
      rawAccounts.complete([]);
      return;
    }
    Object source = await FileManager.readFile(folder, filename);
    if(source is String)
    {
      // rawAccounts = jsonDecode(source);
      rawAccounts.complete(jsonDecode(source) as List);
    }
    else if (source is List)
    {
      rawAccounts.complete(source);
    }
    Print.warning("Account.init: ${source.runtimeType}");
    notify();
  }

  static notify()
  {
    _self.notifyListeners();
  }

  static int currentSelectedId() => _self.selected;

  ///Changes current working account
  static change(int id)
  {
    _self.selected = id;
  }

  ///Returns current working account
  static AccountData current() {
    return _self.accounts[_self.selected];
  }

  ///Used only for consumer/selector
  AccountData get currentSelected
  {
    return accounts[selected];
  }

  static Future<bool> add(Map entry, Wallet? wallet) async {
    // List accounts = await _self.accounts.future;
    if(!validator(entry))
    {
      Print.error("Error at Account.add: Malformed param key");
      return false;
    }
    List account = await _self.rawAccounts.future;
    account.add(entry);
    bool didSave = await FileManager.writeString(folder, filename, jsonEncode(account));
    if(!didSave) {
      throw "Error at Account.add: Could not save the account's data";
    }

    /// Wallet can be null when testing the saving to file, otherwise
    ///is a full imported or created account with credentials
    ///besides that if Account.accounts is null the app has not been
    ///initialized, perhaps an App State could solve that... (please no!)
    if(wallet != null)
    {
      // List<AccountData> _accounts = [];
      // if(_self.accounts.isNotEmpty)
      // {
      //   _accounts = _self.accounts;
      // }
      AccountData account = AccountData(wallet, entry["title"], entry["slot"], entry["derived"]);
      await account.hasAddress.future;
      _self.accounts.add(account);

      // _self.accounts = _accounts;
    }

    _self.rawAccounts = Completer()
      ..complete(account);
    notify();
    return true;
  }

  static bool validator(Map entry) {
    List<String> keys = [
      "slot",
      "title",
      "derived",
      "data",
    ];
    int score = 0;
    for(String key in entry.keys)
    {
      if(keys.contains(key))
      {
        score++;
      }
    }
    if(score == (keys.length))
    {
      return true;
    }
    // Print.printError("Score: $score, Total: ${keys.length}");
    return false;
  }

  static Future<bool> remove(Map entry) async
  {
    bool isValid = validator(entry);
    if(!isValid)
    {
      throw "Error at Account.remove: Invalid keys";
    }

    List account = await _self.rawAccounts.future;
    bool didRemove = account.remove(entry);
    if(!didRemove) {
      throw "Error at Account.remove: Could not find account";
    }

    bool didSave = await FileManager.writeString(folder, filename, jsonEncode(account));

    if(!didSave) {
      throw "Error at Account.remove: Could not save the account's data";
    }
    // accounts = Completer()
    //   ..complete(account);
    _self.rawAccounts = Completer()
      ..complete(account);
    return true;
  }

  static Future load(String password) async
  {
    List _accounts = await _self.rawAccounts.future;
    Print.warning("accounts? $_accounts");
    // ProgressDialog init = ProgressDialog();
    ProgressDialog progress = await ProgressPopup.display();
    progress.label.value = "Initializing ${_accounts.length > 1 ? "Accounts" : "Account"}...";
    Threads threads = Threads();

    ThreadMessage threadMessage = ThreadMessage(
      caller: "Accounts.load",
      function: wrapLoad,
      params: [_accounts, password]
    );
    List<AccountData>? accountList;
    Completer<bool> processEnded = Completer();
    threads.addToPool(id: 0, task: threadMessage)
      .listen((event) {
        if(event is Map)
        {
          ///This key is provided when the function finished processing!
          ///and its returning value inside "message" key
          if(!event.containsKey("process-id"))
          {
            // progress.label.value = event["label"];
            progress.percentage.value = event["percentage"];
          }
          else
          {
            accountList = event["message"];
          }
        }
      })
      ..onDone(() {
        _self.accounts = accountList!;
      processEnded.complete(true);
    });

    await processEnded.future;
    // await Future.delayed(Duration(seconds: 1000));
    ProgressPopup.dismiss();
  }

  static Future<List<AccountData>> wrapLoad(List params, ThreadWrapper wrap) async
  {
    ///If the process will be infinite, please use prepareOperation to avoid
    ///CancellableOperation[self] = null
    await prepareOperation(wrap);

    List _accounts = params[0];
    String password = params[1];
    int current = 1;
    int total = _accounts.length;
    Print.approve("estou no wrapLoad");
    Print.mark("pw $password, current $current, $total, $_accounts");
    List<AccountData> fAccounts = [];
    // for(Map entry in _accounts)
    await Future.forEach(_accounts, (entry) async
    {
      if(entry is Map)
      {
        String label = "$current/$total ${_accounts.length} ${entry["title"]}";
        int percentage = ((100 / total) * current).toInt();
        wrap.send({"label": label, "percentage": percentage});
        String encoded = jsonEncode(entry["data"]);
        Wallet wallet = Wallet.fromJson(encoded, password);
        AccountData accountData = AccountData(wallet, entry["title"], entry["slot"], entry["derived"]);
        await accountData.hasAddress.future;
        fAccounts.add(accountData);
        current++;
      }
    });
    return fAccounts;
  }
}