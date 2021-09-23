import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/gradient_card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {

  final Map<String,Widget> routes;
  final String side;
  const AppDrawer(this.routes, {this.side = "RIGHT"});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {

    List<Widget> drawerElements = [
      header(context)
    ];

    widget.routes.forEach((key, value) {
      drawerElements.add(
        ListTile(
          title: Text(key),
          onTap: () {
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => value));
            Navigator.push(context, MaterialPageRoute(builder: (context) => value));
          }
        )
      );
    });

    // drawerElements.add(
    //   ListTile(
    //     title: const Text('Close'),
    //     onTap: () {
    //       Navigator.pop(context);
    //     },
    //   )
    // );

    drawerElements.add(
      GradientCard(
        address: "0x000000000000000000000000000000",
        onPressed: () => NotificationBar().show(context, text:"Item Taped"),
        onIconPressed: () {},
        balance: "32 60,032621000",
        label: "Account #1")
    );

    drawerElements.add(
      GradientCard(
        address: "0x000000000000000000000000000000",
        onPressed: () => NotificationBar().show(context, text:"Item Taped"),
        onIconPressed: () {},
        balance: "69 696,96900000",
        label: "Account #2")
    );

    drawerElements.add(
      GradientCard(
        address: "0x000000000000000000000000000000",
        onPressed: () => NotificationBar().show(context, text:"Item Taped"),
        onIconPressed: () {},
        balance: "2 332,632621000",
        label: "Account #3")
    );

    drawerElements.add(
      footer(context)
    );

    List<Widget> finalDrawer = [];

    drawerElements.asMap().forEach((pos,element) {
      if(pos == 0 || (pos + 1) == drawerElements.length)
        finalDrawer.add(element);
      else
        finalDrawer.add(Padding(
          padding: EdgeInsets.only(bottom: 28),
          child: element,
        ));
    });

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: widget.side.toUpperCase() == "RIGHT" ? labelRadius.topLeft * 2 : labelRadius.topRight * 2,
        bottomLeft:widget.side.toUpperCase() == "RIGHT" ? labelRadius.bottomLeft * 2 : labelRadius.bottomRight * 2,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 8 * 7,
        child: Drawer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24.0),
            child: ListView(
              padding: EdgeInsets.zero,
              children: finalDrawer,
            ),
          ),
        ),
      ),
    );
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
                        // color: Colors.red,
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