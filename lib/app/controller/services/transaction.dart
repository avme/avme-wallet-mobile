import 'dart:isolate';
import 'dart:typed_data';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/transaction_information.dart' as transactionModel;
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/service_data.dart';
import 'package:avme_wallet/app/packages/services.dart';
import 'package:avme_wallet/external/contracts/avme_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

String url = env["NETWORK_URL"];
ServiceData requestTransactionData;

Future<bool> hasEnoughBalanceToPayTaxes(BigInt balance) async {
  Client httpClient = Client();
  Web3Client ethClient = Web3Client(url, httpClient);
  BigInt tax = (await ethClient.getGasPrice()).getInWei;
  return tax > balance ? false : true;
}

Future<bool> sendTransaction(AvmeWallet appState, String receiverAddress, BigInt amount, {ValueNotifier notifier}) async
{
  ReceivePort receivePort = ReceivePort();
  Client httpClient = Client();
  Web3Client ethClient = Web3Client(url, httpClient);
  // Credentials accountCredentials = await ethClient.credentialsFromPrivateKey(appState.currentAccount.address);

  EthereumAddress contractAddress = EthereumAddress.fromHex(env["CONTRACT_ADDRESS"]);
  AvmeContract avmeContract = AvmeContract(
      address:contractAddress,
      client: ethClient,
      chainId: int.parse(env["CHAIN_ID"]),
  );
  Credentials accountCredentials = await avmeContract.client.credentialsFromPrivateKey(appState.currentAccount.address);

  Transaction _transaction = await avmeContract
      .transfer(
      to: EthereumAddress.fromHex(receiverAddress),
      value: amount,
      credentials: accountCredentials,
  );
  notifier.value = "2 - Signing Transaction";
  print("[Info] Transaction: ${_transaction.data}");
  Uint8List signedTransaction = await ethClient.signTransaction(
    appState.currentAccount.account.privateKey,
    _transaction,
    chainId: int.parse(env["CHAIN_ID"])
  );

  notifier.value = "3 - Creating Transaction Hash";
  String transactionHash = await ethClient.sendRawTransaction(signedTransaction);

  print("[Info] transaction hash:$transactionHash");

  Map <String, dynamic> data = {
    "url" : url,
    "transactionHash" : transactionHash,
    "contractAddress" : env["CONTRACT_ADDRESS"],
    "chainId" : int.parse(env["CHAIN_ID"]),
    "amount" : amount,
  };

  // requestTransactionData = ServiceData(data, receivePort.sendPort);
  notifier.value = "4 - Waiting for the network";
  await compute(getTransactionByHash, data).then((response) async {
    // TransactionInformation _data = response["response"];
    TransactionInformation _data = response["response"];
        appState.lastTransactionWasSucessful.setLastTransactionInformation(
        _data,
        // tokenValue: EtherAmount.fromUnitAndValue(EtherUnit.gwei, amount),
        tokenValue: EtherAmount.inWei(amount),
        to: receiverAddress
    );
    notifier.value = "5 - Writing Transaction";
    await Future.delayed(Duration(seconds: 2));
    appState.lastTransactionWasSucessful.writeTransaction();
  });
  // appState.services["pendingTransaction"] = await Isolate.spawn(getTransactionByHash,requestTransactionData);
  //
  // notifier.value = "4 - Waiting for the network";
  //
  // receivePort.listen((response) async {
  //   print("Returned Data: ${response["response"]}");
  //   appState.killService("pendingTransaction");
  //   TransactionInformation _data = response["response"];
  //   appState.lastTransactionWasSucessful.setLastTransactionInformation(
  //     _data,
  //     // tokenValue: EtherAmount.fromUnitAndValue(EtherUnit.gwei, amount),
  //     tokenValue: EtherAmount.inWei(amount),
  //     to: receiverAddress
  //   );
  //   await Future.delayed(Duration(seconds: 2));
  //   appState.lastTransactionWasSucessful.writeTransaction();
  // });
  return true;
}

Future<Map> getTransactionByHash(Map data) async
{
  Client httpClient = Client();
  Web3Client ethClient = Web3Client(data["url"], httpClient);
  String transactionHash = data['transactionHash'];
  EthereumAddress contractAddress = EthereumAddress.fromHex(data["contractAddress"]);
  AvmeContract avmeContract =  AvmeContract(address:contractAddress, client: ethClient, chainId: data["chainId"]);

  TransactionInformation transactionInformation;
  TransactionReceipt transactionReceipt;
  int secondsPassed = 0;
  Map mapInfo = {};
  while(true)
  {
    try
    {
      await Future.delayed(Duration(seconds:2));
      transactionReceipt = await avmeContract.client.getTransactionReceipt(transactionHash);
      print("[info] Receipt: $transactionReceipt");
      if(transactionReceipt.status)
      {
        transactionInformation = await avmeContract.client.getTransactionByHash(transactionHash);
        print("[Info] seconds passed: $secondsPassed, and returned $transactionInformation");
        if(transactionInformation != null)
        {
          mapInfo = {
            "response" : transactionInformation,
          };
          break;
        }
      }
    }
    catch(e)
    {
      print("ERROR $e");
    }
  }
  return mapInfo;
}