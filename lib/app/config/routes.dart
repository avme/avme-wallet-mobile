import 'package:avme_wallet/app/screens/prototype/app_scaffold.dart';
import 'package:avme_wallet/app/screens/prototype/login.dart' as pl;
import 'package:avme_wallet/app/screens/prototype/overview.dart';
import 'package:avme_wallet/app/screens/qrcode_reader.dart';
import 'package:avme_wallet/app/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/screens/tabswallet.dart';
import 'package:avme_wallet/app/screens/splashscreen.dart';
import 'package:avme_wallet/app/screens/new_password.dart';
import 'package:avme_wallet/app/screens/login_old.dart';
import 'package:avme_wallet/app/screens/debug_options.dart';
import 'package:avme_wallet/app/screens/login.dart';


/// Default route when the app launches
String defaultRoute = '/initialLoad';

/// Routes that can be called anywere by their name
Map<String,WidgetBuilder> routes =
{
  '/initialLoad' : (context) => SplashScreen(),
  '/registerPassword' : (context) => NewPassword(),
  '/home' : (context) => TabsWallet(),
  '/debugOptions' : (context) => Options(),
  '/old' : (context) => LoginOld(),
  '/login' : (context) =>Login(),
  '/welcome' : (context) =>Welcome(),
  '/qrScanner':(context) => QRScanner(),

  ///Prototype routes

  'app/login' : (context) => pl.Login(),
  'app/overview' : (context) => AppScaffold(),
};