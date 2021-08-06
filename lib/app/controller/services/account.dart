import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/service_data.dart';

import 'package:web3dart/web3dart.dart';

List<Isolate> isolateList = [];
ServiceData serviceData;

Future<bool> loadWalletAccounts(List accounts, String password, AvmeWallet appState) async
{
  ReceivePort receivePort = ReceivePort();
  //Total amount of accounts to be loaded
  appState.accountsState.total = accounts.length;
  accounts.asMap().forEach((index,accountData) async
  {
    // print("accountData:");
    // print(jsonEncode(accountData));
    serviceData = new ServiceData(
      {
        "index": index,
        "accountData": accountData,
        "password": password,
        "walletManager": appState.walletManager
      }, receivePort.sendPort);

    isolateList.add(await Isolate.spawn(buildAccountObjectList, serviceData));
  });

  // Listens the threads...
  int progress = 0;
  await for (List response in receivePort)
  {
    appState.addToAccountList(response[0],response[1]);
    progress++;
    // print(progress);
    appState.accountsState.progress = progress;
    if(progress >= accounts.length)
    {
      appState.accountsState.loadedAccounts = true;
      stopLoadWalletAccountsThreads();
      return true;
    }
  }
  return false;
}

void stopLoadWalletAccountsThreads()
{
  for(int i = 0; i < isolateList.length; i++)
  {
    if(isolateList[i] != null)
    {
      isolateList[i].kill(priority: Isolate.immediate);
      print("killing thread ${i.toString()}");
      isolateList[i] = null;
    }
  }
  isolateList = [];
}

void buildAccountObjectList(ServiceData param) async
{
  ReceivePort response = new ReceivePort();
  Map _accountData = param.data["accountData"];
  String _walletData = jsonEncode(_accountData["data"]);
  // print("wallet data:");
  // print(_walletData);
  //Wallet.fromJson can take up to 2 seconds per operation!
  Wallet _wallet = Wallet.fromJson(_walletData, param.data["password"]);
  EthereumAddress _ethAddress = await _wallet.privateKey.extractAddress();
  //Return a AccountItem object to be added in the accountList
  param.sendPort.send(
    [
      param.data["index"],
      AccountObject(
        account: _wallet,
        address: _ethAddress.hex,
        slot: _accountData["slot"],
        derived: _accountData["derived"],
        title: _accountData["title"]
      )
    ]
  );
  return response.first;
}