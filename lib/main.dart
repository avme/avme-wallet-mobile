
import 'package:flutter/material.dart';
import 'package:avme_wallet/controller/routes.dart' as appRoutes;
import 'package:avme_wallet/config/main_theme.dart';


void main() {
  runApp(AvmeWallet());
}

class AvmeWallet extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: defaultTheme(),
      initialRoute: appRoutes.defaultRoute,
      routes: appRoutes.routes);
  }
}





