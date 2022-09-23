import 'package:avme_wallet/app/src/controller/ui/popup.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/balance.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/helper/utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

import 'filemanager_test.dart';
import 'network_test.dart';
import 'threads_test.dart';
import 'token_test.dart';
import 'wallet_test.dart';

Future main() async
{
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  io.HttpOverrides.global = null;
  await dotenv.load(fileName: '.env');
  Print(debug: dotenv.env["DEBUG_MODE"] == "TRUE" ? true : false);

  await HomeTests.main();
}

class HomeTests
{
  static Future main() async
  {
    // ProgressDialog dialog = await ProgressPopup.display();
    // dialog.percentage.value = 99;
    // dialog.label.value = "gunman";
    // await Future.delayed(Duration(seconds: 2));
    // dialog.percentage.value = 100;
    // dialog.label.value = "done";
    FileManagerTest.main();
    Print.error("is in testnet? ${Utils.inTestnet()}");
    String password = "abacaxi";
    WalletTest.main(password);
    TokenTest.main();
    // WalletTest.main("abacaxi");
    NetworkTest.main();
    await ThreadsTest.main();

  }
}