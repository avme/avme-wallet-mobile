import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/app_scaffold.dart';
import 'package:avme_wallet/app/screens/tabs/accounts_old.dart';
import 'package:avme_wallet/app/screens/widgets/drawer_scaffold.dart';
// import 'package:avme_wallet/app/screens/widgets/tab_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/screens/debug_options.dart';
import 'package:avme_wallet/app/screens/tabs/accounts.dart';
import 'package:avme_wallet/app/screens/tabs/balance.dart';
import 'package:avme_wallet/app/screens/tabs/transactions.dart';
import 'package:provider/provider.dart';

class TabsWallet extends StatefulWidget {
  @override
  _TabsWalletState createState() => _TabsWalletState();
}

class _TabsWalletState extends State<TabsWallet>{
  // List of Tabs
  final Map<String,Widget> routes = {
    "PROTOTYPE: APP SCAFFOLD" : AppScaffold(),
    "ACCOUNTS OLD" : AccountsOld(),
    "ACCOUNTS" : Accounts(),
    "BALANCE" : Balance(),
    "TRANSACTIONS" : Transactions(),
    "DEBUG OPTIONS" : Options(),
  };

  @override
  Widget build(BuildContext context) {
    AvmeWallet appState = Provider.of<AvmeWallet>(context);
    return DefaultTabController(
      initialIndex: 2,
      length: routes.length,
      child: DrawerScaffold(
        pages: routes,
        options: ["Options", "Reload", "Close"],
        title: Text(appState.appTitle),
      ),
    );
  }
}
