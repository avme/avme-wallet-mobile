import 'package:avme_wallet/screens/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:avme_wallet/controller/globals.dart' as global;
import 'package:avme_wallet/config/main_theme.dart' as theme;

BuildContext _initialLoadingContext;

class InitialLoading extends StatefulWidget {
  @override
  _InitialLoadingState createState() => _InitialLoadingState();
}

class _buttonText extends StatelessWidget {
  final String text;
  _buttonText({this.text});
  Widget build(BuildContext context) {
    return Text(text,
        style: theme.alertDialogText()
    );
  }
}

class _InitialLoadingState extends State<InitialLoading> with Helpers{
  //LIFE CYCLE
  /*GENERIC LOADING SCREEN*/
  @override
  void initState() {
    super.initState();
    _initialLoadingContext = context;
    getData();
  }
  void getData() async
  {
    await Future.delayed(Duration(microseconds: 2000), () async {
      // Navigator.pushReplacementNamed(context, "/options");

      await global.walletManager.deletePreviousWallet();
      bool hasWallet = await global.walletManager.hasPreviousWallet();

      if(hasWallet == false)
      {
        // THIS DIALOG MUST INIT THE WALLET ON THE GLOBAL
        welcomeDialog();
      }
      snack("Had wallet \"$hasWallet\"", context);
    });
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
              child: _buttonText(text: "RESTORE BACKUP"),
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: implement backup process
                snack("NOT IMPLEMENTED", context);
              },
            ),
            TextButton(
              child: _buttonText(text: "CREATE NEW",),
              onPressed: () async {
                // TODO: implement passphrase, confirmation then create the wallet, for now is disabled
                String retForm = await Navigator.pushNamed(context, "/registerPassword") as String;
                // String retForm = "abacaxi";
                // snack(retorno, context);
                String ret = await global.walletManager.makeAccount(retForm);
                snack("$ret : PW: $retForm", context);

                if(global.walletManager.logged())
                {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, "/home");
                  return true;
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: theme.backgroundImage,
          child: Center(
            child: SpinKitDualRing(
              color: Colors.white,
              size: 50.0,
            ),
          ),
        ),
    );
  }
}