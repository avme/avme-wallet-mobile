import 'package:avme_wallet/app/controller/services/push_notification.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/import_account.dart';
import 'package:avme_wallet/app/screens/prototype/new_account.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double buttonSpacing = SizeConfig.safeBlockVertical * 4;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[AppColors.purpleVariant1, AppColors.purpleBlue])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal * 8,
              ),
              child: Card(
                color: AppColors.cardBlue,
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.safeBlockVertical * 6,
                      horizontal: SizeConfig.safeBlockVertical * 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Welcome to AVME",
                            textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.titleSize)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.safeBlockVertical * 3,
                          ),
                          child: ScreenIndicator(
                            height: 20,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                        Column(
                          children: [
                            AppButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (builder) => NewAccount()));
                              },
                              text: "CREATE NEW WALLET",
                            ),
                            SizedBox(
                              height: buttonSpacing,
                            ),
                            AppNeonButton(
                              textStyle: TextStyle(color: Colors.white, fontSize: SizeConfig.spanSize * 1.6),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (builder) => ImportAccount()));
                              },
                              text: "IMPORT WALLET",
                            ),
                            SizedBox(
                              height: buttonSpacing,
                            ),
                            AppNeonButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/login");
                              },
                              enabled: false,
                              text: "LOAD WALLET",
                            ),
                          ],
                        )
                      ],
                    ),
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
