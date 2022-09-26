import 'dart:async';

import 'package:avme_wallet/app/src/controller/db/app.dart';
import 'package:flutter/foundation.dart';

import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/model/db/market_data.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';

class MarketInfo extends ChangeNotifier{
  static final MarketInfo _self = MarketInfo._internal();
  factory MarketInfo() => _self;

  MarketInfo._internal()
  {
    _init();
  }

  Completer<bool> init = Completer();
  static Map<String, List<MarketData>> previewWeek = {};
  
  void _init() async {
    List<String> tokens = Coins.list.map((token) => token.name.toUpperCase()).toList();
    previewWeek = await WalletDB.viewOverviewDays(tokens, 14);
    // Print.ok("[PREVIEW WEEK]");
    // Print.ok("$previewWeek");
    init.complete(true);
  }
}