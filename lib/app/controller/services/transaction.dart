import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:avme_wallet/app/model/transaction_information.dart' as transactionModel;
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/service_data.dart';
import 'package:avme_wallet/external/contracts/erc20_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import 'contract.dart';

String url = env["NETWORK_URL"];
ServiceData requestTransactionData;

Future<bool> hasEnoughBalanceToPayTaxes(BigInt balance) async {
  Client httpClient = Client();
  Web3Client ethClient = Web3Client(url, httpClient);
  BigInt tax = (await ethClient.getGasPrice()).getInWei;
  return tax > balance ? false : true;
}

Future<String> sendTransaction(AvmeWallet appState, String receiverAddress, BigInt amount, int tokenId, {List<ValueNotifier> listNotifier}) async
{
  Client httpClient = Client();
  Web3Client ethClient = Web3Client(url, httpClient);
  BigInt addToFee = BigInt.from((5 * pow(10,9)));
  EtherAmount gasPrice = EtherAmount.inWei((await ethClient.getGasPrice()).getInWei + addToFee);
  Map<String,List> contracts = Contracts.getInstance().contracts;
  Transaction transaction = Transaction(
      to: EthereumAddress.fromHex(receiverAddress),
      maxGas: 70000,
      gasPrice: gasPrice,
      value: EtherAmount.inWei(amount),
  );

  //Todo ASAP: change from token id to token identifier
  ///1: AVAX, 2: AVME

  listNotifier[0].value = 40;
  listNotifier[1].value = "Signing Transaction";
  String transactionHash;
  Web3Client transactionClient;
  if(tokenId == 1)
  {
    Credentials accountCredentials = appState.currentAccount.walletObj.privateKey;
    // transactionHash = await ethClient.sendTransaction(accountCredentials, transaction, chainId: 43113);
    Uint8List signedTransaction = await ethClient.signTransaction(
      accountCredentials,
      transaction,
      chainId:43113,
    );
    print("[signedTransaction]");
    print(signedTransaction);
    transactionHash = await ethClient.sendRawTransaction(signedTransaction);
    print("[transactionHash]$transactionHash");
    listNotifier[0].value = 60;
    listNotifier[1].value = "Sending Transaction";
    transactionClient = ethClient;
  }
  else
  {
    transaction = Transaction(
      maxGas: 70000,
      gasPrice: gasPrice
    );
    EthereumAddress contractAddress = EthereumAddress.fromHex(contracts["AVME testnet"][1]);
    ContractAbi abi = contracts["AVME testnet"][0];
    int chainId = int.tryParse(contracts["AVME testnet"][2]);
    ERC20 contract = ERC20(abi, address: contractAddress, client: ethClient, chainId: chainId);
    Credentials accountCredentials = appState.currentAccount.walletObj.privateKey;
    listNotifier[0].value = 60;
    listNotifier[1].value = "Sending Transaction";
    transactionHash = await contract.transfer(
        EthereumAddress.fromHex(receiverAddress),
        amount,
        credentials: accountCredentials,
        transaction: transaction
    );

    transactionClient = contract.client;
  }
  print(transactionHash);
  listNotifier[0].value = 90;
  listNotifier[1].value = "Confirming Transaction";
  /*Recovering Transaction hash*/
  TransactionInformation transactionInformation;
  TransactionReceipt transactionReceipt;
  int secondsPassed = 0;
  while(true) {
    try {
      await Future.delayed(Duration(seconds:1));
      transactionReceipt = await transactionClient.getTransactionReceipt(transactionHash);
      print("[info] Receipt: $transactionReceipt");
      if(transactionReceipt.status) {
        transactionInformation = await transactionClient.getTransactionByHash(transactionHash);
        print("[Info] seconds passed: $secondsPassed, and returned $transactionInformation");
        if(transactionInformation != null)
        {
          appState.lastTransactionWasSucessful.setLastTransactionInformation(
              transactionInformation,
              tokenValue: EtherAmount.inWei(amount),
              to: receiverAddress
          );
          appState.lastTransactionWasSucessful.writeTransaction();
          break;
        }
      }
    }
    catch(e)
    {
      print("ERROR $e");
    }
  }
  listNotifier[0].value = 100;
  listNotifier[1].value = "Done";
  return "https://snowtrace.io/tx/$transactionHash";
}