// @dart=2.12
import 'dart:async';
import 'dart:convert';

import 'package:avme_wallet/app/controller/web/web_utils.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/packages/services.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../main.dart';

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
  AllowedUrls aUrl = AllowedUrls();

  if(context == null)
  {
    throw "No context found in handleServer";
  }
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
      response = {
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
    printApprove("[handleServer] ?${request["method"]}?: $res");
  }

  /// Asking if the WebSite has permission
  if(requirePermission.contains(request["method"]))
  {
    bool hasPermission = false;
    int allowed = await aUrl.isAllowed(origin);
    printApprove("Is allowed? $allowed");
    // List sites = await aUrl.getSites();
    // /// For now we're just gonna add it without permission
    // for (List site in sites)
    // {
    //   printMark("$site == $origin");
    //   if(site[0] == origin && site[1])
    //   {
    //     allowed = true;
    //     hasPermission = true;
    //   }
    // }
    if(allowed == 1)
    {
      hasPermission = true;
    }
    else if(allowed == 0)
    {
      /// Holding the request until the user interacts
      bool waiting = true;
      showDialog(
        context: context, builder: (BuildContext context) {
          return AppPopupWidget(
            title: "Warning",
            cancelable: false,
            canClose: false,
            actions: [
              AppNeonButton(
                expanded: false,
                onPressed: () {
                  aUrl.blockSite(origin);
                  Navigator.of(context).pop();
                },
                text: "CANCEL"
              ),
              AppButton(
                expanded: false,
                onPressed: () {
                  // hasPermission = true;
                  aUrl.allowSite(origin);
                  hasPermission = true;
                  Navigator.of(context).pop();
                },
                text: "ALLOW"
              ),
            ],
            children: [
              Column(
                children: [
                  Text("The website \"$origin\" is requesting your permission, allow it?")
                ],
              )
            ]
          );
      },
      ).then((value){
        waiting = false;
      });

      while(waiting)
      {
        await Future.delayed(Duration(seconds: 1));
        printMark("Waiting to confirm!");
      }
    }
    if(!hasPermission) {
      response = {
        "code": -32603,
        "error": errorList[-32603]
      };
      response.removeWhere((key, value) => key == "result");
    }

      // return;
  }

  /// Returning the request
  String res = jsonEncode({
    "type" : "eth:payload",
    "payload" : response
  });

  printApprove("window.postMessage($res)");
  controller.runJavascript("window.postMessage($res)");
}