// @dart=2.12

import 'dart:convert';
import 'dart:io';

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

  ///Returns true if user was verified with fingerprint
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
            key, secret, AndroidPrompt('Enable Fingerprint', 'Cancel', description: 'Scan fingerprint to enable fingerprint authentication')),
      );

      return 'Secret saved';
    } on Exception catch (exception) {
      return exception;
    }
  }

  /// Dynamic allows return of string if true, exception if false
  Future<dynamic> retrieveSecret() async {
    try {
      final retrieved = await FlutterLocker.retrieve(RetrieveSecretRequest(
          key, AndroidPrompt('Authenticate', 'Cancel', description: 'Scan fingerprint to authenticate'), IOsPrompt('Authenticate')));

      return retrieved;
    } on Exception catch (exception) {
      print(exception);
      return exception;
    }
  }

  Future<dynamic> deleteSecret() async {
    dynamic retrieved;
    try {
      retrieved = await FlutterLocker.retrieve(RetrieveSecretRequest(
          key,
          AndroidPrompt('Disable fingerprint', 'Cancel', description: 'Scan fingerprint to disable fingerprint authentication'),
          IOsPrompt('Disable fingerprint')));

      if (retrieved is String) {
        return await _deleteSecret();
      }
    } on Exception catch (exception) {
      print(exception);
      return exception;
    }
  }

  Future<String> _deleteSecret() async {
    try {
      await FlutterLocker.delete(key);

      return 'Secret deleted';
    } on Exception catch (exception) {
      return '$exception';
    }
  }
}
