import 'dart:async';
import 'dart:isolate';
import 'package:avme_wallet/app/controller/wallet_manager.dart';
import 'package:avme_wallet/app/database/account_item.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Memory from threads/isolates in dart isn't shared, just for object reference
import 'package:avme_wallet/app/controller/globals.dart' as global;

List<Isolate> isolateList = [];

void exampleIsolate() async
{
  ReceivePort receivePort = ReceivePort();
  List<Isolate> isolateList = [];

  for(int i = 0; i < 10; i++)
  {
    print("thread $i was added to the task");
    isolateList.add(await Isolate.spawn(runExample, receivePort.sendPort));
  }
  receivePort.listen((response){
    print("A isolate returned: $response");
  });
}

void runExample(SendPort sendPort) async
{
  await Future.delayed(Duration(seconds: 5), () {
    print("This code was run on a new Isolate");
  });
  sendPort.send("a isolate finished his task");
}

//WalletManager new Thread execution

class GenericThreadData
{
  Map<String, dynamic> data;
  SendPort sendPort;
  GenericThreadData(this.data, this.sendPort);
}

Future<bool> loadWalletAccounts(String password, WalletManager walletManager) async
{
  List<String> accountPathList = await walletManager.getAccounts();
  ReceivePort receivePort = ReceivePort();

  int progress = 0;
  bool inProgress = true;
  accountPathList.asMap().forEach((index,pathEntity) async
  {
    GenericThreadData param = new GenericThreadData(
      {"index":index,"walletPath":pathEntity,"password":password,"walletManager":walletManager},receivePort.sendPort
    );
    isolateList.add(await Isolate.spawn(createAccountList, param));
  });

  // Listens the threads...

  receivePort.listen((response){
    print("Data returned:"+response.toString());
    global.accountList.add(response);
    progress++;
    print(progress);
    if(progress >= accountPathList.length)
    {
      inProgress = false;
    }
  });
  await waitWhile(() => inProgress);
  stopLoadWalletAccountsThreads();
  return true;
}

void stopLoadWalletAccountsThreads()
{
  for(Isolate thread in isolateList)
  {
    if(thread != null)
    {
      thread.kill(priority: Isolate.immediate);
      thread = null;
    }
  }
}

void createAccountList(GenericThreadData param) async
{
  ReceivePort response = new ReceivePort();
  String content = await param.data["walletManager"]
      .readWalletJson(position: param.data["index"].toString());
  Wallet _wallet = Wallet.fromJson(content, param.data["password"]);
  EthereumAddress _ethAddress = await _wallet.privateKey.extractAddress();
  //Return a AccountItem object to be added in the accountList
  param.sendPort.send(
    AccountItem(
      account: _wallet,
      accountPath: param.data["walletPath"],
      address: _ethAddress.hex)
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