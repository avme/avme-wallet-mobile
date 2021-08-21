import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/boxes.dart';
import 'package:avme_wallet/app/model/service_data.dart';
import 'package:avme_wallet/app/model/token_chart.dart';
import 'package:avme_wallet/external/contracts/avme_contract.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:decimal/decimal.dart';

///Spawns a single thread to listen, and update our appState
void balanceSubscription(AvmeWallet appState, Map<int,AccountObject> accounts, int posCurrentAccount) async
{
  ///Validating if is the default/selected or a specific account to keep track of!

  List<Map<String, dynamic>> accountSpawnData = [];

  for(int pos = 0; pos < accounts.length; pos++)
  {
    if(pos == posCurrentAccount)
    {
      accountSpawnData.add({
        "id" : posCurrentAccount,
        "updateIn" : 10,
        "address" : EthereumAddress.fromHex(appState.currentAccount.address),
      });
    }
    else
    {
      accountSpawnData.add({
        "id" : pos ,
        "updateIn" : 30,
        "address" : EthereumAddress.fromHex(appState.accountList[pos].address),
      });
    }
  }
  print("Account to be processed");
  print(accountSpawnData);

  Map <String, dynamic> data = {
    "accounts" : accountSpawnData,
    "url" : env['NETWORK_URL'],
    "contractAddress" : EthereumAddress.fromHex(env['CONTRACT_ADDRESS']),
  };

  ReceivePort receivePort = ReceivePort();
  ServiceData serviceData = ServiceData(data,receivePort.sendPort);

  appState.services["balanceSubscription"] = await Isolate.spawn(
    startBalanceSubscription,
    serviceData
  );

  receivePort.listen((data) {
    print(data);
    Map response;
    ///We validate who is returning data, since we don't use multiple Isolates,
    ///for the same purpose (like previously seen) to save memory! @_@
    /*
      appState.metaCoin.value = response["avax"];
      appState.token.value = response["avme"];
    */

    if(data.containsKey("metacoin"))
    {
      response = data["metacoin"];
      if(appState.accountList[response['id']].waiBalance != response["balance"])
        appState.accountList[response['id']].updateAccountBalance = response["balance"];

      double balanceFromBigInt =
        double.tryParse(weiToFixedPoint(response["balance"].toString()));

      double metacoinValue = double.tryParse(appState.metaCoin.value);
      double result = balanceFromBigInt * metacoinValue;
      appState.accountList[response['id']].currencyBalance = result;
    }
    if(data.containsKey("token"))
    {
      response = data["token"];
      if(appState.accountList[response['id']].rawTokenBalance != response["tokenBalance"])
        appState.accountList[response['id']].updateTokenBalance = response["tokenBalance"];

      double tokenFromBigInt =
      double.tryParse(weiToFixedPoint(response["tokenBalance"].toString()));

      double tokenMarketValue = double.tryParse(appState.token.value);
      double result = tokenFromBigInt * tokenMarketValue;
      appState.accountList[response['id']].currencyTokenBalance = result;
    }
  });
}

void startBalanceSubscription(ServiceData param)
{
  param.data["accounts"].forEach((account) {
    account["url"] = param.data["url"];
    account["contractAddress"] = param.data["contractAddress"];
    watchBalanceChanges(ServiceData(account,param.sendPort));
    watchTokenChanges(ServiceData(account,param.sendPort));
  });
}

///Isolated function to watch balance changes
void watchBalanceChanges(ServiceData param) async
{
  EthereumAddress address = param.data["address"];
  http.Client httpClient = http.Client();
  Web3Client ethClient = Web3Client(param.data["url"], httpClient);
  int seconds = 0;
  while(true)
  {
    await Future.delayed(Duration(seconds: seconds), () async{
      EtherAmount balance = await ethClient.getBalance(address);
      param.sendPort.send(
        {
          "metacoin": {"balance" : balance.getInWei, "id" : param.data["id"]}
        }
      );
      if(seconds == 0) seconds = param.data["updateIn"];
    });
  }
}

///Isolated function to watch token balance changes
void watchTokenChanges(ServiceData param) async
{
  EthereumAddress address = param.data["address"];
  http.Client httpClient = http.Client();
  Web3Client ethClient = Web3Client(param.data["url"], httpClient);
  AvmeContract contract = AvmeContract(address: param.data["contractAddress"],client: ethClient, chainId: 43113);
  int seconds = 0;
  while(true)
  {
    await Future.delayed(Duration(seconds: seconds), () async{
      BigInt tokenBalance = await contract.balanceOf(address);
      param.sendPort.send(
        {
          "token": {"tokenBalance" : tokenBalance, "id" : param.data["id"]}
        }
      );
      if(seconds == 0) seconds = param.data["updateIn"];
    });
  }
}

void valueSubscription(AvmeWallet appState) async
{
  ReceivePort isolatePort = ReceivePort();

  Map <String, dynamic> data = {"env":env};
  Box<TokenChart> box = Boxes.getHistory();
  ServiceData isolateData = ServiceData(data,isolatePort.sendPort);
  appState.services["valueSubscription"] = await Isolate.spawn(startValueSubscription,isolateData);

  isolatePort.listen((data) {

    ///We validate who is returning data, since we don't use multiple Isolates,
    ///for the same purpose (like previously seen) to save memory! @_@

    Map response;
    print(data);
    if(data.containsKey("watchTokenPriceHistory"))
    {
      response = data["watchTokenPriceHistory"];
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

      tokenMap.forEach((key, value) {
        Decimal metaCoinValue = Decimal.fromInt(1) / Decimal.parse(metaCoinMap[key]);
        Decimal tokenValue = metaCoinValue * Decimal.parse(value);
        // print("$key: value:$tokenValue");
        dashboardChart.addToList(key, tokenValue.toString());
      });
      box.put(0,dashboardChart);
    }

    if(data.containsKey("watchCoinValueChanges"))
    {
      response = data["watchCoinValueChanges"];
      appState.metaCoin.value = response["avax"];
      appState.token.value = response["avme"];
    }
  });
}

void startValueSubscription(ServiceData param)
{
  String url = param.data["env"]["MAINNET_URL"] + ":${param.data["env"]["MAINNET_PORT"]}" + param.data["env"]["MAINNET_VALUEPATH"];

  print("Spawning watchTokenPriceHistory");

  watchTokenPriceHistory(
    ServiceData({
        "url" : url,
        "tokenBodyRequest" : {"query": "{tokenDayDatas(first: 30,orderBy: date,orderDirection: desc,where:{token: \"0x1ecd47ff4d9598f89721a2866bfeb99505a413ed\"}) { date priceUSD }}"},
        "metaCoinBodyRequest" : {"query": "{tokenDayDatas(first: 30,orderBy: date,orderDirection: desc,where:{token: \"0xde3a24028580884448a5397872046a019649b084\"}) { date priceUSD }}"},
      }
    ,param.sendPort));

  print("Spawning watchCoinValueChanges");
  watchCoinValueChanges(
      ServiceData({
        "url" : url,
        "avaxBodyRequest" : {"query": "{pair(id: \"0x9ee0a4e21bd333a6bb2ab298194320b8daa26516\") {token0 {symbol} token1 {symbol} token0Price token1Price}}"},
        "tokenBodyRequest" : {"query": "{token(id: \"0x1ecd47ff4d9598f89721a2866bfeb99505a413ed\"){symbol derivedETH}}"}
      }
    ,param.sendPort));
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
        }
      );
    });
    if(seconds == 0) seconds = 3600;
  }
}

void watchCoinValueChanges(ServiceData param) async
{
  int seconds = 0;
  String url = param.data["url"];
  Map <String, dynamic> tokenBodyRequest = param.data["tokenBodyRequest"];
  Map <String, dynamic> avaxBodyRequest = param.data["avaxBodyRequest"];
  String avmePrice;
  String avaxPrice;
  while(true)
  {
    await Future.delayed(Duration(seconds: seconds), () async{
      avaxPrice = await getAVAXPriceUSD(avaxBodyRequest, url);
      avmePrice = await getAVMEPriceUSD(avaxPrice, url, tokenBodyRequest);

      param.sendPort.send(
        {"watchCoinValueChanges": {"avax": avaxPrice, "avme": avmePrice}
      });
    });
    if(seconds == 0) seconds = 5;
  }
}

Future<String> httpGetRequest(String urlString, Map body) async
{
  Uri url = Uri.parse(urlString);
  var response = await http.post(url,
      body: json.encode(body),
      headers: {"Content-Type": "application/json"});
  return response.body;
}

Future<String> getAVMEPriceUSD(String avaxUnitPriceUSD, String url, Map body) async
{
  String response = await httpGetRequest(url, body);
  Decimal avaxPrice = Decimal.parse(avaxUnitPriceUSD);
  Decimal derivedETH = Decimal.parse(json.decode(response)["data"]["token"]["derivedETH"]);
  Decimal avmeValue = derivedETH * avaxPrice;
  return avmeValue.toString();
}

Future<String> getAVAXPriceUSD(Map body, url) async
{
  String response = await httpGetRequest(url, body);
  String token0Label = json.decode(response)["data"]["pair"]["token0"]["symbol"];
  String token1Label = json.decode(response)["data"]["pair"]["token1"]["symbol"];
  String token0Price = json.decode(response)["data"]["pair"]["token0Price"];
  String token1Price = json.decode(response)["data"]["pair"]["token1Price"];

  return token0Label == "WAVAX" ? token1Price : token0Price;
}

Future<String> getTokenChartHistory(Map body, url) async
{
  String response = await httpGetRequest(url, body);
  return response;
}
