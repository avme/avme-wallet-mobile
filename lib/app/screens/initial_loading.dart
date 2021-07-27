import 'package:avme_wallet/app/controller/services/balance.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class InitialLoading extends StatefulWidget {
  @override
  _InitialLoadingState createState() => _InitialLoadingState();
}

class ButtonText extends StatelessWidget {
  final String text;
  ButtonText({this.text});
  Widget build(BuildContext context) {
    return Text(text,
        // style: theme.alertDialogText()
    );
  }
}

class _InitialLoadingState extends State<InitialLoading>{
  /*GENERIC LOADING SCREEN*/
  @override
  void initState()
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    startWalletServices(context);
    return Scaffold(
      body: Container(
        // color: theme.defaultTheme().scaffoldBackgroundColor,
        child: Center(
          child: SpinKitDualRing(
            color: Colors.white,
            size: 50.0,
          ),
        ),
      ),
    );
  }

  void startWalletServices(BuildContext context) async
  {
    AvmeWallet wallet = Provider.of<AvmeWallet>(context);
    wallet.init();
    if (!wallet.services.containsKey("tokenPriceHistory"))
      getTokenPriceHistory(wallet);

    if (!wallet.services.containsKey("updateCoinValues"))
      updateCoinValues(wallet);

    await wallet.fileManager.getDocumentsFolder();

    if(env["ALWAYS_RESET"].toString().toUpperCase() == "TRUE")
    {
      wallet.walletManager.deletePreviousWallet();
    }

    bool hasWallet = await wallet.walletManager.walletAlreadyExists();

    if(hasWallet == false)
      welcomeDialog();

    else
      Navigator.pushReplacementNamed(context, "/login");
    snack("Wallet already created previously? \"$hasWallet\"", context);
  }

  Future<void> welcomeDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Welcome to AVME Wallet'),
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Do you want to restore a backup, or create a new wallet?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: ButtonText(text: "RESTORE BACKUP"),
              onPressed: () {
                // Navigator.of(context).pop();
                // TODO: implement backup process
                snack("NOT IMPLEMENTED", context);
              },
            ),
            TextButton(
              child: ButtonText(text: "CREATE NEW",),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/registerPassword");
              },
            ),
          ],
        );
      },
    );
  }
}