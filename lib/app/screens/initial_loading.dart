import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart' as theme;
import 'package:provider/provider.dart';

class InitialLoading extends StatefulWidget {
  @override
  _InitialLoadingState createState() => _InitialLoadingState();
}

class buttonText extends StatelessWidget {
  final String text;
  buttonText({this.text});
  Widget build(BuildContext context) {
    return Text(text,
        style: theme.alertDialogText()
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
    getData(context);
    return Scaffold(
      body: Container(
        color: theme.defaultTheme().scaffoldBackgroundColor,
        child: Center(
          child: SpinKitDualRing(
            color: Colors.white,
            size: 50.0,
          ),
        ),
      ),
    );
  }

  void getData(BuildContext context) async
  {
    //Initialize the appLoadingState
    AvmeWallet wallet = Provider.of<AvmeWallet>(context);
    wallet.init();
    print("Wallet init was called...");
    //REMOVE THE GLOBALS REFERENCE AND USE THE AppState / AvmeWallet Model please

    await wallet.fileManager.getDocumentsFolder();

    if(env["ALWAYS_RESET"].toString().toUpperCase() == "TRUE")
    {
      wallet.walletManager.deletePreviousWallet();
    }

    bool hasWallet = await wallet.walletManager.hasPreviousWallet();

    if(hasWallet == false)
    {
      welcomeDialog();
    }
    else
    {
      Navigator.pushReplacementNamed(context, "/login");
    }
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
              child: buttonText(text: "RESTORE BACKUP"),
              onPressed: () {
                // Navigator.of(context).pop();
                // TODO: implement backup process
                snack("NOT IMPLEMENTED", context);
              },
            ),
            TextButton(
              child: buttonText(text: "CREATE NEW",),
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