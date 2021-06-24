import 'dart:isolate';
import 'dart:typed_data';
import 'package:avme_wallet/app/model/transaction_information.dart' as transactionModel;
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/service_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

String url = env["NETWORK_URL"];
ServiceData requestTransactionData;

Future<bool> sendTransaction(AvmeWallet appState, String receiverAddress, BigInt amount) async
{
  ReceivePort receivePort = ReceivePort();
  Client httpClient = Client();
  Web3Client ethClient = Web3Client(url, httpClient);
  Transaction _transaction = Transaction(
      to:EthereumAddress.fromHex(receiverAddress),
      gasPrice: EtherAmount.inWei(BigInt.from(int.parse(env["GAS_PRICE"]))),
      maxGas: int.parse(env["MAX_GAS"]),
      // value: EtherAmount.fromUnitAndValue(EtherUnit.ether, amount)
      value: EtherAmount.inWei(amount),
  );

  Uint8List signedTransaction = await ethClient.signTransaction(
    appState.currentAccount.account.privateKey,
    _transaction,
    chainId: int.parse(env["CHAIN_ID"])
  );

  String transactionHash = await ethClient.sendRawTransaction(signedTransaction);

  Map <String, dynamic> data = {
    "url" : url,
    "transactionHash" : transactionHash
  };

  requestTransactionData = ServiceData(data, receivePort.sendPort);
  appState.services["pendingTransaction"] = await Isolate.spawn(getTransactionByHash,requestTransactionData);

  receivePort.listen((response) {
    print("Returned Data: ${response["response"]}");
    appState.killService("pendingTransaction");
    // Todo: create transaction files
    TransactionInformation _data = response["response"];
    appState.lastTransactionWasSucessful.setLastTransactionInformation = _data;
    appState.lastTransactionWasSucessful.writeTransaction();
  });
  return true;
}

void getTransactionByHash(ServiceData param) async
{
  // Future.delayed(Duration(seconds: 5), () async{
    Client httpClient = Client();
    Web3Client ethClient = Web3Client(param.data["url"], httpClient);
    String transactionHash = param.data['transactionHash'];
    TransactionInformation transactionData;
    bool done = false;
    while(!done)
    try
    {
      await Future.delayed(Duration(seconds:2), () async {
        transactionData = await ethClient.getTransactionByHash(transactionHash);
        if(transactionData != null)
        {
          param.sendPort.send({
            "response" : transactionData});
          done = true;
        }
      });
    }
    catch(e)
    {}
    // print("transactionInformation"+transactionData.nonce.toString());
    print("transactionInformation"+transactionData.from.toString());
  // });
}