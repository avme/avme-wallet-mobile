// @dart=2.12
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:avme_wallet/app/controller/services/navigation_service.dart';
import 'package:avme_wallet/app/controller/web/web_utils.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/packages/services.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/webview/popup/approve_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../controller/services/transaction.dart';

import '../screens/prototype/widgets/webview/popup/allow_site.dart';

enum RequestSignTypes {
  eth_sign, personal_sign, none
}

List<String> requirePermission = [
  "eth_requestAccounts",
  "eth_accounts",
  "personal sign",
  "personal_sign",
  "eth_sendTransaction",
  "eth_sign",
];

List<String> requestTransaction = [
  "eth_sendTransaction",
];

List<String> requestSign = [
  "eth_sign",
  "personal sign",
  "personal_sign"
];

Map<int, String> errorList = {
  -32601 : "\"eth_subscribe\" method not found",
  -32603 : "Internal error",
  4001 : "User rejected request"
};

///List of methods

String ethChainId = "eth_chainId";
String netVersion = "net_version";
String ethRequestAccounts = "eth_requestAccounts";
String ethAccounts = "eth_accounts";
String ethSubscribe = "eth_subscribe";
String ethSign = "eth_sign";
String personalSign = "personal sign";
String personalSign2 = "personal_sign";
String walletAddEthereumChain = "wallet_addEthereumChain";

Future<void> handleServer (Completer completer, Map request, String origin)
async {
  BuildContext? context = NavigationService.globalContext.currentContext;
  if(context == null)
  {
    throw "No context found in handleServer";
  }
  AllowedUrls allowedUrls = AllowedUrls();

  WebViewController controller = await completer.future;
  Map response = {
    "jsonrpc" : "2.0",
    "id" : request["id"],
  };

  RequestSignTypes requestSignType = RequestSignTypes.none;

  if(request["method"] == ethChainId)
  {
    int hexId = int.tryParse(dotenv.get("CHAIN_ID")) ?? 43114;
    response["result"] = "0x" + (hexId.toRadixString(16));
  }
  else if(request["method"] == netVersion)
  {
    response["result"] = int.tryParse(dotenv.get("CHAIN_ID")) ?? 43114;
  }
  else if(request["method"] == ethRequestAccounts || request["method"] == ethAccounts)
  {
    AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);

    response["result"] = [ app.currentAccount.address ];
  }
  else if(request["method"] == ethSubscribe)
  {
    response["error"] = {
      "code": -32601,
      "message": errorList[-32601]
    };
    // response["error"]["code"] = -32601;
    // response["error"]["message"] = errorList[-32601];
  }
  else if(request["method"] == ethSign)
  {
    requestSignType = RequestSignTypes.eth_sign;
  }
  else if(request["method"] == personalSign || request["method"] == personalSign2)
  {
    requestSignType = RequestSignTypes.personal_sign;
  }
  else if(request["method"] == walletAddEthereumChain)
  {
    int hexId = int.tryParse(dotenv.get("CHAIN_ID")) ?? 43114;
    // The method MUST return null if the request was successful, and an error otherwise.
    // See https://eips.ethereum.org/EIPS/eip-3085
    // TODO: When implementing multichain, ask the user to accept a new network from the website
    if (request["params"][0]["chainId"] !=  "0x" + (hexId.toRadixString(16))) {
      response["error"] = {
        "code": -32601,
        "error": errorList[-32601]
      };
    }
    return;
  }
  else
  {
    String res = await executeInNetwork(request);
    response = jsonDecode(res);
    if(response["result"] == "0x")
      throw "Error at handleServer -> ${request["method"]}: Returned \"0x\"";
    printApprove("[handleServer] ?${request["method"]}?: $res, result: ${response["result"]}");
  }

  /// Asking if the WebSite has permission
  if(requirePermission.contains(request["method"]))
  {
    bool hasPermission = false;
    int allowed = await allowedUrls.isAllowed(origin);
    printApprove("Is allowed? $allowed");
    if(allowed == 1)
    {
      hasPermission = true;
    }
    else if(allowed == 0)
    {
      hasPermission = await requestSitePermission(context, origin, allowedUrls: allowedUrls);
    }
    if(!hasPermission) {
      response["error"] = {
        "code": -32603,
        "error": errorList[-32603]
      };
      response.removeWhere((key, value) => key == "result");
    }
  }

  if(requestTransaction.contains(request["method"])) {
    String data = "",
        gas = "",
        value = "",
        from = "",
        to = "";

    if (request["params"][0].containsKey("data"))
      data = request["params"][0]["data"];
    if (request["params"][0].containsKey("gas")) {
      gas = request["params"][0]["gas"];
    } else {
      gas = "0xc3500";
    }
    if (request["params"][0].containsKey(
        "value")) { // Value input is optional! check if exists to set it properly.
      value = request["params"][0]["value"];
    } else {
      value = "0x0";
    }

    from = request["params"][0]["from"];
    to = request["params"][0]["to"];

    int _gasLimit = int.parse(gas.replaceAll('0x', ''), radix: 16);

    EtherAmount valueAmount = EtherAmount.inWei(
        BigInt.from(int.parse(value.replaceAll('0x', ''), radix: 16)));
    printOk("data: $data, gas: $gas, ");

    /// Awaiting the user to confirm the transaction
    AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);

    /// + 2000000000
    EtherAmount gasPrice = await app.walletManager.getGasPrice();
    EtherAmount gasLimit = EtherAmount.fromUnitAndValue(
        EtherUnit.gwei, BigInt.from(_gasLimit));
    printWarning(
        "app.walletManager.calculateTransactionCost(${valueAmount.getInWei
            .toString()}, $_gasLimit, ${gasPrice.getInWei.toString()})");
    BigInt _totalCost = app.walletManager.calculateTransactionCost(
        valueAmount.getInWei, BigInt.from(_gasLimit), gasPrice.getInWei);
    BigInt _fee = _totalCost - valueAmount.getInWei;
    printError("totalCost: $_totalCost, fee: $_fee");

    EtherAmount fee = EtherAmount.fromUnitAndValue(EtherUnit.wei, _fee);

    bool approved = await requestApproveTransaction(
      context,
      origin,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      valueAmount: valueAmount,
      unlocked: true,
      fee: fee,
    );
    if(approved == false)
    {
      response["error"] = {
        "code": 4001,
        "error": errorList[4001],
      };
    }
    else
    {
      String hash = await sendRaw(
        app,
        to,
        valueAmount.getInWei,
        gasLimit.getValueInUnit(EtherUnit.gwei).toInt(),
        gasPrice.getInWei,
        data: hexToBytes(data)
      );
      printError("PROCESSED DATAS $hash");
      response = {
        "jsonrpc" : "2.0",
        "id" : request["id"],
        "result" : hash
      };
    }
  }

  /// Returning the request
  String res = jsonEncode({
    "type": "eth:payload",
    "payload": response
  });

  printApprove("window.postMessage($res)");
  controller.runJavascript("window.postMessage($res)");
}