import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/boxes.dart';
import 'package:avme_wallet/app/model/service_data.dart';
import 'package:avme_wallet/app/model/token_chart.dart';
import 'package:avme_wallet/app/packages/services.dart';
import 'package:avme_wallet/external/contracts/avme_contract.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:decimal/decimal.dart';

///Spawns two threads to listen, and update our appState
void updateBalanceService(AvmeWallet appState) async
{
  AccountObject accountWallet = appState.currentAccount;
  ServiceData balanceData;
  ServiceData tokenData;
  ReceivePort balancePort = ReceivePort();
  ReceivePort tokenPort = ReceivePort();

  EthereumAddress address = await accountWallet.account.privateKey.extractAddress();

  Map <String, dynamic> data = {
    "etheriumAddress" : address,
    "url" : env['NETWORK_URL']
  };

   data = {
    "etheriumAddress" : address,
    "contractAddress" : EthereumAddress.fromHex(env["CONTRACT_ADDRESS"]),
    "url" : env['NETWORK_URL']
  };
  balanceData = ServiceData(data, balancePort.sendPort);
  appState.services["watchBalanceChanges"] = await Isolate.spawn(watchBalanceChanges,balanceData);
  balancePort.listen((data) {
    if(accountWallet.waiBalance != data["balance"]) accountWallet.updateAccountBalance = data["balance"];
  });

  tokenData = ServiceData(data, tokenPort.sendPort);
  appState.services["watchTokenChanges"] = await Isolate.spawn(watchTokenChanges, tokenData);
  tokenPort.listen((data){
    if(accountWallet.rawTokenBalance != data["tokenBalance"]) accountWallet.updateTokenBalance = data["tokenBalance"];
  });
}
///Isolated function to watch balance changes
void watchBalanceChanges(ServiceData param) async
{
  EthereumAddress address = param.data["etheriumAddress"];
  http.Client httpClient = http.Client();
  Web3Client ethClient = Web3Client(param.data["url"], httpClient);
  int seconds = 0;
  while(true)
  {
    await Future.delayed(Duration(seconds: seconds), () async{
      EtherAmount balance = await ethClient.getBalance(address);
      param.sendPort.send(
          {
            "balance" : balance.getInWei
          }
      );
      if(seconds == 0) seconds = 10;
    });
  }
}
///Isolated function to watch token balance changes
void watchTokenChanges(ServiceData param) async
{
  EthereumAddress address = param.data["etheriumAddress"];
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
          "tokenBalance" : tokenBalance
        }
      );
      if(seconds == 0) seconds = 10;
    });
  }
}

void getTokenPriceHistory(AvmeWallet appState) async
{
  ReceivePort isolatePort = ReceivePort();

  Map <String, dynamic> data =
  {
    "url" : env["MAINNET_URL"] + ":${env["MAINNET_PORT"]}" + env["MAINNET_VALUEPATH"],
    "tokenBodyRequest" : {"query": "{tokenDayDatas(first: 30,orderBy: date,orderDirection: desc,where:{token: \"0x1ecd47ff4d9598f89721a2866bfeb99505a413ed\"}) { date priceUSD }}"},
    "metaCoinBodyRequest" : {"query": "{tokenDayDatas(first: 30,orderBy: date,orderDirection: desc,where:{token: \"0xde3a24028580884448a5397872046a019649b084\"}) { date priceUSD }}"},
  };

  ServiceData isolateData = ServiceData(data, isolatePort.sendPort);
  Box<TokenChart> box = Boxes.getHistory();
  appState.services["tokenPriceHistory"] = await Isolate.spawn(watchTokenPriceHistory,isolateData);

  isolatePort.listen((data) {
    // print(data['tokenChart']["data"].runtimeType);
    // print(response);
    TokenChart dashboardChart = TokenChart();

    Map tokenMap = {};
    Map metaCoinMap = {};

    List tokenList = data['tokenChart']['data']['tokenDayDatas'];
    List metaCoinList =  data['metaCoinHistory']['data']['tokenDayDatas'];

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

    // print(box.values.elementAt(0).tokenList[1624060800]);
    // print(box.values.elementAt(0).tokenList[1624060800].runtimeType);
  });
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

      param.sendPort.send(
        {
          "tokenChart" : json.decode(tokenHistory),
          "metaCoinHistory" : json.decode(metaCoinHistory)
        }
      );
    });
    if(seconds == 0) seconds = 3600;
    // if(seconds == 0) seconds = 5;
  }
}

void updateCoinValues(AvmeWallet appState) async
{
  ReceivePort isolatePort = ReceivePort();

  Map <String, dynamic> data =
  {
    "url" : env["MAINNET_URL"] + ":${env["MAINNET_PORT"]}" + env["MAINNET_VALUEPATH"],
    "avaxBodyRequest" : {"query": "{pair(id: \"0x9ee0a4e21bd333a6bb2ab298194320b8daa26516\") {token0 {symbol} token1 {symbol} token0Price token1Price}}"},
    "tokenBodyRequest" : {"query": "{token(id: \"0x1ecd47ff4d9598f89721a2866bfeb99505a413ed\"){symbol derivedETH}}"}
  };

  ServiceData isolateData = ServiceData(data, isolatePort.sendPort);

  appState.services["updateCoinValues"] = await Isolate.spawn(watchCoinValueChanges,isolateData);
  isolatePort.listen((data) {
    appState.metaCoin.value = data["avax"];
    appState.token.value = data["avme"];
  });
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
        {
          "avax" : avaxPrice,
          "avme" : avmePrice
        }
      );
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
