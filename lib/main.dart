import 'package:avme_wallet/app.dart';
import 'package:avme_wallet/app/src/controller/controller.dart';
import 'package:avme_wallet/app/src/controller/wallet/contacts.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/screen/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';

import 'app/src/controller/routes.dart';
import 'app/src/controller/wallet/token/coins.dart' hide Platform;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  bool debug = dotenv.env["DEBUG_MODE"] == "TRUE" ? true : false;
  Print(debug: debug);

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    Print.error("Platform is windows or linux!");
  }

  App app = App();
  Account account = Account();
  Coins coins = Coins();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<App>(create: (_) => app),
        ChangeNotifierProvider<Coins>(create: (_) => coins),
        ChangeNotifierProvider<Account>(create: (_) => account),
        ChangeNotifierProvider<Contacts>(create: (_) => Contacts()),
      ],
      child: AvmeApp(app: app,),
    )
  );
}
class AvmeApp extends StatefulWidget {
  final App app;
  const AvmeApp({Key? key, required this.app}) : super(key: key);

  @override
  State<AvmeApp> createState() => AvmeAppState();
}

class AvmeAppState extends State<AvmeApp> {

  @override
  void initState() {
    super.initState();
    if(SchedulerBinding.instance != null)
    {
      SchedulerBinding.instance!.addPostFrameCallback(widget.app.frameCallback);
    }
  }

  @override
  Widget build(BuildContext context) {
    ///Default route is SplashScreen in there the app waits
    ///for every essential initialization and completes inside App.ready
    return OverlaySupport.global(
      child: MaterialApp(
        navigatorKey: Routes.globalContext,
        initialRoute: Routes.defaultRoute,
        routes: Routes.list,
        theme: AppTheme.theme,
      ),
    );
  }
}
