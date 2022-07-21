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

import 'balance.dart';

class AccountData {
  final Wallet data;
  final String title;
  final int slot;
  final int derived;
  EthereumAddress? ethereumAddress;
  String? address;
  List<Balance> balance = [];
  PlatformBalance platform = PlatformBalance();
  /// Anywhere in the app you can wait if the information is ready
  ///to be used...
  /// You can also use : hasAddress.future.asStream
  Completer<bool> hasAddress = Completer();
  AccountData(this.data, this.title, this.slot, this.derived) {
    insert(data);
  }

  void updateToken(List<Balance> value)
  {
    this.balance = value;
    Print.mark("${this.address} -> AccountData.updateToken");
  }

  void updatePlatform(PlatformBalance value)
  {
    this.platform = value;
    Print.mark("${this.address} -> AccountData.updatePlatform");
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

// Future<EthereumAddress> get address => _data.privateKey.extractAddress();
}

class Account extends ChangeNotifier
{
  static final Account _self = Account._internal();

  factory Account() => _self;

  static List<AccountData> accounts = [];
  static Completer<List> rawAccounts = Completer();

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
  }

  ///Changes current working account
  static change(int id)
  {
    _self.selected = id;
  }

  ///Returns current working account
  static AccountData current() {
    return accounts[_self.selected];
  }

  static Future<bool> add(Map entry, Wallet? wallet) async {
    // List accounts = await _self.accounts.future;
    if(!validator(entry))
    {
      Print.error("Error at Account.add: Malformed param key");
      return false;
    }
    List account = await rawAccounts.future;
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
      List<AccountData> _accounts = [];
      if(accounts != null)
      {
        _accounts = accounts;
      }

      _accounts.add(AccountData(wallet, entry["title"], entry["slot"], entry["derived"]));
      accounts = _accounts;
    }

    rawAccounts = Completer()
      ..complete(account);
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

    List account = await rawAccounts.future;
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
    rawAccounts = Completer()
      ..complete(account);
    return true;
  }

  static Future load(String password) async
  {
    List _accounts = await rawAccounts.future;
    Print.warning("accounts? ${_accounts}");
    ProgressDialog init = ProgressDialog();
    ProgressDialog progress = ProgressPopup.display();
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
        Print.approve(event.toString());
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
        accounts = accountList!;
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