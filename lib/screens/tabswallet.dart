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

  // List of Tabs
  final Map<String,Widget> _tabs = {
    "ACCOUNTS" : Accounts(),
    "BALANCE" : Balance(),
    "TRANSACTIONS" : Transactions(),
    "DEBUG OPTIONS" : Options(),
  };
  final EdgeInsets padding = EdgeInsets.all(12.0);
  // Return a list of types...
  // 1 - Key names as TAB to populate the TabBar
  // 2 or more - Widget List to the TabBarView
  List<Widget> extractTabData(int type)
  {
    List<Widget> _list = [];
    if(type == 1)
    {
      _tabs.forEach((key, value) {
        _list.add(Tab(text:key));
      });
    }
    else
    {
      _tabs.forEach((key, value) {
        _list.add(Padding(padding: padding, child: value));
      });
    }

    return _list;
  }

  @override
  Widget build(BuildContext context) {
    _this = context;
    return DefaultTabController(
      initialIndex: 1,
      length: _tabs.length,
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
              tabs: extractTabData(1),
            ),
          ),
        ),
        body:
          Container(
          decoration: theme.backgroundImage,
          child:
            SafeArea(
              child: TabBarView(
                children: extractTabData(2),
              ),
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
