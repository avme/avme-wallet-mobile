import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/widgets/balance/line_chart.dart';
import 'package:avme_wallet/app/screens/widgets/balance/quick_access_card.dart';
import 'package:avme_wallet/app/screens/widgets/balance/status_card.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Balance extends StatefulWidget {
  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  AvmeWallet appState;
  double qrSize;

  Widget build(BuildContext context) {

    appState = Provider.of<AvmeWallet>(context);
    // appState.walletManager.startBalanceSubscription(appState);
    appState.tProcesses.keys.forEach((key) {
      print("KEYS:$key");
    });
    print("ACCOUNT LIST:");
    print(appState.accountList);
    print(appState.accountList.length);
    print("ACCOUNT #0");
    print(appState.accountList[0]);
    return Scrollbar(
      child: ListView(
        children:
          [
            Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ///AVME value chart
                  SizedBox(
                    height: 8,
                  ),
                  ///Main info card
                  StatusCard(appState: appState),
                  SizedBox(
                    height: 8,
                  ),
                  ///Quick-access card
                  QuickAccessCard()
                ],
              )
            ),
          )
      ],),
    );
  }

  String copyPrivateKey() {
    String _hex = appState.currentAccount.address;
    return _hex.substring(0, 12) + "..." + _hex.substring(_hex.length - 12);
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(
        ClipboardData(text: appState.currentAccount.address));
    snack("Address copied to clipboard", context);
  }
}