import 'dart:async';

import 'package:avme_wallet/app/controller/contacts.dart';
import 'package:avme_wallet/app/controller/services/connection.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/active_contracts.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/login.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/welcome.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{

  AvmeWallet wallet;
  ActiveContracts activeContracts;
  Future serviceSpawner;
  AppConnection appConnection;
  bool hadConnection = false;
  StreamSubscription stream;
  @override
  void initState()
  {
    wallet = Provider.of<AvmeWallet>(context, listen: false);
    Provider.of<ContactsController>(context, listen: false);
    activeContracts = Provider.of<ActiveContracts>(context, listen: false);
    super.initState();
    WidgetsBinding.instance
      .addPostFrameCallback((_) {
      appConnection = AppConnection.getInstance();
      hadConnection = appConnection.hasConnection;
      stream = appConnection.appConnectionChangeController.stream.listen((connectionEvent) {
        if(connectionEvent is List)
        {
          if(!hadConnection && connectionEvent[0])
            Navigator.pop(context);
          if(hadConnection && !connectionEvent[0])
          {
            internetPopup();
          }
          hadConnection = connectionEvent[0];
        }
      });
      serviceSpawner = startWalletServices(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: FutureBuilder(
        future: serviceSpawner,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.data == null) {
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
          } else {
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
          }
        },
      ),
    );
  }

  Future<void> startWalletServices(BuildContext context) async
  {
    if(!hadConnection)
      internetPopup();
    do await Future.delayed(Duration(milliseconds: 250));
    while(!hadConnection);

    await Future.delayed(Duration(milliseconds: 250),() async{
      if(!wallet.services.containsKey("valueSubscription"))
        wallet.walletManager.startValueSubscription(wallet);
      if(dotenv.get("ALWAYS_RESET").toString().toUpperCase() == "TRUE")
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

  void internetPopup() async
  {
    // BuildContext context = NavigationService.globalContext.currentContext;
    showDialog(context: context, builder:(_) =>
        AppPopupWidget(
          title: "Warning!",
          cancelable: false,
          canClose: false,
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 12),
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right:SizeConfig.safeBlockVertical * 2, left: SizeConfig.safeBlockVertical * 1),
                      child: Icon(Icons.warning_rounded, color: Colors.yellow, size: SizeConfig.safeBlockVertical * 6,),
                    )
                  ],
                ),
                Flexible(
                  child: Text("This Device has no connection to internet.",),
                ),
              ],
            ),
          ],
        )
    );
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }
}