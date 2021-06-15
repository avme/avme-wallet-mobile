import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class Send extends StatelessWidget {

  AvmeWallet appState;
  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AvmeWallet>(context);
    return Scaffold(
        appBar:AppBar(title: Text("Receive")),
        body: Container(
            child:
            Column(
              children: [
                Text(appState.currentAccount.address),
                ElevatedButton (
                    onPressed: (){
                      appState.walletManager.sendTransaction(appState);
                    },
                    child: Text("Send"))
              ],
            )
      )
    );
  }
  //
  // String getAddress(AvmeWallet appState)
  // {
  //   return appState.currentAccount.address;
  // }

  double getQrSize(BuildContext context)
  {
    double qrSize = MediaQuery.of(context).size.width <= 200 ?
    MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.6;
    return qrSize;
  }

  Future<void> _copyToClipboard(BuildContext context, AvmeWallet appState) async {
    await Clipboard.setData(ClipboardData(text: appState.currentAccount.address));
    snack("Address copied to clipboard",context);
  }

  void _shareAddress(BuildContext context, AvmeWallet appState) {
    Share.share(
        appState.currentAccount.address,
        subject: "Sharing ${appState.appTitle} address."
    );
  }
}
