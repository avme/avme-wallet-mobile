import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/transaction_information.dart';
import 'package:avme_wallet/app/screens/qrcode_reader.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class Send extends StatelessWidget {
  BuildContext loadingDialog;
  AvmeWallet appState;
  TextEditingController sendersAddress;
  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AvmeWallet>(context);

    // checkTransactionPending();
    return Scaffold(
      appBar:AppBar(title: Text("Send")),
      body: Container(
        child:
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                child: Column(
                  children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child:
                        TextField(
                          controller: sendersAddress,
                          decoration: InputDecoration(
                              hintText: "Scan or type the address here."
                          ),
                        ),
                      ),
                      SizedBox(width: 16,),
                      SizedBox(
                          width: 60,
                          height: 60,
                          child:
                          ElevatedButton(onPressed: () async {
                            // snack("Abre camera ScanQR", context);
                            String response = await Navigator.push(context, MaterialPageRoute(builder: (context) => QRScanner()));
                            //TODO: Use the returned data into transferer screen
                            snack(response, context);
                          },child:Icon(Icons.qr_code, size: 28,))
                          // ElevatedButton(onPressed: () {snack("Abre camera ScanQR", context);},child:Text("yes"))
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Center(child:
                    ElevatedButton(onPressed: () => startTransaction(context),
                    child: Text("Enviar"),
                    ),
                  )
                  ],
                ),
              ),
            ],
          ),
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

  void startTransaction(BuildContext context) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        loadingDialog = context;
        return CircularLoading(text: "Requesting Transaction, please wait.");
      },
    );
    await appState.walletManager.sendTransaction(appState);
    Navigator.pop(loadingDialog);
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

  void buttonPress(){
    print("the memes!");
  }

  // void checkTransactionPending()
  // {
  //   bool closed = loadingDialog == null ? true : false;
  //   while(!closed) {
  //     Future.delayed(Duration(microseconds: 200), () {
  //       closed = !appState.lastTransactionWasSucessful.retrievingData ? true : false;
  //       if(closed == true)
  //       {
  //         Navigator.pop(loadingDialog);
  //       }
  //     });
  //   }
  // }
}
