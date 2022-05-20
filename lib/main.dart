import 'package:avme_wallet/app/controller/contacts.dart';
import 'package:avme_wallet/app/controller/services/connection.dart';
import 'package:avme_wallet/app/controller/threads.dart';
import 'package:avme_wallet/app/controller/web/webview.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/config/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'app/controller/file_manager.dart';
import 'app/model/active_contracts.dart';

main() async{
  WidgetsFlutterBinding.ensureInitialized();

  AppConnection appConnection = AppConnection.getInstance();
  appConnection.initialize();

  Threads threads = Threads.getInstance();
  threads.initialize();

  AppWebViewController controller = AppWebViewController.getInstance();

  await dotenv.load(fileName: ".env");
  FileManager fileManager = FileManager();
  ActiveContracts activeContracts = ActiveContracts(fileManager);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AvmeWallet>(create:(_) => AvmeWallet(fileManager, activeContracts)),
      ChangeNotifierProvider<ActiveContracts>(create:(_) => activeContracts),
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
        navigatorKey: NavigationService.globalContext,
        theme: avmeTheme,
        initialRoute: defaultRoute,
        routes: routes),
    );
  }
}

class NavigationService {
  static GlobalKey<NavigatorState> globalContext =
    GlobalKey<NavigatorState>();
}





