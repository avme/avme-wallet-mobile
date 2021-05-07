import 'package:flutter/material.dart';
import 'package:avme_wallet/screens/tabswallet.dart';
import 'package:avme_wallet/screens/initial_loading.dart';
import 'package:avme_wallet/screens/new_password.dart';
import 'package:avme_wallet/screens/login_old.dart';
import 'package:avme_wallet/screens/debug_options.dart';

Map<String,WidgetBuilder> routes =
{
  '/initialLoad' : (context) => InitialLoading(),
  '/registerPassword' : (context) => NewPassword(),
  '/home' : (context) => TabsWallet(),
  '/debugOptions' : (context) => Options(),
  '/old' : (context) => LoginOld(),
};

String defaultRoute = '/initialLoad';