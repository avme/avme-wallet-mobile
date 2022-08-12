import 'dart:async';

import 'package:avme_wallet/app/src/controller/controller.dart';
import 'package:avme_wallet/app/src/helper/enums.dart';
import 'package:avme_wallet/app/src/helper/file_manager.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

///Describe an list of Active CoinsTokens
///Add, Remove, Etc
class Coins extends ChangeNotifier {
  static final Coins _self = Coins._internal();
  factory Coins() => _self;

  ///Coin's value, Platform is the Network's coin
  static List<CoinData> list = [];
  static Platform platform = Platform();

  Completer<bool> init = Completer();
  Completer<List> _rawCoinsData = Completer();
  String _file = "coins.json";
  bool fileExists = false;

  Coins._internal()
  {
    _init();
  }

  void _init() async {
    Object coinList = await FileManager.readFile(AppRootFolder.Tokens.name, _file);
    if(coinList is List)
    {
      fileExists = true;
    }
    else
    {
      Print.mark("[Coins] Generating file ${AppRootFolder.Tokens.name}/$_file...");
      coinList = <Map>[
        {
          "name": "AVME",
          "symbol": "AVME",
          "address": "0x1ecd47ff4d9598f89721a2866bfeb99505a413ed",
          "test-address": "0x02aDedcfe78757C3d0a545CB0Cbd78a7d19eEE4f",
          "decimals": "18",
          "abi": "",
          "image": "assets/avme_logo.png",
          "active": true
        },
        {
          "name": "AVME testnet",
          "symbol": "AVME",
          "address": "0x5FbDB2315678afecb367f032d93F642f64180aa3",
          "test-address": "0x5FbDB2315678afecb367f032d93F642f64180aa3",
          "decimals": "18",
          "abi": "",
          "image": "assets/avme_logo.png",
          "active": true
        }
      ];
      await FileManager.writeString(AppRootFolder.Tokens.name, _file, coinList);
    }
    for(Map coinData in coinList)
    {
      String address = coinData["address"];
      if(dotenv.env["NETWORK_URL"]!.contains('test'))
      {
        address = coinData["test-address"];
      }
      CoinData data = CoinData(
        coinData["name"],
        coinData["symbol"],
        address,
        coinData["test-address"],
        int.parse(coinData["decimals"]),
        coinData["image"],
        coinData["abi"],
        active: coinData["active"]
      );

      list.add(data);
    }
    _rawCoinsData.complete(coinList);
    init.complete(true);
  }

  static Future<List> listRaw() async {
    return await _self._rawCoinsData.future;
  }

  List<CoinData> getCoins() => list;
  Platform getPlatform() => platform;

  ///When it receives -1 it means the API refused to return
  static void updateValue(String name, double currency, BigInt ether)
  {
    Print.approve("$name, $currency");
    if(currency == -1.0 || name.contains('testnet')) { return; }
    // Decimal _value = Decimal.fromJson(value.toStringAsFixed(6));

    dynamic coin;
    if(name == "platform")
    {
      coin = platform;
    }
    else
    {
      coin = list.where((_coin) => _coin.name == name).first;
    }

    if(coin.value != currency)
    {
      coin.value = currency;
      coin.ether = ether;
      ///Notifying any listener widget Consumer/Provider using this singleton
      _self.notifyListeners();
    }
  }

  static Future<bool> add(CoinData data) async
  {
    try {
      List<CoinData> _currentTokens = list;
      _currentTokens.add(data);
      List raw = await asListOfMap(refList: _currentTokens);
      await FileManager.writeString(AppRootFolder.Tokens.name, _self._file, raw);
    }
    catch(e) {
      return false;
    }
    return true;
  }

  static Future<bool> remove(CoinData data) async
  {
    try {
      List<CoinData> _currentTokens = list;
      _currentTokens.removeWhere((coin) => coin == data);
      List raw = await asListOfMap(refList: _currentTokens);
      await FileManager.writeString(AppRootFolder.Tokens.name, _self._file, raw);
    }
    catch(e) {
      return false;
    }
    return true;
  }

  static Future<List> asListOfMap({List<CoinData>? refList}) async
  {
    List<CoinData> _currentTokens = refList ?? list;
    List _ret = [];
    for(CoinData coin in _currentTokens)
    {
      _ret.add(
        {
          "name": coin.name,
          "symbol": coin.symbol,
          "address": coin.address,
          "test-address": coin.testAddress,
          "decimals": coin.decimals.toString(),
          "abi": coin.abi,
          "image": coin.image,
          "active": coin.active
        }
      );
    }
    return _ret;
  }
}

///Properties of Coin's Symbol, Name, ABI
class CoinData {
  final String name;
  final String symbol;
  final String address;
  final String testAddress;
  final int decimals;
  final String image;
  final String abi;
  late bool active;
  BigInt ether = BigInt.zero;
  double value = 0;

  CoinData(this.name, this.symbol, this.address, this.testAddress, this.decimals, this.image, this.abi, {this.active = false});
}

class Platform {
  BigInt ether = BigInt.zero;
  double value = 0;
}