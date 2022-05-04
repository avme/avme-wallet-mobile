// @dart=2.12

import 'dart:convert';
import 'dart:io';

import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/authentication.dart';
import 'package:provider/provider.dart';

class AuthApi {
  static Authentication _authApi = Authentication();

  static late bool _canAuthenticate;
  static late bool _isFingerprintEnabled;

  /// Do not use
  AuthApi._init();

  /// Initialize the Authentication API with this method
  /// 
  /// AuthApi authApi = await AuthApi.init();
  static Future<AuthApi> init() async {
    var authApi = AuthApi._init();
    //
    final FileManager fileManager = FileManager();
    Future<File> settingsFile() async {
      await fileManager.getDocumentsFolder();
      String fileFolder = "${fileManager.documentsFolder}";
      await fileManager.checkPath(fileFolder);
      File file = File("${fileFolder}settings${fileManager.ext}");
      if (!await file.exists()) {
        await file.writeAsString(fileManager.encoder.convert({
          "display": {"deviceGroupCustom": "0"},
          "options": {"fingerprintAuth": false}
        }));
      }
      return file;
    }

    Future<File> fileContacts = settingsFile();
    await fileContacts.then((File file) async {
      Map contents = jsonDecode(await file.readAsString());
      Map<String, dynamic> fileMap = Map<String, dynamic>.from(contents["options"]);
      _isFingerprintEnabled = fileMap["fingerprintAuth"];
    });
    //
    _canAuthenticate = await _authApi.canAuthenticate();
    return authApi;
  }

  ///-------------------------------------------------------------------------------

  /// For settings.dart, new_account.dart and only
  bool isHardwareAllowed() {
    return _canAuthenticate;
  }

  /// For settings.dart only
  Future<dynamic> saveSecret(String secret) {
    return _authApi.saveSecret(secret);
  }

  /// For settings.dart only
  Future<dynamic> deleteSecret() {
    return _authApi.deleteSecret();
  }

  ///-------------------------------------------------------------------------------

  /// Returns true if hardware available and configured in settings, else false
  ///
  /// Use this before promptFingerprint or retrieveSecret
  bool canAuthenticate() {
    if (_canAuthenticate && _isFingerprintEnabled)
      return true;
    else
      return false;
  }

  /// Prompts user fingerprint to access anything that doesn't need the password,
  ///
  /// as it returns only true or false
  Future<bool> promptFingerprint() async {
    return await _authApi.promptFingerprint();
  }

  /// Returns a string with the user password, or an exception if an error.
  ///
  /// Exceptions usually don't occur here if you first use canAuthenticate()
  /// to verify if the hardware can and user has enabled and configured fingerprint
  ///
  /// Either way, if (result is String) to verify the password returned correctly
  Future<dynamic> retrieveSecret() async {
    return await _authApi.retrieveSecret();
  }
}
