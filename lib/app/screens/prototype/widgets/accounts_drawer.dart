import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/app_drawer.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/gradient_card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AccountsDrawer extends StatefulWidget {

  final AvmeWallet app;

  const AccountsDrawer({Key key, @required this.app}) : super(key: key);

  @override
  _AccountsDrawerState createState() => _AccountsDrawerState();
}

class _AccountsDrawerState extends State<AccountsDrawer> {
  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    List<Widget> drawerElements = [
      header(context)
    ];

    widget.app.accountList.forEach((key,accountObject) {
        // bool selected = key == widget.app.currentWalletId ? true : false;
        DecorationTween balanceTween = DecorationTween(
            begin: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      appColors.preColorList[key][0],
                      appColors.preColorList[key][1]
                    ]
                )
            ),
            end: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      appColors.preColorList[key][2],
                      appColors.preColorList[key][3]
                    ]
                )
            )
        );

        drawerElements.add(
            GradientCard(
                address: accountObject.address,
                onPressed: (){
                  widget.app.setCurrentWallet(key);
                  Navigator.of(context).pop();
                  NotificationBar().show(context, text:"Account \"${widget.app.accountList[key].title}\" selected.");
                },
                onIconPressed: () {},
                balance: accountObject.currencyBalance == null || accountObject.currencyTokenBalance == null ? "0,0000000" :
                "${shortAmount((accountObject.currencyBalance +
                    accountObject.currencyTokenBalance).toString(),comma: true, length: 7)}",
                label: accountObject.title,
                balanceTween: balanceTween,
            ),
        );
    });

    drawerElements.add(
        footer(context)
    );

    List<Widget> finalDrawer = [];

    drawerElements.asMap().forEach((pos,element) {
      if(pos == 0)
        finalDrawer.add(element);
      else
        finalDrawer.add(Padding(
          padding: EdgeInsets.only(bottom: 28),
          child: element,
        ));
    });

    return AppDrawer(finalDrawer.asMap());
  }

  Widget header(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        top:12,
        right: 16,
        bottom: 28,
      ),
      child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Accounts",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ///Close button
                      GestureDetector(
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 16,
                              bottom: 10,
                            ),
                            child: Icon(
                              Icons.account_circle_outlined,
                              size: 36,
                              color: AppColors.purple,
                            ),
                          ),
                        ),
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ScreenIndicator(
              height: 20,
              width: MediaQuery.of(context).size.width,
              position: 0,
              equal: true,
            ),
          ]
      ),
    );
  }

  Widget footer(BuildContext context)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppNeonButton(
          onPressed: () => NotificationBar().show(context, text: "Import was taped"),
          text: "IMPORT",
          expanded: false,
          paddingText: EdgeInsets.symmetric(horizontal: 16),
          textStyle: TextStyle(
              color: Colors.white
          ),
        ),
        AppButton(
          onPressed: () => NotificationBar().show(context, text: "New Account was taped"),
          text: "New",
          expanded: false,
          paddingText: EdgeInsets.symmetric(horizontal: 24),
          textStyle: TextStyle(
              color: Colors.white
          ),
        ),
      ],
    );
  }
}