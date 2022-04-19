import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:avme_wallet/app/controller/database/value_history.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/value_history.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../threads.dart';

Future<bool> getValues(AvmeWallet app) async
{
  bool didValueUpdated = false;
  Map<String, List<int>> missingDates = {};
  Map<String, dynamic> data = {
    "url": "${env["MAINNET_URL"]}:${env["MAINNET_PORT"]}${env["MAINNET_VALUEPATH"]}",
    "activeTokens": app.activeContracts.tokens,
    "contractRaw": app.activeContracts.sContracts.contractsRaw
  };

  int designatedThread = 0;

  ValueHistoryTable tokenHistory = ValueHistoryTable.instance;

  await Future.forEach(app.activeContracts.tokens, (String token) async {
    missingDates[token] = await tokenHistory.getMissingDays(token.toUpperCase());
  });

  data["avaxDates"] = await tokenHistory.getMissingDays("AVAX");
  data['missingDates'] = missingDates;

  String url = data["url"];

  Map<String, Map<String, String>> tokenHistoryBody = {};

  Map<String, Map> contractsRaw = data["contractRaw"];
  String listenBody = "{token(id: \"CONTRACT_ADDRESS\"){symbol derivedETH}}";
  String watchPriceBody =
      "{tokenDayDatas(first: 30,orderBy: date,orderDirection: desc, where:{token: \"CONTRACT_ADDRESS\", date_in:[FILTERED_DAYS]}) { date priceUSD }}";

  Map<String, Map<String, String>> tokenValueParam = {};

  Future.forEach(data["activeTokens"], (String token) async {
    String tokenValue = "";
    String watchToken = "";

    ///Não é Testnet, do contrario atribuir a consulta como AVME
    if (!token.contains('testnet')) {
      print("USING $token");
      tokenValue = listenBody.replaceFirst('CONTRACT_ADDRESS', contractsRaw[token]['address']);
      if (missingDates[token].length > 0)
        watchToken = watchPriceBody
          .replaceFirst('CONTRACT_ADDRESS', contractsRaw[token]['address'])
          .replaceFirst('FILTERED_DAYS', missingDates[token].join(', '));
    } else {
      tokenValue = listenBody.replaceFirst('CONTRACT_ADDRESS', contractsRaw["AVME"]['address']);
      if (missingDates[token].length > 0)
        watchToken = watchPriceBody
          .replaceFirst('CONTRACT_ADDRESS', contractsRaw["AVME"]['address'])
          .replaceFirst('FILTERED_DAYS', missingDates[token].join(', '));
    }
    tokenValueParam[token] = {"query": tokenValue};
    if (watchToken != "") tokenHistoryBody[token] = {"query": watchToken};
  });

  Map watchData = {
    ...data,
    "url": url,
    "tokensRequest": tokenValueParam,
    "avaxBodyRequest": {
      "query": "{pair(id: \"0x9ee0a4e21bd333a6bb2ab298194320b8daa26516\") {token0 {symbol} token1 {symbol} token0Price token1Price}}"
    }
  };

  StreamSubscription sub1;
  StreamSubscription sub2;
  ThreadMessage task1 = ThreadMessage(
      caller: "watchValue",
      params: [watchData],
      function: watchValue
  );

  Threads threads = Threads.getInstance();
  sub1 = threads.addToPool(
    id: designatedThread,
    task: task1,
    shouldReturnReference: true
  ).listen((message) async {
    if(message is ThreadReference)
    {
      app.tProcesses["valueSubscription"] = message;
      return;
    }
    if (message.containsKey("listenValue")) {
      List response = message["listenValue"];
      response.forEach((mapEntry) {
        String key = mapEntry.entries.first.key;
        Decimal value = mapEntry.entries.first.value;
        if (key == "AVAX") {
          app.networkToken.updateToken(value);
        } else {
          app.activeContracts.token.updateToken(key, value);
          if (app.activeContracts.tokens.contains("$key testnet")) app.activeContracts.token.updateToken("$key testnet", value);
        }
        didValueUpdated = true;
      });
    }
  });

  sub1.onDone(() {
    printApprove('${task1.caller} onDone');
  });

  Map<String, dynamic> priceData = {
    "url": url,
    "tokensRequest": tokenHistoryBody,
  };

  ///Mounting AVAX dates filter
  List<int> avax = data["avaxDates"];

  if (avax.length > 0) {
    data["networkTokenRequest"] = {
      "query":
      "{tokenDayDatas(first: 30,orderBy: date,orderDirection: desc,where:{token: \"0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7\", date_in:[FILTERED_DAYS]}) { date priceUSD }}"
          .replaceFirst("FILTERED_DAYS", avax.join(', '))
    };
  }

  ThreadMessage task2 = ThreadMessage(
    function: priceHistory,
    params: [priceData],
    caller: "priceHistory"
  );
  sub2 = threads.addToPool(
    id: designatedThread,
    task: task2,
  ).listen((message) async {
    ///Processing AVAX days
    if (message.containsKey("networkTokenHistory")) {
      Map<String, dynamic> response = message["networkTokenHistory"];
      List<Map> missingDays = response["data"]["tokenDayDatas"].cast<Map>();
      bool pending = await updateTokenHistory(tokenName: "AVAX", days: missingDays, db: tokenHistory);
      SendPort waitAvaxPort = message['waitAvaxPort'];
      waitAvaxPort.send(pending);
    }

    ///Processing Tokens days
    if (message.containsKey("tokensHistory")) {
      print("SOMETHING RETURNED");
      print(message["tokensHistory"]);
      List<Map> tokens = message["tokensHistory"];
      await Future.forEach(tokens, (Map tokenData) async {
        String tokenName = tokenData.entries.first.key;
        List<Map> missingDays = tokenData.entries.first.value["data"]["tokenDayDatas"].cast<Map>();
        await updateTokenHistory(tokenName: tokenName, days: missingDays, db: tokenHistory);
      });
    }
  });

  do await Future.delayed(Duration(milliseconds: 150)); while (!didValueUpdated);
  return didValueUpdated;
}

void watchValue(List<dynamic> params, {ThreadData threadData, int id, ThreadMessage threadMessage}) async
{
  printWarning("[T#${threadData.id} P#$id] Starting \"watchValue\"");
  int seconds = 0;
  Map param = params.first;
  String url = param["url"];
  Map<String, Map<String, dynamic>> tokensRequest = param["tokensRequest"];
  Map<String, String> avaxBodyRequest = param["avaxBodyRequest"];
  List blackList = [];

  ///If the process will be infinite, please use prepareOperation to avoid
  ///CancellableOperation[self] = null
  await prepareOperation(id, threadData);
  while(!threadData.processes[id].isCanceled) {
    await Future.delayed(Duration(seconds: seconds), () async {
      Decimal avaxPrice = await getAVAXPriceUSD(avaxBodyRequest, url);
      List<Map> tokenValue = await Future.wait(tokensRequest.entries.map((entry) {
        if (blackList.contains(entry.key)) return Future.value({entry.key: Decimal.zero});
        return getTokenPriceUSD(avaxPrice, url, entry.value, entry.key);
      }));
      tokenValue.add({"AVAX": avaxPrice});
      tokenValue.forEach((Map map) {
        if (map.entries.first.value == Decimal.zero && !blackList.contains(map.entries.first.key)) blackList.add(map.entries.first.key);
      });
      threadMessage.payload = {"listenValue": tokenValue};
      // printWarning("sending $tokenValue");
      threadData.sendPort.send(threadMessage);
    });
    if (seconds == 0) seconds = 5;
  }
}

Future<int> priceHistory(List<dynamic> params, {ThreadData threadData, int id, ThreadMessage threadMessage}) async {
  printWarning("[T#${threadData.id} P#$id] Starting \"priceHistory\"");
  Map param = params.first;
  String url = param["url"];
  Map<String, Map<String, dynamic>> tokensRequest = param["tokensRequest"];
  Map<String, dynamic> networkTokenRequest = param["networkTokenRequest"] ?? {};
  bool pendingAvaxHistory = true;
  if (networkTokenRequest.length != 0) {
    /**
     * Using a receive port because we can't use SQLite to operate inside
     * another Isolate, so we sent the data back to the mainThread and wait...
     **/
    ReceivePort socket = ReceivePort();

    socket.listen((pending) {
      if (pending is bool && pending == true) pendingAvaxHistory = !pending;
    });

    String networkTokenHistory = await httpGetRequest(url, body: networkTokenRequest);

    threadMessage.payload = {"networkTokenHistory": jsonDecode(networkTokenHistory), 'waitAvaxPort': socket.sendPort};
    threadData.sendPort.send(threadMessage);
  }
  else
    pendingAvaxHistory = false;

  do {
    await Future.delayed(Duration(milliseconds: 50));
  } while (pendingAvaxHistory);
  if (tokensRequest.length > 0) {
    List<Map> rawMissingDays = await Future.wait(tokensRequest.entries.map((entry) {
      return wrapAsList(
        processName: "priceHistory",
        identifier: entry.key,
        future: httpGetRequest(url, body: entry.value),
      );
    }));
    List<Map> missingDays = [];
    rawMissingDays.forEach((tokenData) {
      String key = tokenData.entries.first.key;
      dynamic data = json.decode(tokenData.entries.first.value);
      missingDays.add({key: data});
    });

    rawMissingDays = [];
    threadMessage.payload = {"tokensHistory": missingDays};
    threadData.sendPort.send(threadMessage);
  }
  return 1;
}

Future<bool> updateTokenHistory({List<Map> days, String tokenName, ValueHistoryTable db}) async {
  await Future.forEach(days, (Map day) async {
    String price = day['priceUSD'];
    int date = day['date'];
    Decimal value = Decimal.parse(price);
    TokenHistory inserted = await db.insert(TokenHistory(tokenName: tokenName, value: value, dateTime: date));
    print(inserted);
  });
  return true;
}

Future<Map> getTokenPriceUSD(Decimal avaxUnitPriceUSD, String url, Map body, String tokenName) async {
  try {
    String response = await httpGetRequest(url, body: body);

    Decimal avaxPrice = avaxUnitPriceUSD;

    Map data = json.decode(response)["data"]["token"];

    if (data == null) throw Exception("Failed to recover value from $tokenName, block chain returned null");

    Decimal derivedETH = Decimal.parse(data["derivedETH"]);

    Decimal tokenValue = derivedETH * avaxPrice;

    return {tokenName: tokenValue};
  } catch (e) {
    print('Exception at getTokenPriceUSD -> Token Name: $tokenName, Details:\n$e');
    return {tokenName: Decimal.zero};
  }
}

Future<Decimal> getAVAXPriceUSD(Map body, url) async {
  String response = await httpGetRequest(url, body: body);
  String token0Label = json.decode(response)["data"]["pair"]["token0"]["symbol"];
  String token1Label = json.decode(response)["data"]["pair"]["token1"]["symbol"];
  Decimal token0Price = Decimal.parse(json.decode(response)["data"]["pair"]["token0Price"]);
  Decimal token1Price = Decimal.parse(json.decode(response)["data"]["pair"]["token1Price"]);

  return token0Label == "WAVAX" ? token1Price : token0Price;
}
