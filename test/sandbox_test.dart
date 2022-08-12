import 'package:avme_wallet/app/src/controller/network/network.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
Future main() async
{
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  io.HttpOverrides.global = null;
  await dotenv.load(fileName: '.env');
  Print(debug: dotenv.env["DEBUG_MODE"] == "TRUE" ? true : false);

  test("Request AVME value from Network", () async {
    Iterable<double> value = await Network.getPrice(address: "0x1ecd47ff4d9598f89721a2866bfeb99505a413ed");
    Print.mark("[Coin Value] 0x1ecd47ff4d9598f89721a2866bfeb99505a413ed: $value");
    expect(value.length, greaterThan(0));
  });
}