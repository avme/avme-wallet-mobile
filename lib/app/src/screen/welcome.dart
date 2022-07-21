import 'package:avme_wallet/app/src/screen/navigation/new.dart';
import 'package:avme_wallet/app/src/screen/widgets/buttons.dart';
import 'package:avme_wallet/app/src/screen/widgets/painted.dart';
import 'package:avme_wallet/app/src/screen/widgets/theme.dart';
import 'package:flutter/material.dart';

import 'package:avme_wallet/app/src/helper/size.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    double buttonSpacing = DeviceSize.safeBlockVertical * 4;
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
                horizontal: DeviceSize.safeBlockHorizontal * 8,
              ),
              child: Card(
                color: AppColors.cardBlue,
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: DeviceSize.safeBlockVertical * 6,
                      horizontal: DeviceSize.safeBlockVertical * 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Welcome to AVME",
                            textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: DeviceSize.titleSize)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: DeviceSize.safeBlockVertical * 3,
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
                                //TODO: Implement these widgets
                                Navigator.push(context, MaterialPageRoute(builder: (builder) => NewWallet()));
                              },
                              text: "CREATE NEW WALLET",
                            ),
                            SizedBox(
                              height: buttonSpacing,
                            ),
                            AppNeonButton(
                              textStyle: TextStyle(color: Colors.white, fontSize: DeviceSize.spanSize * 1.6),
                              onPressed: () {
                                //TODO: Implement these widgets
                                // Navigator.push(context, MaterialPageRoute(builder: (builder) => ImportAccount()));
                              },
                              text: "IMPORT WALLET",
                            ),
                            SizedBox(
                              height: buttonSpacing,
                            ),
                            AppNeonButton(
                              onPressed: () {
                                //TODO: Implement these widgets
                                // Navigator.pushNamed(context, "/login");
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
