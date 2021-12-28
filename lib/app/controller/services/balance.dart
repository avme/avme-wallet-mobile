import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:avme_wallet/app/controller/services/contract.dart';
import 'package:avme_wallet/app/controller/services/database_token_value.dart';
import 'package:avme_wallet/app/controller/services/push_notification.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/active_contracts.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/boxes.dart';
import 'package:avme_wallet/app/model/service_data.dart';
import 'package:avme_wallet/app/model/token_chart.dart';
import 'package:avme_wallet/app/model/token_data.dart';
import 'package:avme_wallet/external/contracts/erc20_contract.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
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

// ///Isolated function to watch balance changes
// void avaxBalanceChanges(ServiceData account) async
// {
//   EthereumAddress address = account.data["address"];
//   http.Client httpClient = http.Client();
//   Web3Client ethClient = Web3Client(account.data["url"], httpClient);
//   int seconds = 0;
//   while(true)
//   {
//     await Future.delayed(Duration(seconds: seconds), () async{
//       EtherAmount balance = await ethClient.getBalance(address);
//       account.sendPort.send(
//         {
//           "metacoin": {"balance" : balance.getInWei, "id" : account.data["id"]}
//         }
//       );
//       if(seconds == 0) seconds = account.data["updateIn"];
//     });
//   }
// }


void _startBalanceSubscription(ServiceData param)
{
  param.data["accounts"].forEach((account) {
    account["url"] = param.data["url"];
    account["contracts"] = param.data["contracts"];
    account["activeTokens"] = param.data["activeTokens"];
    account["contractAddress"] = param.data["contractAddress"];
    // avaxBalanceChanges(ServiceData(account,param.sendPort));
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

  Map<String,ERC20> contractsERC20 = {};

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
    }
  );
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
            return wrapAsList(identifier: contractItem.key,
              future: contractItem.value.balanceOf(address));
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
Future<Map> wrapAsList({String identifier , Future future}) async
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
      print("[WARNING -> wrapAsList] Balance Subscription failed while processing $identifier, \n at $e");
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

  // Box<TokenChart> box = Boxes.getHistory();
  ServiceData isolateData = ServiceData(data,isolatePort.sendPort);
  appState.services["valueSubscription"] = await Isolate.spawn(startValueSubscription,isolateData);

  isolatePort.listen((data) {
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

    if(data.containsKey("watchTokenPriceHistory"))
    {
      //TODO: Change this entire thing to support multiple tokens, for now only AVAX works, and finish stuff here
      Map response = data["watchTokenPriceHistory"];
      print(response['tokenChart']["data"].runtimeType);
      TokenChart dashboardChart = TokenChart();
      Map tokenMap = {};
      Map metaCoinMap = {};

      List tokenList = response['tokenChart']['data']['tokenDayDatas'];
      List metaCoinList =  response['metaCoinHistory']['data']['tokenDayDatas'];

      tokenList.forEach((element) {
        tokenMap[element["date"]] = element["priceUSD"];
      });
      metaCoinList.forEach((element) {
        metaCoinMap[element["date"]] = element["priceUSD"];
      });

      // tokenMap.forEach((date, value) {
      //   int epochDay = date;
      //   ///Gabriel: Aqui ele faz o cálculo para cada dia
      //   Decimal metaCoinValue = Decimal.fromInt(1) / Decimal.parse(metaCoinMap[epochDay]);
      //   Decimal tokenValue = metaCoinValue * Decimal.parse(value);
      //
      //   print("AVAX === day: $epochDay | value:$metaCoinValue");
      //
      //   ///Pseudo insert em database
      //   List<Map> databaseChart = [];
      //   databaseChart.insert(0, {
      //     "tokenName" : "AVME",
      //     "value": tokenValue,
      //     "datetime": epochDay
      //   });
      //
      //   //Apenas para testes
      //   DatabaseInterface.instance.create(TokenValue(
      //       tokenName: 'AVAX', value: metaCoinValue.toDouble(), dateTime: epochDay))
      //       .then((value) {
      //     DatabaseInterface.instance.read(epochDay).then((value) => print('Inserindo na database: $value'));
      //   });
      //
      //   dashboardChart.addToList(epochDay, tokenValue.toString());
      // });
    }
  });
  do await Future.delayed(Duration(milliseconds: 150));
  while(!didValueUpdated);
  return didValueUpdated;
}

void startValueSubscription(ServiceData param)
{

  // print("Spawning watchTokenPriceHistory");
  //
  // watchTokenPriceHistory(
  //   ServiceData({
  //       "url" : url,
  //       "tokenBodyRequest" : {"query": "{tokenDayDatas(first: 30,orderBy: date,orderDirection: desc,where:{token: \"0xde3a24028580884448a5397872046a019649b084\"}) { date priceUSD }}"},
  //       "metaCoinBodyRequest" : {"query": "{tokenDayDatas(first: 30,orderBy: date,orderDirection: desc,where:{token: \"0xde3a24028580884448a5397872046a019649b084\"}) { date priceUSD }}"},
  //     }
  //   ,param.sendPort));


  Map<String,Map> contractsRaw = param.data["contractRaw"];
  String tokenRequest = "{token(id: \"CONTRACT_ADDRESS\"){symbol derivedETH}}";
  Map<String,Map<String,String>> paramList = {};
  param.data["activeTokens"].forEach((String token)
  {
    // if(!token.contains('testnet'))
      paramList[token] = {"query":tokenRequest.replaceFirst('CONTRACT_ADDRESS', token.contains('testnet')
        ? param.data["contractRaw"]["AVME"]['address']
        : param.data["contractRaw"][token]['address'])};
  });

  listenValue(
      ServiceData({
        "url" : param.data["url"],
        "tokenBodyRequest" : paramList,
        "avaxBodyRequest" : {"query": "{pair(id: \"0x9ee0a4e21bd333a6bb2ab298194320b8daa26516\") {token0 {symbol} token1 {symbol} token0Price token1Price}}"},
      }
    ,param.sendPort));
}

void listenValue(ServiceData param) async
{
  int seconds = 0;
  String url = param.data["url"];
  Map <String, Map<String,dynamic>> tokenBodyRequest = param.data["tokenBodyRequest"];
  Map <String, String> avaxBodyRequest = param.data["avaxBodyRequest"];
  List blackList = [];
  while(true)
  {
    await Future.delayed(Duration(seconds: seconds), () async {
      Decimal avaxPrice = await getAVAXPriceUSD(avaxBodyRequest, url);
      List<Map> tokenValue = await Future.wait(
        tokenBodyRequest.entries.map((entry) {
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
}

void watchTokenPriceHistory(ServiceData param) async
{

  int seconds = 0;
  String url = param.data["url"];
  Map <String, dynamic> tokenBodyRequest = param.data["tokenBodyRequest"];
  Map <String, dynamic> metaCoinBodyRequest = param.data["metaCoinBodyRequest"];
  String tokenHistory;
  String metaCoinHistory;

  while(true)
  {
    await Future.delayed(Duration(seconds: seconds), () async{
      tokenHistory = await getTokenChartHistory(tokenBodyRequest, url);
      metaCoinHistory = await getTokenChartHistory(metaCoinBodyRequest, url);

      param.sendPort.send({
        "watchTokenPriceHistory":{
          "tokenChart": json.decode(tokenHistory),
          "metaCoinHistory": json.decode(metaCoinHistory)
        }
      });
    });
    if(seconds == 0) seconds = 3600;
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

Future<String> getTokenChartHistory(Map body, url) async
{
  String response = await httpGetRequest(url, body: body);
  return response;
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
