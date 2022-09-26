import 'dart:async';

import 'package:avme_wallet/app/src/controller/controller.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/token.dart';
import 'package:avme_wallet/app/src/helper/enums.dart';
import 'package:avme_wallet/app/src/helper/file_manager.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:avme_wallet/app/src/helper/utils.dart';

///Describe an list of Active CoinsTokens
///Add, Remove, Etc
class Coins extends ChangeNotifier {
  static final Coins _self = Coins._internal();
  factory Coins() => _self;

  /// This array stores both tokens and the platform being hosted
  ///use the first in index to recover the platform token info
  ///when operating!
  ///
  /// Alternately you can use Coins.getPlatformToken to avoid
  ///confusion...
  static List<Token> list = [];
  static Token get getPlatformToken => list.first;

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
          "test-address": "0xa5f05f0403F56ddF9FB90ebAA2610c3166994016",
          "decimals": "18",
          "abi": "",
          "image": "assets/avme_logo.png",
          "active": true
        },
        // {
        //   "name": "AVME testnet",
        //   "symbol": "AVME",
        //   "address": "0x5FbDB2315678afecb367f032d93F642f64180aa3",
        //   "test-address": "0x5FbDB2315678afecb367f032d93F642f64180aa3",
        //   "decimals": "18",
        //   "abi": "",
        //   "image": "assets/avme_logo.png",
        //   "active": true
        // }
      ];
      await FileManager.writeString(AppRootFolder.Tokens.name, _file, coinList);
    }
    bool inTestnet = Utils.inTestnet();
    for(Map coinData in coinList)
    {
      CoinData data = CoinData(
        coinData["name"],
        coinData["symbol"],
        coinData["address"],
        coinData["test-address"],
        int.parse(coinData["decimals"]),
        coinData["image"],
        coinData["abi"],
        active: coinData["active"],
        inTestnet: inTestnet
      );

      list.add(data);
    }
    list.insert(0,
      Platform(
        dotenv.env["PLATFORM_NAME"] ?? "Avalanche",
        dotenv.env["PLATFORM_SYMBOL"] ?? "AVAX",
        "",
        "",
        1,
        dotenv.env["PLATFORM_IMAGE"] ?? "assets/avax_logo.png",
        "",
        active: true,
      )
    );
    _rawCoinsData.complete(coinList);
    init.complete(true);
  }

  static Future<List> listRaw() async {
    return await _self._rawCoinsData.future;
  }

  List<Token> getCoins() => list;
  Platform getPlatform() => list.first as Platform;

  ///When it receives -1 it means the API refused to return
  static void updateValue(int index, String name, double currency, BigInt ether)
  {
    Print.approve("$name, $currency");
    if(currency == -1.0 || name.contains('testnet')) { return; }
    Token coin = list[index];
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
    Print.warning("Coins add: $data");
    try {
      List<Token> _currentTokens = list;
      _currentTokens.add(data);
      List raw = await asListOfMap(refList: _currentTokens);
      await FileManager.writeString(AppRootFolder.Tokens.name, _self._file, raw);
    }
    catch(e) {
      // Print.error(e.toString());
      // return false;
      throw e;
    }
    return true;
  }

  static Future<bool> remove(Token data) async
  {
    try {
      List<Token> _currentTokens = list;
      if(data is Platform) { return false; }
      _currentTokens.removeWhere((coin) => coin == data);
      List raw = await asListOfMap(refList: _currentTokens);
      await FileManager.writeString(AppRootFolder.Tokens.name, _self._file, raw);
    }
    catch(e) {
      return false;
    }
    return true;
  }

  static Future<List> asListOfMap({List<Token>? refList}) async
  {
    List<Token> _currentTokens = refList ?? list;
    List _ret = [];
    for(Token coin in _currentTokens)
    {
      if(coin is Platform) { continue; }
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
class CoinData extends Token {
  CoinData(
    String name,
    String symbol,
    String address,
    String testAddress,
    int decimals,
    String image,
    String abi,
    {bool active = false, bool inTestnet = false}
  ) : super(
    name,
    symbol,
    address,
    testAddress,
    decimals,
    image,
    abi,
    active: active,
    inTestnet: inTestnet
  );

  factory CoinData.fromMap(Map data) {
    return CoinData(data["name"],
      data["symbol"],
      data["address"],
      data["test-address"],
      int.parse(data["decimals"]),
      data["image"],
      data["abi"],
      active : data["active"],
      inTestnet: data["inTestnet"]
    );
  }

  @override
  String toString()
  {
    return super.toString().replaceFirst("Token", "CoinData");
  }
}

class Platform extends Token {
  Platform(
    String name,
    String symbol,
    String address,
    testAddress,
    decimals,
    image,
    abi,
    {bool active = false, bool inTestnet = false}
  ) : super(
    name,
    symbol,
    address,
    testAddress,
    decimals,
    image,
    abi,
    active: active,
    inTestnet: inTestnet
  );

  @override
  factory Platform.fromMap(Map data) {
    return Platform(
      data["name"],
      data["symbol"],
      data["address"],
      data["testAddress"],
      int.parse(data["decimals"]),
      data["image"],
      data["abi"],
      active: data["active"],
      inTestnet: data["inTestnet"]
    );
  }

  @override
  String toString()
  {
    return super.toString().replaceFirst("Token", "Platform");
  }
}