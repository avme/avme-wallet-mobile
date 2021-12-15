import 'package:avme_wallet/app/controller/contacts.dart';
import 'package:avme_wallet/app/controller/services/balance.dart';
import 'package:avme_wallet/app/controller/services/contract.dart';
import 'package:avme_wallet/app/controller/services/push_notification.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/active_contracts.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/login.dart';
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

class _InitialLoadingState extends State<InitialLoading>{
  AvmeWallet wallet;
  ActiveContracts activeContracts;
  @override
  void initState()
  {
    wallet = Provider.of<AvmeWallet>(context, listen: false);
    Provider.of<ContactsController>(context, listen: false);
    activeContracts = Provider.of<ActiveContracts>(context, listen: false);
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
                      'assets/avme_logo.png',
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
      if(!wallet.services.containsKey("valueSubscription"))
        wallet.walletManager.startValueSubscription(wallet);
      if(env["ALWAYS_RESET"].toString().toUpperCase() == "TRUE")
        wallet.walletManager.deletePreviousWallet();

      bool walletExists = await wallet.walletManager.walletAlreadyExists();
      print("walletExists? $walletExists");
      if(walletExists)
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => Login(canGoBack: walletExists,)
        ));
      else
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => Welcome()
        ));
    });
  }
}