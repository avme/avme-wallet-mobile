import 'package:flutter/material.dart';
import 'package:avme_wallet/app/config/routes.dart';
import 'package:avme_wallet/config/main_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

Future<void> main() async{
  await DotEnv.load();
  runApp(AvmeWallet());
}

class AvmeWallet extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: defaultTheme(),
      initialRoute: defaultRoute,
      routes: routes);
  }
}





