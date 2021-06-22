import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/config/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:avme_wallet/app/model/app.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnv.load();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<AvmeWallet>(create:(_) => AvmeWallet()),
        ChangeNotifierProvider<AppLoadingState>(create:(_) => AppLoadingState())
      ],
    child: AvmeWalletApp(),
    )
  );
}

class AvmeWalletApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return MaterialApp(
      theme: avmeTheme,
      initialRoute: defaultRoute,
      routes: routes);
  }
}





