import 'package:avme_wallet/app/screens/prototype/new_account.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';

import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(
                  (MediaQuery.of(context).size.width * 0.1).toDouble()
              ),
              child: Card(
                color: AppColors.cardBlue,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                          "Welcome to AVME",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 28)
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      ScreenIndicator(
                        height: 20,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 32,
                            ),
                            AppButton(
                              onPressed: () {
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (builder) => NewAccount()));
                              },
                              text: "CREATE NEW WALLET",
                            ),
                            SizedBox(
                              height: 32,
                            ),
                            AppNeonButton(
                              onPressed: () {},
                              text: "IMPORT WALLET",
                              textStyle: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                            SizedBox(
                              height: 32,
                            ),
                            AppNeonButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/login");
                              },
                              text: "LOAD WALLET",
                              textStyle: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
