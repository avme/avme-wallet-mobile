import 'dart:isolate';
import 'package:avme_wallet/app/controller/wallet_manager.dart';
import 'package:web3dart/web3dart.dart';
// Memory from threads/isolates in dart isn't shared, just for object reference
import 'package:avme_wallet/app/controller/globals.dart' as global;
WalletManager wm = new WalletManager();

void newIsolate() async
{
  ReceivePort receivePort = ReceivePort();
  List<Isolate> isolateList = [];

  for(int i = 0; i < 10; i++)
  {
    print("thread $i was added to the task");
    isolateList.add(await Isolate.spawn(runCode, receivePort.sendPort));
  }
  receivePort.listen((response){
    print("A isolate returned: $response");
  });
}

void runCode(SendPort sendPort) async
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

Future<bool> loadWalletAccounts(String password) async
{
  List<String> accountPathList = await wm.getAccounts();
  ReceivePort receivePort = ReceivePort();
  List<Isolate> isolateList = [];
  // for(int i = 0; i < 10; i++)
  // {
  //   print("thread $i was added to the task");
  //   isolateList.add(await Isolate.spawn(runCode, receivePort.sendPort));
  // }
  // receivePort.listen((response){
  //   print("A isolate returned: $response");
  // });
  // int index = 0;
  accountPathList.asMap().forEach((index,pathEntity) async
  {
    GenericThreadData param = new GenericThreadData(
      {"index":index,"walletPath":pathEntity,"password":password},receivePort.sendPort
    );
    isolateList.add(await Isolate.spawn(createAccountList, param));
  });
  // Listens the threads...
  receivePort.listen((response){
    print("Data returned: $response");
  });
  return true;
  // List<String> accountPathList = await wm.getAccounts();
  // List<Future> futures = [];
  // int index = 0;
  //
  // accountPathList.forEach((pathEntity) async{
  //
  //   // futures.add(createAccountList(index, pathEntity, password));
  //   futures.add(createAccountList(index, pathEntity, password));
  //
  // });
  // await Future.wait(futures);
  // return true;
}

void createAccountList(GenericThreadData param) async
{
  // await Future.delayed(Duration(seconds: 2), () {
  //   String ret = "Task #"+param.data["index"].toString()+" finished.";
  //   print(ret);
  //   param.sendPort.send(ret);
  // });

}

void createAccountListOld(int index, String walletPath, String password) async
{
  // print(index.toString()+walletPath);
  String content = await wm.readWalletJson(position: index.toString());
  // debugPrint(content);
  // instance fromJson is taking forever...
  Wallet _wallet = Wallet.fromJson(content, password);
  EthereumAddress _ethAddress = await _wallet.privateKey.extractAddress();
  //Return this to the main thread please
  global.accountList.add(global.AccountItem(
      account: _wallet,
      accountPath: walletPath,
      address: _ethAddress.hex));
}