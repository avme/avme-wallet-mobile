import 'package:avme_wallet/app/src/controller/settings.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:flutter_test/flutter_test.dart';

class SettingsTest {
  static void main()
  {
    Settings settings = Settings();
    group("Testing settings", () {
      test("Initialize", () async {
        bool didInit = await settings.init.future;
        expect(didInit, true);
      });
      test("Recover setting by key", () async {
        // dynamic value = Settings.get("security");
        dynamic value = Settings.get("fingerprint");
        Print.approve(value.toString());
      });

      test("Configure setting by key", () async {
        // dynamic value = Settings.get("security");
        dynamic value = Settings.set("fingerprint", true);
        Print.approve(value.toString());
      });
    });
  }
}