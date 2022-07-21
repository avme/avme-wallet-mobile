import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:avme_wallet/app/src/controller/wallet/wallet.dart';
import 'package:avme_wallet/app/src/helper/enums.dart';
import 'package:avme_wallet/app/src/screen/widgets/hint.dart';
import 'package:flutter_locker/flutter_locker.dart';
import 'package:avme_wallet/app/src/helper/file_manager.dart';
import 'package:avme_wallet/app/src/helper/print.dart';

class Authentication {
  static final Authentication _self = Authentication._internal();

  factory Authentication() => _self;

  static final String _root = AppRootFolder.Root.name;
  static const String _file1 = 'secret';
  static const String _file2 = '50e33fb77b';

  Completer<bool> init = Completer();
  static Completer<bool> registeredAuth = Completer();
  static bool canAuthenticate = false;
  String _key = "";

  AndroidPrompt androidPrompt = AndroidPrompt("Please Authenticate", 'Cancel');
  IOsPrompt iOsPrompt = IOsPrompt("Please Authenticate");

  Authentication._internal() {
    _init();
  }

  ///Validates if key is defined
  void _init() async {
    canAuthenticate = await FlutterLocker.canAuthenticate() ?? false;
    Object data = await FileManager.readFile(_root, _file2);
    if(data is String)
    {
      _key = data;
      registeredAuth.complete(true);
    }
    else
    {
      registeredAuth.complete(false);
    }
    init.complete(true);
  }

  ///If yes gives an option to authenticate using fingerprint
  ///else receives only PIN or Passphrase to authenticate
  static Future auth([String? password]) async {
    bool _auth = await registeredAuth.future;
    Print.warning("registredAuth? $_auth");

    ///Requests the device for recognition
    if(password == null && _auth)
    {
      String data = "";
      try {
        RetrieveSecretRequest request = RetrieveSecretRequest(_self._key,_self.androidPrompt, _self.iOsPrompt);
        data = await FlutterLocker.retrieve(request);
      }
      catch(e)
      {
        if(e is LockerException)
        { return _self._exception(e); }
      }
      await Wallet.auth(data);
      return data;
    }
    else if (!_auth) { return password; }
    // return Wallet.auth(password!);
    return password ?? "";
  }

  static Future<bool> registerDeviceRecognition(String password) async {
    bool _auth = await Wallet.auth(password);
    if(!canAuthenticate || !_auth)
    {
      Print.warning("[Device] This device has no recognition available");
      return false;
    }
    Random _rnd = Random.secure();
    List<int> bytes = List.generate(32, (index) => _rnd.nextInt(256));
    String key = base64Encode(bytes);
    SaveSecretRequest request = SaveSecretRequest(key, password, _self.androidPrompt);
    await FileManager.writeString(_root, _file2, key);
    await FlutterLocker.save(request);
    _self._key = key;
    registeredAuth = Completer()
      ..complete(true);
    return true;
  }

  void _exception(LockerException e)
  {
    switch(e.reason)
    {
      case LockerExceptionReason.authenticationCanceled:
        AppHint.show("Authentication cancelled by the user.");
        break;
      case LockerExceptionReason.authenticationFailed:
        AppHint.show("Failed to Recognise the Authentication, try again!");
        break;
      default:
        AppHint.show("Unknown Error, please use your password to login, and reset the Device Authentication");
        break;
    }
  }
}