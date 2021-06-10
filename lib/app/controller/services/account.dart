import 'dart:async';
import 'dart:isolate';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:web3dart/web3dart.dart';

List<Isolate> isolateList = [];
GenericThreadData genericThreadData;
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

Future<bool> loadWalletAccounts(Map<int, String> accountPathList, String password, AvmeWallet appState, AppLoadingState loadState) async
{
  // List<String> accountPathList = await walletManager.getAccounts(first:false);
  ReceivePort receivePort = ReceivePort();

  int progress = 0;
  bool inProgress = true;
  accountPathList.forEach((index,pathEntity) async
  {
    loadState.total = (index + 1);
    genericThreadData = new GenericThreadData({"index":index,"walletPath":pathEntity,"password":password,"walletManager":appState.walletManager}, receivePort.sendPort);
    isolateList.add(await Isolate.spawn(createAccountList, genericThreadData));
  });

  // Listens the threads...

  receivePort.listen((response){
    // print("Data returned:"+response.toString());
    appState.addToAccountList(response[0],response[1]);
    progress++;
    print(progress);
    loadState.progress = progress;
    if(progress >= accountPathList.length)
    {
      inProgress = false;
      if(accountPathList.length != 1)
      {
        loadState.loadedAccounts = true;
      }
      stopLoadWalletAccountsThreads();
    }
  });

  if(accountPathList.length == 1)
  {
    await waitWhile(() => inProgress);
  }
  return true;
}

void stopLoadWalletAccountsThreads()
{
  // for(Isolate thread in isolateList)
  // for(Isolate thread in isolateList)
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

void createAccountList(GenericThreadData param) async
{
  ReceivePort response = new ReceivePort();
  String content = await param.data["walletManager"]
      .readWalletJson(position: param.data["index"].toString());
  //Wallet.fromJson can take up to 2 seconds per operation!
  Wallet _wallet = Wallet.fromJson(content, param.data["password"]);
  EthereumAddress _ethAddress = await _wallet.privateKey.extractAddress();
  //Return a AccountItem object to be added in the accountList
  print("Thread Index:"+param.data["index"].toString());
  param.sendPort.send(
    [
      param.data["index"],
      AccountItem(
        account: _wallet,
        accountPath: param.data["walletPath"],
        address: _ethAddress.hex)
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