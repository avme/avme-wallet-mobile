// @dart=2.12
import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../../../controller/web/web_utils.dart';
import '../../../../../lib/utils.dart';
import '../../button.dart';
import '../../neon_button.dart';
import '../../popup.dart';

Future<bool> requestApproveTransaction(BuildContext context, Map<String,String> transactionData, {bool unlocked = false, required AllowedUrls allowedUrls})
async {
  int gas = int.parse(transactionData["gas"]!.replaceAll('0x', ''), radix: 16);
  int intValue = int.parse(transactionData["v"]!.replaceAll('0x', ''), radix: 16);
  printOk(transactionData.toString());
  /// Awaiting the user to confirm the transaction
  Completer<bool> askForTransaction = Completer();
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
                askForTransaction.complete(false);
                Navigator.of(context).pop();
              },
              text: "CANCEL"
          ),
          AppButton(
              expanded: false,
              onPressed: () {
                askForTransaction.complete(true);
                Navigator.of(context).pop();
              },
              text: "CONFIRM"
          ),
        ],
        children: [
          Column(
            children: [
              // Text("The website \"$origin\" is requesting your permission, allow it?")
              RichText(
                text:TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: 'The following website is requesting a transaction: \n'),
                    TextSpan(text: '${transactionData["origin"]}\n', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: 'Total Value: '),
                    TextSpan(text: '0.0\n', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: 'Gas Limit: '),
                    TextSpan(text: '$gas\n', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: 'Fee Cost: '),
                    TextSpan(text: '0.0 AVAX\n', style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
                textAlign: TextAlign.center,
              )
            ],
          )
        ]
    );
  });
  return await askForTransaction.future;
}