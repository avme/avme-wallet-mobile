import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/service_data.dart';

import 'package:web3dart/web3dart.dart';

List<Isolate> isolateList = [];
ServiceData genericThreadData;

Future<bool> loadWalletAccounts(List accounts, String password, AvmeWallet appState) async
{
  ReceivePort receivePort = ReceivePort();

  int progress = 0;
  bool inProgress = true;

  accounts.asMap().forEach((index,accountData) async
  {
    print(index);
    print(accountData["data"]);
    //TODO: move to receivePort
    appState.accountsState.total = (index + 1);

    genericThreadData = new ServiceData(
        {
          "index":index,
          "accountData": jsonEncode(accountData["data"]),
          "password":password,
          "walletManager":appState.walletManager
        }, receivePort.sendPort);

    isolateList.add(await Isolate.spawn(buildAccountObjectList, genericThreadData));
  });

  // Listens the threads...

  receivePort.listen((response){
    appState.addToAccountList(response[0],response[1]);
    progress++;
    print(progress);
    appState.accountsState.progress = progress;
    if(progress >= accounts.length)
    {
      inProgress = false;
      print(accounts.length);
      // if(accountPathList.length != 1)
      // {
      appState.accountsState.loadedAccounts = true;
      // }
      stopLoadWalletAccountsThreads();
    }
  });

  ///Remove this implementation, is lazy and inapropiate,
  ///please use FutureBuilder at Widget/UI level

  if(accounts.length == 1)
  {
    await waitWhile(() => inProgress);
  }
  return true;
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
}

void buildAccountObjectList(ServiceData param) async
{
  print(param.data);
  ReceivePort response = new ReceivePort();
  //Wallet.fromJson can take up to 2 seconds per operation!
  Wallet _wallet = Wallet.fromJson(param.data["accountData"], param.data["password"]);
  EthereumAddress _ethAddress = await _wallet.privateKey.extractAddress();
  //Return a AccountItem object to be added in the accountList
  param.sendPort.send(
    [
      param.data["index"],
      AccountObject(
        account: _wallet,
        address: _ethAddress.hex
      )
    ]
  );
  return response.first;
}

// Solution used:
// URL:https://stackoverflow.com/questions/47776045/is-there-a-good-way-to-write-wait-for-variables-to-change-in-darts-async-meth

Future waitWhile(bool test(), [Duration pollInterval = Duration.zero]) {
  var completer = new Completer();
  check() {
    if (!test()) {
      completer.complete();
    } else {
      new Timer(pollInterval, check);
    }
  }
  check();
  return completer.future;
}