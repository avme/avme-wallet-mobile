import 'dart:async';
import 'package:avme_wallet/app/src/controller/network/connection.dart';
import 'package:avme_wallet/app/src/controller/network/network.dart';
import 'package:avme_wallet/app/src/controller/routes.dart';
import 'package:avme_wallet/app/src/controller/settings.dart';
import 'package:avme_wallet/app/src/controller/wallet/account.dart';
import 'package:avme_wallet/app/src/controller/wallet/authentication.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:flutter/material.dart';

import 'app/src/controller/threads.dart';
import 'app/src/controller/wallet/token/coins.dart';
import 'app/src/controller/wallet/wallet.dart';
import 'app/src/helper/file_manager.dart';
import 'app/src/helper/size.dart';
import 'app/src/model/services.dart';


class App extends ChangeNotifier {
  static final App _self = App._internal();
  factory App() => _self;

  ///By Default App.ready could return false, since theres no
  ///try & catch exception arranged it returns true
  static Completer<bool> ready = Completer();
  static Completer<bool> done = Completer();
  static bool exists = false;

  App._internal()
  {
    Print.warning("Starting...");
    Network.isTestnet();
    _init();
  }

  /*
    Please implement every initializer Completer<bool> of every class
    and make a sum of every bool before finalize the loading...
  */
  void _init () async {
    FileManager().generateStructure();
    Threads threads = Threads();
    Services();
    Wallet wallet = Wallet();
    Authentication authentication = Authentication();
    Settings settings = Settings();
    Coins coins = Coins();
    await threads.init.future;
    await wallet.init.future;
    await settings.init.future;
    await authentication.init.future;
    await coins.init.future;

    Print.warning("[Wallet Exists] ${Wallet.exists}");

    ///Initializing Network token values...
    bool recoverValue = await Network.observeValueChanges();
    if(recoverValue)
    {
      await Network.updateCoinHistory();
      await Network.observeTodayHistory();
    }
    Print.warning("App._init ready");
    ready.complete(true);
  }

  void frameCallback(Duration callback) async
  {
    Print.mark("App.frameCallback ${callback.inMilliseconds}ms");

    ///Reference of running services
    DeviceSize deviceSize = DeviceSize();
    deviceSize.init(Routes.globalContext.currentContext!);
    Connection conn = Connection();
    conn.trackerOfConnectionWidget();

    List<bool> complete = await Future.wait([
      deviceSize.ready.future,
    ]);
    int id = 0;
    for (bool completed in complete)
    {
      if (completed == false) {
        throw "Error at App.doneInit: Failed to initialize ID#$id";
      }
      id++;
    }
    Print.warning("App._init done");
    done.complete(true);
    Print.mark("App.frameCallback done");
  }
}