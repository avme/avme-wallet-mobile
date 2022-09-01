import 'package:avme_wallet/app/src/controller/wallet/token/balance.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

Future main() async
{
  BalanceTestAbstract.main();
}
class BalanceTestAbstract {
  static Future main() async
  {
   await init();
    List<BalanceInfo> accountBalance = [
      PlatformBalance(dotenv.get("PLATFORM_NAME"), dotenv.get("PLATFORM_SYMBOL"), "0x1", decimals: 1),
      Balance("AVME Foundation", "AVME", "0x1ecd47ff4d9598f89721a2866bfeb99505a413ed", decimals: 18)
    ];

    Print.mark("AccountBalanceInfo: $accountBalance");

    test("Increment of inCurrency for network currency", () {
      ///PlatformBalance <BalanceInfo>
      accountBalance[0].qtd = 1000;
      accountBalance[0].inCurrency = 0.25;

      expect(accountBalance[0].qtd, 1000);
    });

   test("Increment of inCurrency for first token currency", () {
     ///PlatformBalance <BalanceInfo>
     accountBalance[1].qtd = 500;
     accountBalance[1].inCurrency = 0.2;

     expect(accountBalance[1].qtd, 500);
   });

   test("New Balance from token reference", (){
     CoinData token = CoinData("Test", "TTT", "0x1", "0xa", 1, "", "");
     Balance balance = Balance.fromToken(token);
     accountBalance.add(balance);
     Print.warning(accountBalance.toString());
     expect(accountBalance.last, equals(balance));
   });

    return;
  }

  static Future init() async
  {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    io.HttpOverrides.global = null;
    await dotenv.load(fileName: '.env');
    Print(debug: dotenv.env["DEBUG_MODE"] == "TRUE" ? true : false);
  }
}

