import 'dart:math';
import 'package:flutter/material.dart';

import 'package:avme_wallet/app/src/controller/ui/popup.dart';
import 'package:avme_wallet/app/src/controller/wallet/authentication.dart';
import 'package:avme_wallet/app/src/helper/crypto/wordlist.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/screen/widgets/buttons.dart';
import 'package:avme_wallet/app/src/screen/widgets/theme.dart';
import 'package:avme_wallet/app/src/controller/wallet/account.dart';
import 'package:avme_wallet/app/src/controller/wallet/wallet.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int dev = 0;
  bool didDerive = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: AppDarkButton(
              onPressed: () async {
                ProgressDialog progress = ProgressPopup.display();
                for(double i = 0; i < 100; i++)
                {
                  Random random = Random();
                  int index = random.nextInt(WORDLIST.length - 1);
                  progress.percentage.value = i;
                  progress.label.value = WORDLIST[index];
                  await Future.delayed(Duration(milliseconds: 40));
                }
                ProgressPopup.dismiss();
              },
              child: Text("TEST NEW POPUP"),
            ),
          ),
          Expanded(
            child: AppDarkButton(
              onPressed: () async {
                String? password = await Authentication.auth();
                if(password == null)
                { return; }
                int d = Account.accounts.length - 1;
                do {
                  didDerive = await Wallet.deriveAccount(password, d);
                  d++;
                }
                while(d < 10);

                List<AccountData> accounts = Account.accounts;
                for(int i = 0; i < accounts.length; i++)
                {
                  // EthereumAddress address = await accounts[i].address;
                  await accounts[i].hasAddress.future;
                  String address = accounts[i].address!;
                  Print.approve("Master | ID #$i Account Address: \"$address\"");
                  dev++;
                  setState(() {});
                }
              },
              child: Text(dev > 0 ? "Derive 10 Accounts" : "Derived $dev"),
            ),
          ),
          Expanded(child: Text("didDerive? $didDerive")),
          Expanded(
            child: Container(
              color: AppColors.darkBlue,
              child: Center(
                child: Text("Dashboard"),
              ),
            ),
          ),
        ],
      )
    );
  }
}
