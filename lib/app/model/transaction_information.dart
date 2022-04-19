import 'dart:convert';
import 'dart:io';

import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart' as web3Dart;
import 'package:hex/hex.dart';

class TransactionInformation with ChangeNotifier{
  bool _retrievingData = false;
  Map<String, dynamic> transaction = {};
  bool get retrievingData => _retrievingData;
  Map<String, dynamic> storedTransaction;
  set retrievingData (bool value)
  {
    this._retrievingData = value;
    notifyListeners();
  }
  void setLastTransactionInformation(web3Dart.TransactionInformation transactionInformation, {
      web3Dart.EtherAmount tokenValue,
      String to,
      String tokenName,
    }) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd HH-mm-ss").format(now);
    transaction["code"] = "";
    transaction["from"] = transactionInformation.from.toString();
    transaction["tokenName"] = tokenName;
    transaction["gas"] = transactionInformation.gas.toString();
    transaction["gasPrice"] = "${transactionInformation.gasPrice.getValueInUnit(web3Dart.EtherUnit.gwei).toInt()} Gwei (${transactionInformation.gasPrice.getInWei} wei)";
    transaction["hash"] = transactionInformation.hash;
    transaction["input"] = HEX.encode(transactionInformation.input);
    transaction["nonce"] = transactionInformation.nonce.toString();
    transaction["to"] = to;
    transaction["transactionIndex"] = transactionInformation.transactionIndex.toString();
    transaction["value"] = tokenValue.getInWei.toDouble() != 0 ?
      "${tokenValue.getValueInUnit(web3Dart.EtherUnit.gwei).toInt()} Gwei (${tokenValue.getInWei} wei)" :
      "${transactionInformation.value.getValueInUnit(web3Dart.EtherUnit.gwei).toInt()} Gwei (${transactionInformation.value.getInWei} wei)";
    transaction["type"] = "message";
    transaction["v"] = transactionInformation.v.toString();
    transaction["r"] = transactionInformation.r.toString();
    transaction["s"] = transactionInformation.s.toString();
    transaction["unixDate"] = now.microsecondsSinceEpoch;
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
      readJson["transactions"].insert(0,this.transaction);
      jsonFile = encoder.convert(readJson);
    }
    else jsonFile = encoder.convert({"transactions":[this.transaction]});
    stream.writeAsString(jsonFile);
  }

  Future<List> fileTransactions(String address, {int amount = 0}) async {
    FileManager fileManager = FileManager();
    String file = (await fileManager.getDocumentsFolder()) + fileManager.transactions + "$address";
    File dataFile = File(file);
    if(!await dataFile.exists())
    {
      return null;
    }
    List ret = jsonDecode(await dataFile.readAsString())["transactions"];
    if(amount > 0)
      ret = ret.sublist(ret.length - amount, ret.length);
    return ret;
  }

  int get qtdTransactions => this.storedTransaction["transactions"].length;
}