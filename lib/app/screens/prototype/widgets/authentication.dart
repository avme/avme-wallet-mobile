// @dart=2.12

import 'package:flutter/material.dart';
import 'package:flutter_locker/flutter_locker.dart';

class Authentication {
  String key = '0';

  Future<bool> canAuthenticate() async {
    try {
      final canAuthenticate = await FlutterLocker.canAuthenticate();

      return canAuthenticate!;
    } on Exception catch (exception) {
      print(exception);
      return false;
    }
  }

  ///maybe not use this
  Future<bool> promptFingerprint() async {
    try {
      await FlutterLocker.retrieve(RetrieveSecretRequest(key, AndroidPrompt('Authenticate', 'Cancel'), IOsPrompt('Authenticate')));

      return true;
    } on Exception catch (exception) {
      return false;
    }
  }

  ///Made this future to return a dynamic variable.  It will always return a String if it is a success, and an expection if failure
  Future<dynamic> saveSecret(String secret) async {
    try {
      await FlutterLocker.save(
        SaveSecretRequest(
            key,
            secret,
            AndroidPrompt('Enable Fingerprint', 'Cancel',
                description: 'Scan any configured fingerprint in your phone to enable fingerprint authentication on login')),
      );

      return 'Secret saved, secret: $secret';
    } on Exception catch (exception) {
      return exception;
    }
  }

  Future<dynamic> retrieveSecret() async {
    try {
      final retrieved = await FlutterLocker.retrieve(RetrieveSecretRequest(
          key, AndroidPrompt('Authenticate', 'Cancel', description: 'Scan fingerprint to authenticate'), IOsPrompt('Authenticate')));

      return 'Secret retrieved, secret: $retrieved';
    } on Exception catch (exception) {
      print(exception);
      return exception;
    }
  }

  Future<dynamic> deleteSecretPrompt() async {
    try {
      final retrieved = await FlutterLocker.retrieve(RetrieveSecretRequest(
          key,
          AndroidPrompt('Disable fingerprint', 'Cancel', description: 'Scan fingerprint to disable fingerprint authentication'),
          IOsPrompt('Disable fingerprint')));

      return 'Secret retrieved, secret: $retrieved';
    } on Exception catch (exception) {
      print(exception);
      return exception;
    }
  }

  Future<String> deleteSecret() async {
    try {
      await FlutterLocker.delete(key);

      return 'Secret deleted';
    } on Exception catch (exception) {
      return '$exception';
    }
  }
}
