import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/transaction_information.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
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
  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AvmeWallet>(context);
    // checkTransactionPending();
    return Scaffold(
        appBar:AppBar(title: Text("Receive")),
        body: Container(
            child:
            Column(
              children: [
                Text(appState.currentAccount.address),
                ElevatedButton (
                    onPressed: () async{
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
                      // if(appState.lastTransactionWasSucessful.retrievingData == false)
                      // {
                      //   Navigator.pop(loadingDialog);
                      // }
                    },
                    child: Text("Send")),
                // Consumer<AvmeWallet>
                //   (builder: (builder, appState, child) {
                //   return ElevatedButton (
                //       onPressed: appState.lastTransactionWasSucessful.retrievingData ? null : buttonPress,
                //       child: Text("Testing TransactionInformation controller"));
                // }),
                // Selector<AvmeWallet, TransactionInformation>(
                // selector: (context, model) => model.lastTransactionWasSucessful,
                // builder: (context, transactionInformation, child){
                //   if(loadingDialog == null && transactionInformation.retrievingData)
                //   showDialog(
                //     context: context,
                //     barrierDismissible: false,
                //     builder: (BuildContext context) {
                //       loadingDialog = context;
                //       return CircularLoading(text: "Requesting Transaction, please wait.");
                //     },
                //   );
                //   else if(loadingDialog != null && transactionInformation.retrievingData)
                //   {
                //     Navigator.pop(loadingDialog);
                //   }
                //   appState.wasLastTransactionInformationSuccessful();
                //   return Text(transactionInformation.retrievingData.toString());
                //
                // })
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
