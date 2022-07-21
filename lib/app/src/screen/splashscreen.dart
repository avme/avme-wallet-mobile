import 'package:avme_wallet/app/src/controller/wallet/wallet.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/screen/widgets/theme.dart';
import 'package:flutter/material.dart';

import 'package:avme_wallet/app.dart';
import 'package:flutter/scheduler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    appInitialization();
  }

  void appInitialization() async
  {
    await App.ready.future;

    if(Wallet.exists)
    {
      Navigator.pushReplacementNamed(context, "/login");
    }
    else
    {
      Navigator.pushReplacementNamed(context, "/welcome");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
      )
    );
  }
}
