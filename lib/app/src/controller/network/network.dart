import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';
import 'package:avme_wallet/app/src/helper/crypto/convert.dart';
import 'package:avme_wallet/app/src/model/services.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:web3dart/contracts/erc20.dart';
import 'package:web3dart/web3dart.dart';

import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/controller/wallet/account.dart';

import 'package:avme_wallet/app/src/controller/db/coin.dart';

import 'package:avme_wallet/app/src/helper/utils.dart';
import 'package:avme_wallet/app/src/model/db/coin.dart';
import 'package:avme_wallet/app/src/controller/threads.dart';
import 'package:avme_wallet/app/src/controller/wallet/balance.dart';

class Network {
  static final Network _self = Network._internal();

  Network._internal();

  factory Network() => _self;

  String url = dotenv.env["NETWORK_URL"] ??
      'https://api.avax.network/ext/bc/C/rpc';
  String chain = dotenv.env["CHAIN_ID"] ?? '43114';

  static Future<bool> checkConnection({String? url}) async
  {
    Uri uri = Uri.parse(url ?? _self.url);
    int repeat = 3;

    Duration timeoutTimer = const Duration(seconds: 3);
    Future pending = Future.wait(
        List.generate(repeat, (index) =>
        http.get(uri)
          ..timeout(timeoutTimer,
              onTimeout: () => _self._timeout("checkConnection", timeoutTimer))
        ));
    // ..timeout(timeoutTimer, onTimeout: () => List.generate(repeat, (index) => _self._timeout("checkConnection", timeoutTimer)));
    List<http.Response> results = await pending;
    for (http.Response response in results) {
      // Utils.printApprove("Code: ${response.statusCode}");
      if (response.statusCode == 500) {
        return false;
      }
    }
    return true;
  }

  http.Response _timeout(String caller, Duration limit) {
    Print.error("Error at: Network.$caller: ${limit
        .inMilliseconds} passed with no returned data");
    return http.Response("", 500);
  }

  ///Requests every account's balance
  static Future<List> getBalance([List<String>? addressList, String? url]) async
  {
    Map body = {
      "id": "0",
      "jsonrpc": "2.0",
      "method": "eth_getBalance",
      "params": ["", "latest"]
    };

    List<Map> mapRequest = [];

    if (addressList == null) {
      List<AccountData> accounts = Account.accounts;
      for (int i = 0; i < accounts.length; i++) {
        Map<String, dynamic> instance = Map.from(body);
        instance["id"] = "$i";
        instance["params"] = [accounts[i].address!, "latest"];
        mapRequest.add(instance);
      }
    }
    else {
      for (int i = 0; i < addressList.length; i++) {
        Map<String, dynamic> instance = Map.from(body);
        instance["id"] = "$i";
        instance["params"] = [addressList[i], "latest"];
        mapRequest.add(instance);
      }
    }
    String response = await get(mapRequest, url: url);
    return jsonDecode(response);
  }

  ///Requests the balance of any address
  static Future<List> getBalanceAny(String address, [String? url]) async
  {
    try {
      EthereumAddress.fromHex(address);
    } catch (e) {
      Print.warning(e.toString());
    }

    Map body = {
      "id": 0,
      "jsonrpc": "2.0",
      "method": "eth_getBalance",
      "params": [address, "latest"]
    };

    String response = await get([body], url: url);
    return jsonDecode(response) as List;
  }

  ///The id of the platform issuing tokens (See asset_platforms endpoint for list of options)
  ///asset_platforms: https://api.coingecko.com/api/v3/asset_platforms
  static Future<double> getPrice(
      {String currency = "usd", String? address}) async
  {
    String base = "https://api.coingecko.com/api/v3/simple/";
    String url = "$base";
    String key = "avalanche-2";
    if (address != null) {
      url +=
      "token_price/avalanche?contract_addresses=$address&vs_currencies=$currency";
      key = "$address";
    }
    else {
      url += "price?ids=avalanche-2&vs_currencies=$currency";
    }

    String response = await get(null, url: url, method: "GET");

    try {
      dynamic value = (jsonDecode(response) as Map)[key][currency];
      if (value is double) {
        return value;
      }
      if (value is String) {
        return double.parse(value);
      }
      return 0.0;
    }
    catch (e) {
      return -1.0;
    }
  }

  ///The id of the platform issuing tokens (See asset_platforms endpoint for list of options)
  ///asset_platforms: https://api.coingecko.com/api/v3/asset_platforms
  static Future<List<Map>> getPlatformHistory(
      {String currency = "usd", String id = "avalanche-2", int days = 30}) async
  {
    List<Map> ret = [];
    String api = "https://api.coingecko.com/api/v3/coins/$id/market_chart?vs_currency=$currency&days=$days";
    String response = await get(null, url: api, method: "GET");
    List date = (jsonDecode(response) as Map)["prices"];
    intl.DateFormat dateFormat = intl.DateFormat('dd/MM/yyyy hh:mm:ss a');
    for (List day in date) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(day.first);
      ret.add({
        "date": dateFormat.format(dateTime),
        currency: (day.last as double).toStringAsFixed(2),
        "exact": day.last,
        "unix": day.first
      });
    }
    return ret;
  }

  ///The id of the platform issuing tokens (See asset_platforms endpoint for list of options)
  ///asset_platforms: https://api.coingecko.com/api/v3/asset_platforms
  static Future<List<Map>> getTokenHistory(String address,
      {
        String currency = "usd",
        String id = "avalanche",
        int days = 30
      }) async
  {
    try {
      EthereumAddress.fromHex(address);
    } catch (e) {
      Print.warning(e.toString());
    }
    List<Map> ret = [];
    String api = "https://api.coingecko.com/api/v3/coins/$id/contract/$address/market_chart/?vs_currency=$currency&days=$days";
    String response = await get(null, url: api, method: "GET");
    List date = (jsonDecode(response) as Map)["prices"];
    intl.DateFormat dateFormat = intl.DateFormat('dd/MM/yyyy hh:mm:ss a');
    for (List day in date) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(day.first);
      ret.add({
        "date": dateFormat.format(dateTime),
        currency: (day.last as double).toStringAsFixed(2),
        "exact": day.last
      });
    }
    return ret;
  }

  /// Requests CoinGecko's api for token's $address in $platform and it's
  ///value in range, for more information about platform's ids visit:
  ///platform-listings: https://api.coingecko.com/api/v3/asset_platforms
  ///
  /// This request will return unix in milliseconds of precision of 3
  static Future<List<Map>> getTokenHistoryRange({
    required int from,
    required int to,
    String currency = "usd",
    String platform = "avalanche-2",
    String address = "0x0",
    String name = "",
    bool simplify = true,
  }) async
  {
    List<Map> ret = [];
    String api = "https://api.coingecko.com/api/v3/coins/";
    if (address == "0x0") {
      api +=
      "$platform/market_chart/range?vs_currency=$currency&from=$from&to=$to";
    }
    else {
      try {
        EthereumAddress.fromHex(address);
      } catch (e) {
        Print.warning(e.toString());
      }
      api +=
      "avalanche/contract/$address/market_chart/range?vs_currency=$currency&from=$from&to=$to";
    }
    String response = await get(null, url: api, method: "GET");
    List date = [];
    if (response.isNotEmpty) {
      date = (jsonDecode(response) as Map)["prices"] ?? [];
    }
    intl.DateFormat dateFormat = intl.DateFormat('dd/MM/yyyy hh:mm:ss a');
    List unixList = [];
    for (List day in date) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(day.first);
      int unix = day.first;

      if (simplify) {
        DateTime _dateTime = DateTime.fromMillisecondsSinceEpoch(day.first);
        dateTime = DateTime(
            _dateTime.year, _dateTime.month, _dateTime.day, _dateTime.hour);
        unix = int.parse(
            dateTime.millisecondsSinceEpoch.toString().substring(0, 10));
      }

      ///Skipping duplicates
      if (unixList.contains(unix)) {
        continue;
      }
      unixList.add(unix);
      ret.add({
        "date": dateFormat.format(dateTime),
        currency: (day.last as double).toStringAsFixed(2),
        "exact": day.last,
        "unix": unix,
        "name": name
      });
    }
    return ret;
  }

  static Future<String> get(body,
      {String? url, Map<String, String>? headers, String method = "POST"}) async
  {
    headers = headers ?? {"Content-Type": "application/json"};
    Uri uri = Uri.parse(url ?? _self.url);
    http.Response? response;
    try {
      if (method.toUpperCase() == "POST") {
        response =
        await http.post(uri, body: json.encode(body), headers: headers);
      } else if (method.toUpperCase() == "GET") {
        response = await http.get(uri, headers: headers);
      }
      if (response == null) {
        throw FormatException('Response returned null, possibly no internet connection');
      }
    }
    catch (e) {
      // if(e is FormatException)
      // {
      Print.warning('''
Error at Network.get: Caused by a \"$e\", retrying in 5 seconds...
''');
      await Future.delayed(Duration(seconds: 5));
      return get(body, headers: headers, method: method, url: url);
      // }
    }
    return response.body;
  }

  ///Get the current value of platform and Coins
  ///this is a live service
  static Future<bool> observeValueChanges() async
  {
    List<CoinData> coins = Coins.list;
    Threads threads = Threads();

    late Stream stream;
    ThreadMessage observeValues = ThreadMessage(
      caller: "observeValueChanges",
      params: [coins],
      function: wrapGetPrice,
    );
    stream = threads.addToPool(id: 0, task: observeValues, shouldReturnReference: true);
    stream.listen((event) {
      // Print.approve("observeValues: ${event.toString()}");
      if (event is ThreadReference) {
        Services.add("valueSubscription", event);
      }
      else if (event is List) {
        for (Map coinData in event) {
          String coinName = coinData.entries.first.key;
          double value = coinData.entries.first.value;
          Coins.updateValue(coinName, value);
        }
      }
    });
    await stream.first;
    return true;
  }

  static Future<bool> observeTodayHistory() async
  {
    List<CoinData> coins = Coins.list;
    Threads threads = Threads();

    late Stream stream;
    ThreadMessage observeHist = ThreadMessage(
        caller: 'observeTodayHistory',
        function: observeHourlyCoinHistory
    );
    stream = threads.addToPool(
        id: 0, task: observeHist, shouldReturnReference: true);
    stream.listen((event) async {
      if (event is Map) {
        if (event["command"] == "getMissingDays") {
          SendPort socket = event["sendPort"];
          List<Map> pending = [];
          await Future.forEach(coins, (CoinData coin) async {
            List<int> missing = await ValueHistoryTable.getMissingHours(
                coin.name);
            pending.add(
              {
                coin.name: [
                  Utils.lowest(missing),
                  Utils.highest(missing),
                  coin.address
                ]
              }
            );
          });
          List<int> pMissing = await ValueHistoryTable.getMissingHours("platform");
          pending.insert(0,
            {
              "platform": [
                Utils.lowest(pMissing),
                Utils.highest(pMissing),
                "0x0"
              ]
            }
          );
          socket.send(pending);
        }
        else if (event["command"] == "update") {
          // await Future.forEach(event["data"].entries, (MapEntry entry) async
          for (MapEntry entry in event["data"].entries) {
            String coin = entry.key;
            // Print.approve(coin);
            for (Map _entry in entry.value) {
              String price = _entry['exact'].toStringAsFixed(6);
              Decimal value = Decimal.parse(price);
              Print.ok("$price, $value");
              await _self._insertHistoryValues(coin, _entry['unix'], value);
            }
          } //);
        }
      }
    });
    return true;
  }

  /// This function tracks hourly every token change, since the CoinGecko's API
  ///returns a very detailed registry of then the data was updated
  ///we save the data per hour removing the minutes and seconds from the record
  static Future observeHourlyCoinHistory(List params, ThreadWrapper wrap) async
  {
    await prepareOperation(wrap);

    ///When the thread sends back an sendPort its stored in the caller
    ///to attend any unique Singleton request, for example a singleton
    ///managing other processes or even threads...
    ReceivePort receivePort = ReceivePort();
    wrap.send({"socket": receivePort.sendPort});

    ///in UnixEpoch: [{'platform': [0: lowest, 1: highest]}]
    receivePort.listen((event) async {
      Print.error("receivePort listen $event");
      if (event is List<Map>) {
        Map result = {};
        // Print.mark(event.toString());
        await Future.forEach(event, (Map _entry) async
        // for(Map _entry in event)
            {
          List properties = _entry.entries.first.value;

          String coin = _entry.entries.first.key;
          if (coin.contains('testnet')) {
            return;
          }

          int lowest = properties[0];
          int highest = properties[1];
          String address = properties[2];
          if (lowest == highest) {
            Print.ok("[T#${wrap.info.id} ID#${wrap
                .id}] Skipping history request for Coin \"$coin\" UNIX range [$lowest - $highest] being too short");
            return;
          }
          Print.warning("[T#${wrap.info.id} ID#${wrap
              .id}] L:$lowest | H:$highest | 0x: $address");
          List<Map> missingHoursData = await getTokenHistoryRange(
            from: lowest,
            to: highest,
            address: address,
          );
          result[coin] = missingHoursData;
        });
        // Print.warning("$result");
        if (result.isNotEmpty) {
          wrap.send({
            "command": "update",
            "sendPort": receivePort.sendPort,
            "data": result
          });
        }
      }
    });
    do {
      wrap.send(
          {"command": "getMissingDays", "sendPort": receivePort.sendPort});
      await Future.delayed(Duration(minutes: 1));
      // await Future.delayed(Duration(seconds: 5));
    }
    while (!wrap.isCanceled());
  }

  ///Gathers 30 day coin market for every coin, including platform
  static Future<bool> updateCoinHistory() async
  {
    List<CoinData> coins = Coins.list;
    List<int> platformMissing =
      await ValueHistoryTable.getMissingDays("platform");
    if (platformMissing.isNotEmpty) {
      Print.warning("platform? $platformMissing");
      List platformData = await getTokenHistoryRange(
        from: Utils.lowest(platformMissing),
        to: Utils.highest(platformMissing),
      );
      for (Map _entry in platformData) {
        String price = _entry['exact'].toStringAsFixed(6);
        Decimal value = Decimal.parse(price);
        _self._insertHistoryValues("platform", _entry['unix'], value);
      }
    }

    for (CoinData coin in coins) {
      if (coin.name.contains('testnet')) {
        continue;
      }
      List<int> _missing = await ValueHistoryTable.getMissingDays(coin.name);
      if (_missing.isEmpty) {
        continue;
      }
      List<Map> result = await getTokenHistoryRange(
        from: Utils.lowest(_missing),
        to: Utils.highest(_missing),
        address: coin.address,
        name: coin.name
      );
      for (Map _entry in result) {
        String price = _entry['exact'].toStringAsFixed(6);
        Decimal value = Decimal.parse(price);
        _self._insertHistoryValues(_entry["name"], _entry['unix'], value);
      }
    }
    return true;
  }

  ///Runs indefinitely getPrice until the process is interrupted or canceled
  static Future wrapGetPrice(List params, ThreadWrapper wrap) async
  {
    ///If the process will be infinite, please use prepareOperation to avoid
    ///CancellableOperation[self] = null
    await prepareOperation(wrap);

    List<CoinData> coins = params.first;
    do {
      await Future.delayed(Duration(seconds: 1));
      double platformValue = await getPrice();

      List<Map> coinsValue = await Future.wait(
        coins.map((CoinData coinData) async {
          if (coinData.name.contains("testnet")) {
            return {coinData.name: 1.0};
          }
          return {coinData.name: await getPrice(address: coinData.address)};
        })
      );
      coinsValue.add({"platform": platformValue});
      wrap.send(coinsValue);
    }
    while (!wrap.isCanceled());
  }

  Future _insertHistoryValues(String coinName, int unix, Decimal value) async
  {
    TokenHistory th = TokenHistory(
        tokenName: coinName, value: value, dateTime: unix);
    TokenHistory inserted = await ValueHistoryTable.insert(th);
    Print.mark("[TokenHistory.inserted] $inserted");
  }

  static Future<bool> observeBalance() async
  {
    for (AccountData account in Account.accounts) {
      ///Initialize a list of <Balance> for every Account with positional as id
      ///to later update its BigInt value and readable value
      List<Balance> balance = [];
      for (int i = 0; i < Coins.list.length; i++) {
        if (Coins.list[i].name.contains("testnet")) {
          continue;
        }
        balance.add(Balance(i));
      }
      account.balance = balance;
    }

    Threads threads = Threads();
    late Stream stream;
    ThreadMessage observeBalance = ThreadMessage(
      caller: "observeBalance",
      params: [Account.accounts, _self.url, _self.chain],
      function: wrapObserveBalance,
    );
    stream = threads.addToPool(id: 0, task: observeBalance, shouldReturnReference: true);
    stream.listen((event) {
      // Print.approve("wrapObserveBalance $event");
      if (event is ThreadReference) {
        Services.add("observeBalance", event);
      }
      if(event is Map<String, Map>)
      {
        ///Got token updates from the thread
        if(event.containsKey("update"))
        {
          for(String address in event["update"]!.keys)
          {
            AccountData operatingAccount = Account.accounts.firstWhere((AccountData ad) => ad.address! == address);

            Map update = event["update"]![address];
            List<Balance> tokens = update["token"];
            PlatformBalance platform = update["platform"];
            operatingAccount.updateToken(tokens);
            operatingAccount.updatePlatform(platform);
            Print.mark("tf2 sex update: $update");
          }
        }
      }
    });
    await stream.first;
    return true;
  }

  static Future wrapObserveBalance(List params, ThreadWrapper wrap) async {
    await prepareOperation(wrap);

    List<AccountData> accounts = params[0];
    String url = params[1];
    int chainId = int.parse(params[2]);
    int seconds = 5;

    ///Network socket
    http.Client httpClient = http.Client();
    Web3Client web3client = Web3Client(url, httpClient);
    do {
      Map<String, Map> update = {};
      for (AccountData account in accounts) {
        EthereumAddress address = account.ethereumAddress!;
        List<Balance> _tokens = [];
        for (Balance token in account.balance) {
          EthereumAddress contract = EthereumAddress.fromHex(token.address);
          Erc20 typeERC20 = Erc20(
            address: contract,
            client: web3client,
            chainId: chainId
          );
          Balance balance = Balance.from(token);
          balance.raw = await typeERC20.balanceOf(address);
          String total =
            Convert.weiToFixedPoint(balance.raw.toString(), digits: balance.decimals);
          balance.total = double.parse(total);
          _tokens.add(balance);
        }
        List result = await getBalanceAny(account.address!, url);

        String hexValue = Convert.decimalToReadable(result.first["result"]);
        PlatformBalance platformBalance = PlatformBalance();
        platformBalance.raw = Decimal.fromJson(hexValue).toBigInt();
        platformBalance.total = double.parse(hexValue);
        update[address.hex] = {
          "token": _tokens,
          "platform": platformBalance
        };
      }
      wrap.send({"update": update});
      await Future.delayed(Duration(seconds: seconds));
    }
    while (!wrap.isCanceled());
  }
}