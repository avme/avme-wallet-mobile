import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/token.dart';
import 'package:avme_wallet/app/src/helper/crypto/convert.dart';
import 'package:avme_wallet/app/src/model/db/market_data.dart';
import 'package:avme_wallet/app/src/model/services.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:web3dart/contracts/erc20.dart';
import 'package:web3dart/web3dart.dart';

import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/controller/wallet/account.dart';

import 'package:avme_wallet/app/src/helper/utils.dart';
import 'package:avme_wallet/app/src/controller/threads.dart';
import 'package:avme_wallet/app/src/controller/wallet/balance.dart';

import 'package:avme_wallet/app/src/controller/db/app.dart';
import 'package:avme_wallet/app/src/controller/ui/push_notification.dart';

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
      )
    );
    List<http.Response> results = await pending;
    for (http.Response response in results) {
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
        instance["params"] = [accounts[i].address, "latest"];
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
  static Future<Iterable<double>> getPrice(
      {String currency = "usd", String? address}) async
  {
    String base = "https://api.coingecko.com/api/v3/simple/";
    String url = "$base";
    String key = "avalanche-2";
    if (address != null) {
      url +=
      "token_price/avalanche?contract_addresses=$address&vs_currencies=$currency%2Ceth";
      key = "$address";
    }
    else {
      url += "price?ids=avalanche-2&vs_currencies=$currency%2Ceth";
    }

    String response = await get(null, url: url, method: "GET");

    try {
      Map data = (jsonDecode(response) as Map)[key] as Map;
      return List<double>.from(data.values);
    }
    catch (e) {
      return [-1.0, -1.0];
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
    Print.mark("[$name] \"$api\"");
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
        dateTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day, _dateTime.hour);
        unix = int.parse(dateTime.millisecondsSinceEpoch.toString().substring(0, 10));
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
    List<Token> coins = Coins.list;
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
          List info = coinData.entries.first.value;
          double currency = info.first;
          BigInt ether = info.last;
          Coins.updateValue(event.indexOf(coinData), coinName, currency, ether);
        }
      }
    });
    await stream.first;
    return true;
  }

  static Future<bool> observeTodayHistory() async
  {
    List<Token> coins = Coins.list;
    for(Token coin in coins)
    {
      Print.approve("${coin.name} | ${coin.address}");
    }
    Threads threads = Threads();

    late Stream stream;
    ThreadMessage observeHist = ThreadMessage(
      caller: 'observeTodayHistory',
      function: observeHourlyCoinHistory
    );
    stream = threads.addToPool(id: 0, task: observeHist, shouldReturnReference: true);
    stream.listen((event) async {
      if (event is Map) {
        if (event["command"] == "getMissingDays") {
          SendPort socket = event["sendPort"];
          List<Map> pending = [];
          await Future.forEach(coins, (Token token) async {
            List<int> missing = await WalletDB.getMissingHours(token.name);
            if (token is Platform)
            {
              pending.insert(0,
                {
                  token.name : [
                    Utils.lowest(missing),
                    Utils.highest(missing),
                    "0x0"
                  ]
                }
              );
            }
            else if (token is CoinData) {
              pending.add({
                token.name: [
                  Utils.lowest(missing),
                  Utils.highest(missing),
                  token.address
                ]
              });
            }
          });
          socket.send(pending);
        }
        else if (event["command"] == "update") {
          for (MapEntry entry in event["data"].entries) {
            String coin = entry.key;
            for (Map _entry in entry.value) {
              String price = _entry['exact'].toStringAsFixed(6);
              Decimal value = Decimal.parse(price);
              Print.ok("$price, $value");
              await _self._insertHistoryValues(coin, _entry['unix'], value);
            }
          }
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

        await Future.forEach(event, (Map _entry) async
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
            Print.ok("[T#${wrap.info.id} ID#${wrap.id}] Skipping history request for Coin \"$coin\" UNIX range [$lowest - $highest] being too short");
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
    }
    while (!wrap.isCanceled());
  }

  ///Gathers 30 day coin market for every coin, including platform
  static Future<bool> updateCoinHistory() async
  {
    List<Token> coins = Coins.list;
    // List<int> platformMissing =
    //   await WalletDB.getMissingDays("platform");
    // if (platformMissing.isNotEmpty) {
    //   Print.warning("platform? $platformMissing");
    //   List platformData = await getTokenHistoryRange(
    //     from: Utils.lowest(platformMissing),
    //     to: Utils.highest(platformMissing),
    //   );
    //   for (Map _entry in platformData) {
    //     String price = _entry['exact'].toStringAsFixed(6);
    //     Decimal value = Decimal.parse(price);
    //     _self._insertHistoryValues("platform", _entry['unix'], value);
    //   }
    // }

    for (Token coin in coins) {
      Print.error("[${coin.name}]");
      if (coin.name.contains('testnet')) {
        continue;
      }
      List<int> _missing = await WalletDB.getMissingDays(coin.name);
      if (_missing.isEmpty) {
        continue;
      }
      // late List<Map> result;
      // if(coin is Platform)
      // {
      //   result = await getTokenHistoryRange(
      //     from: Utils.lowest(_missing),
      //     to: Utils.highest(_missing),
      //     name: coin.name,
      //   );
      // }
      // else
      // {
      List<Map> result = await getTokenHistoryRange(
        from: Utils.lowest(_missing),
        to: Utils.highest(_missing),
        address: coin is Platform ? "0x0" : coin.address,
        name: coin.name
      );

      List<MarketData> marketList = result.map((_entry) {
        return MarketData(
          tokenName: _entry["name"],
          value: Decimal.parse(_entry['exact'].toStringAsFixed(6)),
          dateTime: _entry['unix']
        );
      }).toList();

      if(marketList.isNotEmpty)
      {
        await WalletDB.insertList(marketList);
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

    List<Token> coins = params.first;
    coins.removeWhere((coin) => coin.name.contains('testnet'));
    double test = 0;
    do {
      List<Map> coinsValue = await Future.wait(
        coins.map((Token coinData) async {
          late Iterable data;
          late double currency;
          if(coinData is Platform)
          {
            data = await getPrice();
            test += 0.2;
            currency = data.first + test;
          }
          else if (coinData is CoinData)
          {
            data = await getPrice(address: coinData.address);
            currency = data.first;
          }

          BigInt ether = BigInt.from(data.last);
          return {coinData.name: [currency, ether]};
        })
      );
      wrap.send(coinsValue);

      ///Lowered from 1 second to 30 seconds, the CoinGecko's endpoint can negate
      ///our request, and its unnecessary to request so many updates when
      ///dealing with a mobile device
      await Future.delayed(Duration(seconds: 30));
    }
    while (!wrap.isCanceled());
  }

  Future _insertHistoryValues(String coinName, int unix, Decimal value) async
  {
    MarketData md = MarketData(tokenName: coinName, value: value, dateTime: unix);
    MarketData inserted = await WalletDB.insert(md);
    Print.mark("[MarketData.inserted] $inserted");
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
    bool selfInitialized = false;
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
            AccountData resAccount = Account.accounts.firstWhere((AccountData ad) => ad.address == address);

            Map update = event["update"]![address];
            List<Balance> tokens = update["token"];
            for(int i = 0; i < tokens.length; i++)
            {
              Balance token = tokens[i];
              Print.error("balance ${tokens[i].name}: \$${resAccount.balance[i].inCurrency}:TokenAmount ${resAccount.balance[i].qtd}");

              if(token.qtd != resAccount.balance[i].qtd)
              {
                token.inCurrency = token.qtd * token.token().value;
                double difference = token.inCurrency - resAccount.balance[i].inCurrency;
                Print.ok("${token.name} ${token.inCurrency} - ${resAccount.balance[i].inCurrency}");
                if(difference > 0 && selfInitialized)
                {
                  PushNotification.showNotification(
                    id: 9,
                    title: "Transfer received (${token.name})",
                    body:
'''Account Update: 
You received \$${difference.toStringAsFixed(2)}\b (${token.name}) in the Account#${Account.accounts.indexOf(resAccount)} ${resAccount.title}.''',
                    payload: "app/history"
                  );
                }
                resAccount.updateToken(token, i);
              }
            }
            PlatformBalance platform = update["platform"];
            platform.inCurrency = platform.qtd * platform.token().value;
            if(platform.qtd != resAccount.platform.qtd)
            {

              double difference = platform.inCurrency - resAccount.platform.inCurrency;
              Print.ok("platform: ${platform.inCurrency} - ${resAccount.platform.inCurrency}");
              if(difference > 0 && selfInitialized)
              {
                PushNotification.showNotification(
                  id: 9,
                  title: "Transfer received (${platform.name})",
                  body:
                  '''Account Update: 
You received \$${difference.toStringAsFixed(2)}\b (${platform.name}) in the Account#${Account.accounts.indexOf(resAccount)} ${resAccount.title}.''',
                  payload: "app/history"
                );
              }
              resAccount.updatePlatform(platform);
            }
            else if(resAccount.platform.inCurrency != platform.qtd * platform.token().value)
            {
              resAccount.updatePlatform(platform);
            }
          }
        }
        if(!selfInitialized)
        {
          selfInitialized = true;
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
        EthereumAddress accountAddress = account.ethereumAddress!;
        List<Balance> _tokens = [];
        for (Balance token in account.balance) {
          EthereumAddress contract = EthereumAddress.fromHex(token.address);
          Erc20 typeERC20 = Erc20(
            address: contract,
            client: web3client,
            chainId: chainId
          );
          Balance balance = Balance.from(token);
          balance.raw = await typeERC20.balanceOf(accountAddress);
          String total =
            Convert.weiToFixedPoint(balance.raw.toString(), digits: balance.decimals);
          balance.qtd = double.parse(total);
          _tokens.add(balance);
        }
        List result = await getBalanceAny(account.address, url);

        BigInt ether = Convert.bigIntFromUnit(result.first["result"]);
        PlatformBalance platformBalance = PlatformBalance();
        platformBalance.qtd = double.parse(Convert.bigIntReadable(ether));
        platformBalance.raw = ether;
        update[accountAddress.hex] = {
          "token": _tokens,
          "platform": platformBalance
        };
      }
      wrap.send({"update": update});
      await Future.delayed(Duration(seconds: seconds));
    }
    while (!wrap.isCanceled());
  }

  static Future<BigInt> calculateGasPrice() async
  {
    String url = dotenv.get("NETWORK_URL");
    http.Client httpClient = http.Client();
    Web3Client ethClient = Web3Client(url, httpClient);
    // EtherAmount _gasPriceTemp = EtherAmount.inWei((await ethClient.getGasPrice()).getInWei);
    EtherAmount _gasPriceTemp = await ethClient.getGasPrice();
    BigInt addToFee = BigInt.from((5 * pow(10, 9)));
    double gasPriceVal = ((_gasPriceTemp.getInWei + addToFee).toDouble()) / 1000000000;

    return BigInt.from(gasPriceVal);
  }

  static void isTestnet()
  {
    if (Utils.inTestnet())
    {
      Print.mark("[WARNING] Using testnet faucet network");
    }
    else
    {
      Print.mark("[WARNING] Using main network");
    }
  }
}