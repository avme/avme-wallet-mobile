import 'package:avme_wallet/app/controller/contacts.dart';
import 'package:avme_wallet/app/controller/services/connection.dart';
import 'package:avme_wallet/app/model/token_chart.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/config/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:avme_wallet/app/model/app.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/controller/file_manager.dart';

main() async{
  WidgetsFlutterBinding.ensureInitialized();

  AppConnection appConnection = AppConnection.getInstance();
  appConnection.initialize();

  await DotEnv.load();
  await Hive.initFlutter();
  Hive.registerAdapter(TokenChartAdapter());
  await Hive.openBox<TokenChart>("dashboard_chart");
  FileManager fileManager = FileManager();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<AvmeWallet>(create:(_) => AvmeWallet(fileManager)),
        ChangeNotifierProvider<ContactsController>(create:(_) => ContactsController(fileManager)),
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return OverlaySupport.global(
      child: MaterialApp(
        theme: avmeTheme,
        initialRoute: defaultRoute,
        routes: routes),
    );
  }
}





