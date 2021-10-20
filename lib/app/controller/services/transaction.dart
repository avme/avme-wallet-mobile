import 'dart:isolate';
import 'dart:typed_data';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/transaction_information.dart' as transactionModel;
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/service_data.dart';
import 'package:avme_wallet/external/contracts/avme_contract.dart';
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

Future<bool> sendTransaction(AvmeWallet appState, String receiverAddress, BigInt amount) async
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

  print("[Info] Transaction: ${_transaction.data}");
  Uint8List signedTransaction = await ethClient.signTransaction(
    appState.currentAccount.account.privateKey,
    _transaction,
    chainId: int.parse(env["CHAIN_ID"])
  );

  String transactionHash = await ethClient.sendRawTransaction(signedTransaction);

  print("[Info] transaction hash:$transactionHash");

  Map <String, dynamic> data = {
    "url" : url,
    "transactionHash" : transactionHash,
    "contractAddress" : env["CONTRACT_ADDRESS"],
    "chainId" : int.parse(env["CHAIN_ID"]),
    "amount" : amount,
  };

  requestTransactionData = ServiceData(data, receivePort.sendPort);
  appState.services["pendingTransaction"] = await Isolate.spawn(getTransactionByHash,requestTransactionData);

  receivePort.listen((response) {
    print("Returned Data: ${response["response"]}");
    appState.killService("pendingTransaction");
    TransactionInformation _data = response["response"];
    appState.lastTransactionWasSucessful.setLastTransactionInformation(
      _data,
      // tokenValue: EtherAmount.fromUnitAndValue(EtherUnit.gwei, amount),
      tokenValue: EtherAmount.inWei(amount),
      to: receiverAddress
    );
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
  EthereumAddress contractAddress = EthereumAddress.fromHex(param.data["contractAddress"]);
  AvmeContract avmeContract =  AvmeContract(address:contractAddress, client: ethClient, chainId: param.data["chainId"]);

  TransactionInformation transactionInformation;
  TransactionReceipt transactionReceipt;
  bool receipt = false;
  int secondsPassed = 0;
  while(!receipt)
  {
    try
    {
      await Future.delayed(Duration(seconds:2), () async {
        // transactionData = await ethClient.getTransactionByHash(transactionHash);
        transactionReceipt = await avmeContract.client.getTransactionReceipt(transactionHash);
        print("[info] Receipt: $transactionReceipt");
        if(transactionReceipt.status)
        {
          transactionInformation = await avmeContract.client.getTransactionByHash(transactionHash);
          print("[Info] seconds passed: $secondsPassed, and returned $transactionInformation");
          if(transactionInformation != null)
          {
            print("[info] Receipt: $transactionInformation");
            param.sendPort.send({
              "response" : transactionInformation,
            });
          }
        }
      });
    }
    catch(e)
    {}
  }
}