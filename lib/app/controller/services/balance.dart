import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:avme_wallet/app/controller/database/value_history.dart';
import 'package:avme_wallet/app/controller/services/push_notification.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/service_data.dart';
import 'package:avme_wallet/app/model/value_history.dart';
import 'package:avme_wallet/external/contracts/erc20_contract.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:decimal/decimal.dart';

///Spawns a single thread to listen, and update our appState
Future<bool> balanceSubscription(AvmeWallet appState) async
{
  bool didBalanceUpdate = false;
  ///Validating if is the default/selected or a specific account to keep track of!
  List<Map<String, dynamic>> accountSpawnData = [];
  Map<int,AccountObject> accounts = appState.accountList;
  int currentWalletId = appState.currentWalletId;
  ///List of previously updated accounts
  ///{"0":[true,true]}
  ///{"key":[metacoinUpdated,tokenUpdated]}
  // List<String> didUpdatePreviously = [];
  for(int pos = 0; pos < accounts.length; pos++)
    if(pos == currentWalletId)
      accountSpawnData.add({
        "id" : currentWalletId,
        "updateIn" : 10,
        "address" : EthereumAddress.fromHex(appState.currentAccount.address),
      });
    else
      accountSpawnData.add({
        "id" : pos ,
        "updateIn" : 15,
        "address" : EthereumAddress.fromHex(appState.accountList[pos].address),
      });


  Map <String, dynamic> data = {
    "accounts" : accountSpawnData,
    "url" : env['NETWORK_URL'],
    "activeTokens": appState.activeContracts.tokens,
    "contracts": appState.activeContracts.sContracts.contracts
  };

  ReceivePort receivePort = ReceivePort();
  ServiceData serviceData = ServiceData(data,receivePort.sendPort);

  appState.services["balanceSubscription"] = await Isolate.spawn(
    _startBalanceSubscription,
    serviceData
  );
  receivePort.listen((data) {
    List<Map> balanceData = data["_balanceSubscription"]["balance"];
    int accId = data["_balanceSubscription"]["id"];

    ///Recovering the account to apply the requested data
    AccountObject accountObject = appState.accountList[accId];
    double oldBalance = 0;
    double updatedBalance = 0;

    balanceData.forEach((Map requestedBalance) {
      String key = requestedBalance.entries.first.key;
      if(key == "empty")
        return;
      print("processing $key");
      ///Recovering the requested value as bigInt/Wei
      BigInt balance = requestedBalance.entries.first.value;

      ///...then convert it to normal double
      double balanceUSD =
        double.tryParse(weiToFixedPoint(balance.toString()));

      if(key == "AVAX")
      {
        oldBalance = accountObject.networkBalance; ///Double
        updatedBalance = oldBalance;

        ///Checking the difference in BigInt/Wei
        if(accountObject.networkTokenBalance != balance)
          accountObject.updateAccountBalance = balance;

        ///Recovering the USD price of "Network Token" that we retrieved in
        ///the valueSubscription routine...
        Decimal networkTokenValue = appState.networkToken.decimal; ///Stored as String

        ///Calculating the balance
        updatedBalance = balanceUSD * networkTokenValue.toDouble();

        ///Checking if the balance has been incremented
        //TODO: Fix da sheet
        // if(accountObject.networkBalance != null
        //     && accountObject.networkBalance < updatedBalance
        //     && didBalanceUpdate)
        // {
        //   double difference = updatedBalance - accountObject.networkBalance;
        //   print("[[[DIFFERENCE]]]");
        //   print(difference);
        //   if(difference > 0)
        //     PushNotification.showNotification(
        //         id: 9,
        //         title: "Transfer received ($key)",
        //         body: "Account Update: "
        //             "You received \$${difference.toStringAsFixed(2)}\n ($key) in the account ${accountObject.title}.",
        //         payload: "app/history"
        //     );
        // }

        ///Finally we update the balance in the account
        accountObject.networkBalance = updatedBalance;
        appState.updateAccountObject(accId, accountObject);
      }
      else
      {
        ///When consulting a Smart Contract that does not exist on
        ///api.thegraph.com the default value will be 1 USD
        double tokenValue = 1;
        if(accountObject.tokensBalanceList.containsKey(key))
        {
          oldBalance = accountObject.tokensBalanceList[key]["balance"]; ///Double
        }

        ///Recovering the USD price of "Token" that we retrieved in
        ///the valueSubscription routine...

        tokenValue =
            appState.activeContracts.token.decimal(key).toDouble(); ///Stored as String

        updatedBalance = oldBalance;

        Map<String, dynamic> preparedData = {};

        preparedData["wei"] = balance;

        ///Calculating the balance
        updatedBalance = balanceUSD * tokenValue;

        preparedData["balance"] = updatedBalance;
        
        ///Checking the prepared data and inserting it
        // print("NOSSO MAP $key");
        // print(preparedData);


        String mainName = key.replaceAll(" testnet", "");
        
        ///Checking if the balance has been incremented
        if(accountObject.tokensBalanceList[key] != null
            && accountObject.tokensBalanceList[key]["balance"] < updatedBalance
            && didBalanceUpdate)
        {
          double difference = updatedBalance - accountObject.tokensBalanceList[key]["balance"];
          if(difference > 0)
            PushNotification.showNotification(
              id: 9,
              title: "Transfer received ($key)",
              body: "Account Update: "
                  "You received \$${difference.toStringAsFixed(2)}\n ($key) in the account ${accountObject.title}.",
              payload: "app/history"
            );
        }

        accountObject.tokensBalanceList[key] = preparedData;
        
        print(appState.activeContracts.tokens.contains(mainName));

        if(appState.activeContracts.tokens.contains(mainName))
        {
          accountObject.tokensBalanceList[mainName] = preparedData;
        }
        didBalanceUpdate = true;
      }
    });
  });

  do await Future.delayed(Duration(milliseconds: 150));
  while(!didBalanceUpdate);
  return didBalanceUpdate;
}

void _startBalanceSubscription(ServiceData param)
{
  param.data["accounts"].forEach((account) {
    account["url"] = param.data["url"];
    account["contracts"] = param.data["contracts"];
    account["activeTokens"] = param.data["activeTokens"];
    account["contractAddress"] = param.data["contractAddress"];
    _balanceSubscription(ServiceData(account,param.sendPort));
  });
}

void _balanceSubscription(ServiceData account) async
{
  EthereumAddress address = account.data["address"];
  http.Client httpClient = http.Client();
  Web3Client ethClient = Web3Client(account.data["url"], httpClient);

  ///List of contracts
  Map<String, List> contracts = account.data["contracts"];

  ///Remember, mounted contracts is stored as
  ///[<ContractAbi>"Contract Abi", <String>"ContractAddress", <String>"ChainID"]

  Map<String, ERC20> contractsERC20 = {};

  account.data["activeTokens"].forEach((String tokenName) {
    try
    {
      contractsERC20[tokenName] = ERC20(
        contracts[tokenName][0], // ContractAbi Object
        address: EthereumAddress.fromHex(contracts[tokenName][1]), // String Address
        client: ethClient,
        chainId: int.tryParse(contracts[tokenName][2]), //Chain ID
      );
    }
    catch(e)
    {
      print("$tokenName -> $e");
      throw e;
    }
  });
  int seconds = 0;
  List<String> blackList = [];
  while(true)
  {
    await Future.delayed(Duration(seconds: seconds), () async{
      /// AVAX/Network balance
      EtherAmount balance = await ethClient.getBalance(address);

      List<Map> tokenBalance = [];

      /// Tokens balance as List<Map<String TokenName, BigInt balance>>
      tokenBalance = await Future.wait(
        contractsERC20.entries.map((contractItem) {
          if(blackList.contains(contractItem.key))
            return Future.value({contractItem.key : {"empty"}});
          return wrapAsList(
            identifier: contractItem.key,
            future: contractItem.value.balanceOf(address),
            processName: "_balanceSubscription"
          );
        })
      );

      tokenBalance.insert(0, {"AVAX": balance.getInWei});
      tokenBalance.forEach((Map map) {
        if(map.entries.first.value == "empty" && !blackList.contains(map.entries.first.key))
          blackList.add(map.keys.first);
      });
      blackList.forEach((blacklisted) =>
        tokenBalance.removeWhere((element) => element.containsKey(blacklisted))
      );
      account.sendPort.send(
        {
          "_balanceSubscription": {"balance" : tokenBalance, "id" : account.data["id"]}
        }
      );
      print(blackList);
      if(seconds == 0) seconds = account.data["updateIn"];
    });
  }
}

///Simple wrapper to identify later
Future<Map> wrapAsList({String identifier, Future future, String processName}) async
{
  dynamic result = false;
  print("wrapping $identifier");
  try {
    result = await future;
  }
  catch(e)
  {
    if(e is RangeError)
    {
      print("[WARNING -> wrapAsList | $processName] Balance Subscription failed while processing $identifier, \n at $e");
    }
    return {identifier: "empty"};
  }
  return {identifier: result};
}

Future<bool> valueSubscription(AvmeWallet appState) async
{
  ReceivePort isolatePort = ReceivePort();
  bool didValueUpdated = false;
  Map <String, dynamic> data = {
    "url": "${env["MAINNET_URL"]}:${env["MAINNET_PORT"]}${env["MAINNET_VALUEPATH"]}",
    "activeTokens": appState.activeContracts.tokens,
    "contractRaw": appState.activeContracts.sContracts.contractsRaw
  };

  Map<String, List<int>> missingDates = {};

  ValueHistoryTable tokenHistory = ValueHistoryTable.instance;

  await Future.forEach(appState.activeContracts.tokens, (String token) async {
    missingDates[token] = await tokenHistory.getMissingDays(token.toUpperCase());
  });

  data["avaxDates"]= await tokenHistory.getMissingDays("AVAX");
  data['missingDates'] = missingDates;

  ServiceData isolateData = ServiceData(data,isolatePort.sendPort);
  appState.services["valueSubscription"] = await Isolate.spawn(startValueSubscription,isolateData);
  isolatePort.listen((dynamic data) async {
    if(data.containsKey("listenValue"))
    {
      List response = data["listenValue"];
      response.forEach((mapEntry){
        String key = mapEntry.entries.first.key;
        Decimal value = mapEntry.entries.first.value;
        if(key == "AVAX"){
          appState.networkToken.updateToken(value);
        }
        else
        {
          appState.activeContracts.token.updateToken(key, value);
          if(appState.activeContracts.tokens.contains("$key testnet"))
            appState.activeContracts.token.updateToken("$key testnet", value);
        }
        didValueUpdated = true;
      });
    }
    ///Processing AVAX days
    if(data.containsKey("networkTokenHistory")) {
      Map<String, dynamic> response = data["networkTokenHistory"];
      List<Map> missingDays = response["data"]["tokenDayDatas"].cast<Map>();
      bool pending = await updateTokenHistory(tokenName: "AVAX", days: missingDays, db: tokenHistory);
      SendPort waitAvaxPort = data['waitAvaxPort'];
      waitAvaxPort.send(pending);
    }
    ///Processing Tokens days
    if(data.containsKey("tokensHistory")) {
      print("SOMETHING RETURNED");
      print(data["tokensHistory"]);
      List<Map> tokens = data["tokensHistory"];
      await Future.forEach(tokens, (Map tokenData) async
      {
        String tokenName = tokenData.entries.first.key;
        List<Map> missingDays = tokenData.entries.first.value["data"]["tokenDayDatas"].cast<Map>();
        await updateTokenHistory(tokenName: tokenName, days: missingDays, db: tokenHistory);
      });
    }
  });
  do await Future.delayed(Duration(milliseconds: 150));
  while(!didValueUpdated);
  return didValueUpdated;
}

Future<bool> updateTokenHistory({
  List<Map> days,
  String tokenName,
  ValueHistoryTable db
})
async {
  await Future.forEach(days, (Map day) async
  {
    String price = day['priceUSD'];
    int date = day['date'];
    Decimal value = Decimal.parse(price);
    TokenHistory inserted = await db.insert(
      TokenHistory(tokenName: tokenName, value: value, dateTime: date)
    );
    print(inserted);
  });
  return true;
}
Future<void> startValueSubscription(ServiceData param) async
{
  String url = param.data["url"];

  Map<String, Map<String, String>> tokenHistoryBody = {};
  
  Map<String, Map> contractsRaw = param.data["contractRaw"];
  String listenBody = "{token(id: \"CONTRACT_ADDRESS\"){symbol derivedETH}}";
  String watchPriceBody = "{tokenDayDatas(first: 30,orderBy: date,orderDirection: desc, where:{token: \"CONTRACT_ADDRESS\", date_in:[FILTERED_DAYS]}) { date priceUSD }}";
  Map<String, List<int>> missingDates = param.data["missingDates"];
  Map<String, Map<String, String>> tokenValueParam = {};

  Future.forEach(param.data["activeTokens"], (String token) async {
    String tokenValue = "";
    String watchToken = "";
    ///Não é Testnet, do contrario atribuir a consulta como AVME
    if(!token.contains('testnet'))
    {
      print("USING $token");
      tokenValue = listenBody.replaceFirst('CONTRACT_ADDRESS', contractsRaw[token]['address']);
      if(missingDates[token].length > 0)
        watchToken = watchPriceBody.replaceFirst('CONTRACT_ADDRESS', contractsRaw[token]['address'])
          .replaceFirst('FILTERED_DAYS', missingDates[token].join(', '));
    }
    else
    {
      tokenValue = listenBody.replaceFirst('CONTRACT_ADDRESS', contractsRaw["AVME"]['address']);
      if(missingDates[token].length > 0)
        watchToken = watchPriceBody.replaceFirst('CONTRACT_ADDRESS', contractsRaw["AVME"]['address'])
            .replaceFirst('FILTERED_DAYS', missingDates[token].join(', '));
    }
    tokenValueParam[token] = {"query": tokenValue};
    if(watchToken != "")
      tokenHistoryBody[token] = {"query": watchToken};
  });
  
  listenValue(
    ServiceData({
      "url" : url,
      "tokensRequest" : tokenValueParam,
      "avaxBodyRequest" : {"query": "{pair(id: \"0x9ee0a4e21bd333a6bb2ab298194320b8daa26516\") {token0 {symbol} token1 {symbol} token0Price token1Price}}"},
    },
    param.sendPort));
  
  Map<String, dynamic> data = {
    "url" : url,
    "tokensRequest" : tokenHistoryBody,
  };

  ///Mounting AVAX dates filter
  List<int> avax = param.data["avaxDates"];
  
  if(avax.length > 0)
  {
    data["networkTokenRequest"] = {
      "query": "{tokenDayDatas(first: 30,orderBy: date,orderDirection: desc,where:{token: \"0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7\", date_in:[FILTERED_DAYS]}) { date priceUSD }}"
        .replaceFirst("FILTERED_DAYS", avax.join(', '))
    };
  }
  
  watchTokenPriceHistory(ServiceData(data,param.sendPort));
}

void listenValue(ServiceData param) async
{
  int seconds = 0;
  String url = param.data["url"];
  Map <String, Map<String,dynamic>> tokensRequest = param.data["tokensRequest"];
  Map <String, String> avaxBodyRequest = param.data["avaxBodyRequest"];
  List blackList = [];

  do
  {
    await Future.delayed(Duration(seconds: seconds), () async {
      Decimal avaxPrice = await getAVAXPriceUSD(avaxBodyRequest, url);
      List<Map> tokenValue = await Future.wait(
        tokensRequest.entries.map((entry) {
          if(blackList.contains(entry.key))
            return Future.value({entry.key:Decimal.zero});
          return getTokenPriceUSD(avaxPrice, url, entry.value, entry.key);
        })
      );
      tokenValue.add({"AVAX":avaxPrice});
      tokenValue.forEach((Map map) {
        if(map.entries.first.value == Decimal.zero && !blackList.contains(map.entries.first.key))
          blackList.add(map.entries.first.key);
      });
      print(tokenValue);
      param.sendPort.send(
          {"listenValue": tokenValue});
    });
    if(seconds == 0) seconds = 5;
  }
  while(true);
}

void watchTokenPriceHistory(ServiceData param) async
{
  String url = param.data["url"];
  Map <String, Map<String,dynamic>> tokensRequest = param.data["tokensRequest"];
  Map <String, dynamic> networkTokenRequest = param.data["networkTokenRequest"] ?? {};

  bool pendingAvaxHistory = true;
  if(networkTokenRequest.length != 0)
  {
    /**
     * Using a receive port because we can't use SQLite to operate inside
     * another Isolate, so we sent the data back to the mainThread and wait...
     **/
    ReceivePort socket = ReceivePort();

    socket.listen((pending) {
      if(pending is bool && pending == true)
          pendingAvaxHistory = !pending;
    });

    String networkTokenHistory = await httpGetRequest(url, body: networkTokenRequest);

    param.sendPort.send({
      "networkTokenHistory" : jsonDecode(networkTokenHistory),
      'waitAvaxPort':socket.sendPort
    });
  }
  else
    pendingAvaxHistory = false;

  do await Future.delayed(Duration(milliseconds: 50)); while(pendingAvaxHistory);

  if(tokensRequest.length > 0)
  {
    List<Map> rawMissingDays = await Future.wait(
      tokensRequest.entries.map((entry) {
        return wrapAsList(
          processName: "watchTokenPriceHistory",
          identifier: entry.key,
          future: httpGetRequest(url, body: entry.value),
        );
      })
    );
    List<Map> missingDays = [];
    rawMissingDays.forEach((tokenData) {
      String key = tokenData.entries.first.key;
      dynamic data = json.decode(tokenData.entries.first.value);
      missingDays.add({key : data});
    });

    rawMissingDays = [];

    param.sendPort.send({
      "tokensHistory": missingDays
    });
  }
}

Future<Map> getTokenPriceUSD(Decimal avaxUnitPriceUSD, String url, Map body, String tokenName) async
{
  try
  {
    String response = await httpGetRequest(url, body: body);

    Decimal avaxPrice = avaxUnitPriceUSD;

    Map data = json.decode(response)["data"]["token"];

    if(data == null)
      throw Exception("Failed to recover value from $tokenName, block chain returned null");

    Decimal derivedETH = Decimal.parse(data["derivedETH"]);

    Decimal tokenValue = derivedETH * avaxPrice;

    return {tokenName:tokenValue};
  } catch(e)
  {
    print('Exception at getTokenPriceUSD -> Token Name: $tokenName, Details:\n$e');
    return {tokenName: Decimal.zero};
  }
}

Future<Decimal> getAVAXPriceUSD(Map body, url) async
{
  String response = await httpGetRequest(url, body: body);
  String token0Label = json.decode(response)["data"]["pair"]["token0"]["symbol"];
  String token1Label = json.decode(response)["data"]["pair"]["token1"]["symbol"];
  Decimal token0Price = Decimal.parse(json.decode(response)["data"]["pair"]["token0Price"]);
  Decimal token1Price = Decimal.parse(json.decode(response)["data"]["pair"]["token1Price"]);

  return token0Label == "WAVAX" ? token1Price : token0Price;
}

Future<Map<int,List>> requestBalanceByAddress(Map<int, String> addresses) async
{
  Map<int, List> data = {};
  await Future.forEach(addresses.entries, (entry) async{
    EthereumAddress ethereumAddress = EthereumAddress.fromHex(entry.value);
    String url = env['NETWORK_URL'];

    http.Client httpClient = http.Client();
    Web3Client ethClient = Web3Client(url, httpClient);

    BigInt balance = (await ethClient.getBalance(ethereumAddress)).getInWei;
    String convertedBalance = balance.toDouble() != 0 ? weiToFixedPoint(balance.toString()) : "0";

    data[entry.key] = [
      entry.value,
      shortAmount(convertedBalance,length: 6),
    ];
  });
  return data;
}
