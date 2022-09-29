import 'dart:async';

import 'package:avme_wallet/app/src/controller/db/app.dart';
import 'package:decimal/decimal.dart';
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
  static Map<String, List<ChartData>> chartData = {};

  void _init() async {
    List<String> tokens = Coins.list.map((token) => token.name.toUpperCase()).toList();
    // previewWeek = await WalletDB.viewOverviewDays(tokens, 30);
    chartData = await WalletDB.viewOverviewDaysDetails(tokens, 30);
    previewWeek = chartData.map((key, value) =>
      MapEntry(key, value.map((e) =>
        MarketData(
          dateTime: e.x!.millisecondsSinceEpoch,
          tokenName: key,
          value: Decimal.parse(e.open!.toString())
        )).toList()
      )
    );
    init.complete(true);
  }
}

class ChartData {
  ChartData({this.x, this.open, this.close, this.low, this.high});
  final DateTime? x;
  final double? open;
  final double? close;
  final double? low;
  final double? high;
}