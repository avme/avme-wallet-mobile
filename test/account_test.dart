import 'dart:math';

import 'package:avme_wallet/app/src/controller/wallet/account.dart';
import 'package:flutter_test/flutter_test.dart';

class AccountTest
{
  static void main()
  {
    Account();
    List? initAccounts;
    Map entry = {
      "slot" : 0,
      "title" : "Example Account",
      "derived": 0,
      "data": "",
    };

    group("Accounts", () {
      test("Initialization", () async {
        // initAccounts = await Account.accounts.future;
        initAccounts = await Account().rawAccounts.future;
        expect(initAccounts!.length, greaterThanOrEqualTo(0));
      });
      test("Insert a new Account to accounts", () async {
        bool didInsetAnAccount = await Account.add(entry, null);
        expect(didInsetAnAccount, true);
      });
      test("Validate pass by Reference", () async {
        await Future.delayed(const Duration(milliseconds: 500));
        List _lastList = await Account().rawAccounts.future;
        expect(_lastList.length, equals(initAccounts!.length));
      });
      test("Remove added account", () async {
        bool didRemoveAnAccount = await Account.remove(entry);
        expect(didRemoveAnAccount, true);
      });
    });
  }
}