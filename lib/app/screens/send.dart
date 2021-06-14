import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class Send extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Consumer<AvmeWallet>
      (builder: (context, appState, child) {
      return Scaffold(
          appBar:AppBar(title: Text("Send")),
          body: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      // constraints: BoxConstraints.expand(),
                      // color: Colors.red,
                      child: Center(
                        child:
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: QrImage(
                            backgroundColor: Colors.white,
                            data: "Futagostosa1234123",
                            version: QrVersions.auto,
                            size: getQrSize(context),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      // color: Colors.red,
                      child: Card(
                          child: ListTile(
                            horizontalTitleGap: 100,
                            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                            title: Text('Address:'),
                            subtitle: Text(
                                getAddress(appState)
                            ),
                            // trailing: Icon(Icons.share_sharp),
                            trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                      onTap:() => _copyToClipboard(context, appState),
                                      child:Icon(Icons.copy)
                                  ),
                                  Text("   "),
                                  GestureDetector(
                                    // onTap:() => snack("Please implement the context sharing!", context),
                                      onTap:() => _shareAddress(context, appState),
                                      child:Icon(Icons.share_sharp)
                                  ),
                                ]),
                            isThreeLine: false,
                          )
                      ),
                    ),
                  ],
                ),
              )
          )
      );
    }
    );
  }
  String getAddress(AvmeWallet appState)
  {
    return appState.accountList[appState.currentWalletId].address;
  }
  double getQrSize(BuildContext context)
  {
    double qrSize = MediaQuery.of(context).size.width <= 200 ?
    MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.6
    ;
    return qrSize;
  }

  Future<void> _copyToClipboard(BuildContext context, AvmeWallet appState) async {
    await Clipboard.setData(ClipboardData(text: appState.accountList[appState.currentWalletId].address));
    snack("Address copied to clipboard",context);
  }

  void _shareAddress(BuildContext context, AvmeWallet appState) {
    Share.share(
        appState.accountList[appState.currentWalletId].address,
        subject: "Sharing ${appState.appTitle} address."
    );
  }
}
