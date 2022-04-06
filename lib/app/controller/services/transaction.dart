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

Future<bool> hasEnoughBalanceToPayTaxes(BigInt balance, BigInt amount) async {
  //TODO: Fix this, calculate taxes as in (gax * price + value)
  //RPCError: got code -32000 with msg
  //"insufficient funds for gas * price + value: address 0x39C095e526fEDbb3152bB506a5c03Dd79E7E64C9 have (5146044911057280) want (5660838001700000)".

  Client httpClient = Client();
  Web3Client ethClient = Web3Client(url, httpClient);
  // BigInt tax = (await ethClient.getGasPrice()).getInWei;
  BigInt addToFee = BigInt.from((5 * pow(10, 9)));
  print('addToFee: $addToFee');
  print('tax before addToFee: ${(await ethClient.getGasPrice()).getInWei}');
  BigInt tax = (await ethClient.getGasPrice()).getInWei + addToFee;
  print('tax after addToFee: $tax');
  print('tax > balance = ${tax > balance}');
  return tax > balance ? false : true;
}

Future<String> sendTransaction(AvmeWallet appState, String receiverAddress, BigInt amount, String token, {List<ValueNotifier> listNotifier}) async {
  // print(amount.toString());
  // print(token);
  // return "a";
  Client httpClient = Client();
  Web3Client ethClient = Web3Client(url, httpClient);
  BigInt addToFee = BigInt.from((5 * pow(10, 9)));
  EtherAmount gasPrice = EtherAmount.inWei((await ethClient.getGasPrice()).getInWei + addToFee);
  // EtherAmount gasPrice = await ethClient.getGasPrice();
  Map<String, List> contracts = Contracts.getInstance().contracts;
  Transaction transaction = Transaction(
    to: EthereumAddress.fromHex(receiverAddress),
    maxGas: 70000,
    gasPrice: gasPrice,
    value: EtherAmount.inWei(amount),
  );

  listNotifier[0].value = 40;
  listNotifier[1].value = "Signing Transaction";
  String transactionHash;
  Web3Client transactionClient;
  if (token == "AVAX") {
    print("AVAX - MAINNET");

    ///Get the chainId
    // int chainId = (await ethClient.getChainId()).toInt();
    int chainId = int.tryParse(env["CHAIN_ID"]) ?? 43114;
    print("MEU CHAIN ID $chainId");
    Credentials accountCredentials = appState.currentAccount.walletObj.privateKey;
    Uint8List signedTransaction = await ethClient.signTransaction(
      accountCredentials,
      transaction,
      // chainId: int.tryParse(env["CHAIN_ID"]) ?? 43114,
      chainId: chainId,
    );
    // chainId: 43144);
    print("[signedTransaction]");
    print(signedTransaction);

    // try {
    //   await ethClient.sendRawTransaction(signedTransaction).then((transactionHash) {
    //     print("[transactionHash]$transactionHash");
    //     listNotifier[0].value = 60;
    //     listNotifier[1].value = "Sending Transaction";
    //     transactionClient = ethClient;
    //   }).onError((error, stackTrace) {
    //     print(error);
    //     throw error;
    //   });
    // } catch (e) {
    //   return "https://e621.net";
    // }
    transactionHash = await ethClient.sendRawTransaction(signedTransaction);
    print("[transactionHash]$transactionHash");
    listNotifier[0].value = 60;
    listNotifier[1].value = "Sending Transaction";
    transactionClient = ethClient;
  } else {
    transaction = Transaction(maxGas: 70000, gasPrice: gasPrice);
    EthereumAddress contractAddress = EthereumAddress.fromHex(contracts[token][1]);
    ContractAbi abi = contracts[token][0];
    int chainId = int.tryParse(contracts[token][2]);
    print("${token} - ERC20s ${[abi, contractAddress, ethClient, chainId]}");
    ERC20 contract = ERC20(abi, address: contractAddress, client: ethClient, chainId: chainId);
    Credentials accountCredentials = appState.currentAccount.walletObj.privateKey;
    listNotifier[0].value = 60;
    listNotifier[1].value = "Sending Transaction";

    try {
      await contract
          .transfer(EthereumAddress.fromHex(receiverAddress), amount, credentials: accountCredentials, transaction: transaction)
          .then((response) {
        transactionHash = response;
        print("[transactionHash]$transactionHash");
        transactionClient = contract.client;
      });
    } catch (e) {
      print(e);
    }

    // transactionHash =
    //     await contract.transfer(EthereumAddress.fromHex(receiverAddress), amount, credentials: accountCredentials, transaction: transaction);
    // print("[transactionHash]$transactionHash");
    // transactionClient = contract.client;
  }
  print(transactionHash);
  listNotifier[0].value = 90;
  listNotifier[1].value = "Confirming Transaction";

  int secondsPassed = 0;
  while (true) {
    try {
      await Future.delayed(Duration(seconds: 1));
      TransactionReceipt transactionReceipt = await transactionClient.getTransactionReceipt(transactionHash);
      print("[info] Receipt: $transactionReceipt");
      if (transactionReceipt.status) {
        TransactionInformation transactionInformation = await transactionClient.getTransactionByHash(transactionHash);
        print("[Info] seconds passed: $secondsPassed, and returned $transactionInformation");
        if (transactionInformation != null) {
          appState.lastTransactionWasSucessful
              .setLastTransactionInformation(transactionInformation, tokenValue: EtherAmount.inWei(amount), to: receiverAddress);
          appState.lastTransactionWasSucessful.writeTransaction();
          break;
        }
      }
    } catch (e) {
      print("ERROR $e");
    }
  }
  listNotifier[0].value = 100;
  listNotifier[1].value = "Done";
  return "https://snowtrace.io/tx/$transactionHash";
}
