import 'package:avme_wallet/app/src/controller/wallet/authentication.dart';
import 'package:avme_wallet/app/src/controller/wallet/wallet.dart';
import 'package:flutter_test/flutter_test.dart';

class AuthenticationTest {
  static void main(String password){
    Authentication();
    group("Authentication", () {
      bool canAuthenticate = false;
      test("Authenticate by password", () async {
        bool didAuth = await Wallet.auth(password);
        expect(didAuth, true);
      });
      test("Device has any method of authentcation?", () async {
        canAuthenticate = Authentication.canAuthenticate;
      });
      // if(canAuthenticate) {
      //   test("Check available methods", () async {
      //     List<BiometricType> types = Authentication.availableBiometrics;
      //     for (BiometricType type in types) {
      //       Utils.printApprove("Available type: $type");
      //     }
      //   });
      //   test("Request Auth", () async {});
      // }
      // else {
      //   test("Can't authenticate", (){});
      // }
    });
  }
}