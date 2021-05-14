import 'package:avme_wallet/screens/helper.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/controller/globals.dart' as global;
import 'package:avme_wallet/screens/debug_options.dart';
import 'package:avme_wallet/screens/widgets/colored_tab_bar.dart';
import 'package:avme_wallet/config/main_theme.dart' as theme;
import 'package:avme_wallet/screens/tabs/accounts.dart';
import 'package:avme_wallet/screens/tabs/balance.dart';
import 'package:avme_wallet/screens/tabs/transactions.dart';

class TabsWallet extends StatefulWidget {
  @override
  _TabsWalletState createState() => _TabsWalletState();
}

class _TabsWalletState extends State<TabsWallet> with Helpers {
  BuildContext _this;

  @override
  Widget build(BuildContext context) {
    _this = context;
    return DefaultTabController(
      initialIndex: 1,
      length: 4,
      child: Scaffold(
        // Testing transparency
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(global.appTitle),
          // Testing transparency, removes shadow
          elevation: 0,
          backgroundColor: Color(0x81000000),
          actions: [
          PopupMenuButton(
            onSelected: _popupMenuButtom,
            itemBuilder: (BuildContext context)
            {
              return {'Exit','Settings'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
          ],
          bottom: ColoredTabBar(
            Color(0x23FFFFFF),
            TabBar(
              isScrollable: true,
              tabs: [
                Tab(
                  text: "ACCOUNTS",
                ),
                Tab(
                  text: "BALANCE",
                ),
                Tab(
                  text: "TRANSACTIONS",
                ),
                Tab(
                  text: "DEBUG OPTIONS",
                ),
              ],
            ),
          ),
        ),
        body:
          Container(
          decoration: theme.backgroundImage,
          child:
            SafeArea(
              child:
                TabBarView(
                children: <Widget>[
                  Accounts(),
                  Balance(),
                  Transactions(),
                  Options(),
                ],
              )
          ),
        ),
      ),
    );
  }

  void _popupMenuButtom(String val)
  {
    //Switch
    snack(val, _this);
  }
}
