import 'package:avme_wallet/app/screens/prototype/login.dart' as pl;
import 'package:avme_wallet/app/screens/prototype/overview.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/screens/tabswallet.dart';
import 'package:avme_wallet/app/screens/initial_loading.dart';
import 'package:avme_wallet/app/screens/new_password.dart';
import 'package:avme_wallet/app/screens/login_old.dart';
import 'package:avme_wallet/app/screens/debug_options.dart';
import 'package:avme_wallet/app/screens/login.dart';


/// Default route when the app launches
String defaultRoute = '/initialLoad';

/// Routes that can be called anywere by their name
Map<String,WidgetBuilder> routes =
{
  '/initialLoad' : (context) => InitialLoading(),
  '/registerPassword' : (context) => NewPassword(),
  '/home' : (context) => TabsWallet(),
  '/debugOptions' : (context) => Options(),
  '/old' : (context) => LoginOld(),
  '/login' : (context) =>Login(),

  ///Prototype routes

  'test/login' : (context) => pl.Login()
};

/// TabController reads the named Widgets from the list,
/// and assembles the AppScaffold

Map <String, Widget> tabRoute = {
  'About' : Center(
    child: Text(
      'About',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  'Overview' : Overview(),
  'History' : Center(
    child: Text(
      'History',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
};