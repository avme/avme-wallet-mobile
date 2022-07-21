import 'dart:convert';
import 'dart:math';

import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'account_test.dart';
import 'autentication_test.dart';
import 'filemanager_test.dart';
import 'network_test.dart';
import 'threads_test.dart';
import 'token_test.dart';
import 'wallet_test.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

///Testing tokens
Future main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  io.HttpOverrides.global = null;
  await dotenv.load(fileName: '.env');
  Print(debug: dotenv.env["DEBUG_MODE"] == "TRUE" ? true : false);
  FileManagerTest.main();
  TokenTest.main();
  // await ThreadsTest.main();
  NetworkTest.main();
}

// Future<void> main() async
// {
//   // WidgetsFlutterBinding.ensureInitialized();
//   TestWidgetsFlutterBinding.ensureInitialized();
//   io.HttpOverrides.global = null;
//   await dotenv.load(fileName: '.env');
//   Print.warning("DEBUG_MODE: ${dotenv.env["DEBUG_MODE"]}");
//   Random random = Random.secure();
//   ///128bit password
//   List<int> byteList = List<int>.generate(32, (index) => random.nextInt(256));
//   // String password = base64Encode(byteList);
//   String password = "abacaxi";
//
//   FileManagerTest.main();
//   AccountTest.main();
//   WalletTest.main(password);
//   // AuthenticationTest.main(password);
//   NetworkTest.main();
//   // AuthenticationTest.finger();
//   WalletTest.dispose();
// }