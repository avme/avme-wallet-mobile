import 'dart:convert';
import 'dart:io';

import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart' as web3Dart;
import 'package:hex/hex.dart';

class TransactionInformation with ChangeNotifier{
  // String blockHash;
  // String blockNumber;
  // String from;
  // String gas;
  // String gasPrice;
  // String hash;
  // String input;
  // String nonce;
  // String to;
  // String transactionIndex;
  // String value;
  // String type;
  // String v;
  // String r;
  // String s;
  // String confirmed;
  // int unixDate;
  bool _retrievingData = false;
  Map<String, dynamic> transaction = {};
  bool get retrievingData => _retrievingData;
  Map<String, dynamic> storedTransaction;
  set retrievingData (bool value)
  {
    this._retrievingData = value;
    notifyListeners();
  }

  set setLastTransactionInformation(web3Dart.TransactionInformation transactionInformation) {
    // transaction["blockHash"] = transactionInformation.blockHash;
    // transaction["blockNumber"] = transactionInformation.blockNumber.toString();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd HH-mm-ss").format(now);

    transaction["code"] = "";
    transaction["from"] = transactionInformation.from.toString();
    transaction["gas"] = transactionInformation.gas.toString();
    transaction["gasPrice"] = "${transactionInformation.gasPrice.getValueInUnit(web3Dart.EtherUnit.gwei).toInt()} Gwei (${transactionInformation.gasPrice.getInWei} wei)";
    transaction["hash"] = transactionInformation.hash;
    transaction["input"] = HEX.encode(transactionInformation.input);
    transaction["nonce"] = transactionInformation.nonce.toString();
    transaction["to"] = transactionInformation.to.toString();
    transaction["transactionIndex"] = transactionInformation.transactionIndex.toString();
    transaction["value"] = "${transactionInformation.value.getValueInUnit(web3Dart.EtherUnit.gwei).toInt()} Gwei (${transactionInformation.value.getInWei} wei)";
    transaction["type"] = "message";
    transaction["v"] = transactionInformation.v.toString();
    transaction["r"] = transactionInformation.r.toString();
    transaction["s"] = transactionInformation.s.toString();
    transaction["unixDate"] = now.millisecondsSinceEpoch;
    transaction["humanDate"] = formattedDate;
    transaction["confirmed"] = true;
    transaction["invalid"] = false;
    transaction["creates"] = "";
    transaction["operation"] = "Exchange between accounts";
  }

  void writeTransaction() async {
    FileManager fileManager = FileManager();
    String documentsFolder = await fileManager.getDocumentsFolder();
    String transactions = documentsFolder + fileManager.transactions;
    await fileManager.checkPath(transactions);
    transactions = transactions+"${this.transaction["from"]}";
    File stream = File(transactions);
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String jsonFile;
    if(await stream.exists())
    {
      Map<String, dynamic> readJson = jsonDecode(await stream.readAsString());
      print(readJson["transactions"][0]);
      readJson["transactions"].add(this.transaction);
      jsonFile = encoder.convert(readJson);
    }
    else jsonFile = encoder.convert({"transactions":[this.transaction]});
    stream.writeAsString(jsonFile);
  }

  Future<File> fileTransactions(String address) async {
    FileManager fileManager = FileManager();
    File ret;
    String file = (await fileManager.getDocumentsFolder()) + fileManager.transactions + "$address.json";
    ret = File(file);
    this.storedTransaction = jsonDecode(await ret.readAsString());
    return ret;
  }

  int get qtdTransactions => this.storedTransaction["transactions"].length;
}