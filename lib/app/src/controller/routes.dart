import 'package:avme_wallet/app/src/screen/screen.dart';
import 'package:avme_wallet/app/src/screen/tests_screen.dart' as tests;
import 'package:flutter/material.dart';

///This class contains every route and the default route path
class Routes {
  static Map<String, WidgetBuilder> list = {
    //Routes before the user Authenticates
    "/splashscreen" : (context) => SplashScreen(),
    "/welcome" : (context) => Welcome(),
    "/login" : (context) => Login(),

    //Navigation Routes
    "/navigation/dashboard": (context) => AppScaffold(),
    "/tests/dashboard": (context) => tests.Dashboard(),
  };

  static String defaultRoute = "/splashscreen";

  static GlobalKey<NavigatorState> globalContext = GlobalKey<NavigatorState>();
}