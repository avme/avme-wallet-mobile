import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/screens/widgets/qr_display.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class Receive extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Consumer<AvmeWallet>
      (builder: (context, appState, child) {
        return Scaffold(
          appBar:AppBar(title: Text("Receive")),
          body: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Center(
                      child:
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: QrDisplay(
                          stringToRender: appState.currentAccount.address,
                        )
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
                          appState.currentAccount.address
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
