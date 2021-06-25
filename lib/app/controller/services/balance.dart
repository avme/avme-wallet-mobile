import 'dart:async';
import 'dart:isolate';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/service_data.dart';
import 'package:avme_wallet/external/contracts/avme_contract.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

ServiceData balanceData;
ServiceData tokenData;

///Spawns two threads to listen, and update our appState
void updateBalanceService(AvmeWallet appState) async
{
  AccountObject accountWallet = appState.currentAccount;
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
  Client httpClient = Client();
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
  Client httpClient = Client();
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

// void updateBalanceService(AvmeWallet appState) async
// {
//   AccountObject accountWallet = appState.currentAccount;
//   ReceivePort receivePort = ReceivePort();
//
//   EthereumAddress address = await accountWallet.account.privateKey.extractAddress();
//
//   Map <String, dynamic> data = {
//     "etheriumAddress" : address,
//     "url" : env['NETWORK_URL']
//   };
//   balanceData = ServiceData(data, receivePort.sendPort);
//
//   appState.services["balanceTab"] = await Isolate.spawn(watchBalanceChanges,balanceData);
//
//   receivePort.listen((data) {
//     if(accountWallet.waiBalance != data["response"]) accountWallet.updateAccountBalance = data["response"];
//   });
// }

// void watchBalanceChanges(ServiceData param) async
// {
//   EthereumAddress address = param.data["etheriumAddress"];
//   Client httpClient = Client();
//   Web3Client ethClient = Web3Client(param.data["url"], httpClient);
//   // int secondsPassed = 1;
//   int seconds = 0;
//   while(true)
//   {
//     await Future.delayed(Duration(seconds: seconds), () async{
//       EtherAmount balance = await ethClient.getBalance(address);
//       // print("${(secondsPassed*5)} seconds passed, and the balance is... ${balance.getValueInUnit(EtherUnit.ether).toString()}");
//       param.sendPort.send(
//           {
//             "response" : balance.getInWei
//           }
//       );
//       // secondsPassed++;
//       if(seconds == 0) seconds = 10;
//     });
//   }
// }