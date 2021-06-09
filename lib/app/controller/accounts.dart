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