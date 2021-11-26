import 'package:avme_wallet/app/controller/contacts.dart';
import 'package:avme_wallet/app/controller/services/balance.dart';
import 'package:avme_wallet/app/controller/services/contract.dart';
import 'package:avme_wallet/app/controller/services/push_notification.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/active_contracts.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/welcome.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  AvmeWallet wallet;
  Contracts contractsService;
  @override
  void initState()
  {
    wallet = Provider.of<AvmeWallet>(context, listen: false);
    Provider.of<ContactsController>(context, listen: false);
    Provider.of<ActiveContracts>(context, listen: false);
    contractsService = Contracts.getInstance();
    contractsService.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: startWalletServices(context),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.data == null)
            return Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        AppColors.purpleVariant1,
                        AppColors.purpleBlue
                      ]
                  )
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/resized-newlogo02-trans.png',
                      width: MediaQuery.of(context).size.width * 1 / 4.5,
                      fit: BoxFit.fitHeight,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Text(
                        "AVME",
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          else
            return Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        AppColors.purpleVariant1,
                        AppColors.purpleBlue
                      ]
                  )
              ),
            );
        },
      ),
    );
  }

  Future<void> startWalletServices(BuildContext context) async
  {
    await Future.delayed(Duration(milliseconds: 500),() async{
      wallet.contracts = contractsService.contracts;
      if(!wallet.services.containsKey("valueSubscription"))
        valueSubscription(wallet);
      if(env["ALWAYS_RESET"].toString().toUpperCase() == "TRUE")
        wallet.walletManager.deletePreviousWallet();

      bool walletExists = await wallet.walletManager.walletAlreadyExists();
      print("walletExists? $walletExists");
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => Welcome(walletExists:walletExists)
      ));
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