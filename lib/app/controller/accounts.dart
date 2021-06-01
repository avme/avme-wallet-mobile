import 'package:avme_wallet/app/controller/wallet_manager.dart';
import 'package:flutter/material.dart';

class AccountItem {
  AccountItem({
    this.expandedValue,
    this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

Future<List<String>> getAccountList(int qtdExample) async
{
  WalletManager wm = new WalletManager();
  List accounts = await wm.getAccounts();

  accounts.forEach((element) {
    debugPrint(element);
  });

  // List accounts = List<AccountItem>.generate(qtdExample, (index) {
  //   return AccountItem(
  //     headerValue: "Account $index",
  //     expandedValue: "Account id here...",
  //   );
  // }
  // );
  return accounts;
}