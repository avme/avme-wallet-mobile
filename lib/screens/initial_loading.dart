import 'package:avme_wallet/screens/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:avme_wallet/controller/globals.dart' as globals;
import 'package:avme_wallet/config/main_theme.dart' as theme;
import 'package:avme_wallet/screens/widgets/custom_widgets.dart';

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
  /*GENERIC LOADING SCREEN*/
  @override
  void initState()
  {
    super.initState();
    _initialLoadingContext = context;
    getData();
  }
  void getData() async
  {
    if(env["ALWAYS_RESET"].toString().toUpperCase() == "TRUE")
    {
      await globals.walletManager.deletePreviousWallet();
    }

    bool hasWallet = await globals.walletManager.hasPreviousWallet();

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
              child: _buttonText(text: "RESTORE BACKUP"),
              onPressed: () {
                // Navigator.of(context).pop();
                // TODO: implement backup process
                snack("NOT IMPLEMENTED", context);
              },
            ),
            TextButton(
              child: _buttonText(text: "CREATE NEW",),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/registerPassword");
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
}