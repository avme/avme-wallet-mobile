import 'dart:convert';
import 'dart:isolate';
import 'dart:io';
import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:flutter/material.dart';

class ActiveContracts extends ChangeNotifier
{
  final FileManager fileManager;
  List<String> tokens = [];
  Map<String, Isolate> services = {};

  ActiveContracts(this.fileManager){
    Future<File> _fileTokens = tokensFile();
    _fileTokens.then((File file) async {
      this.tokens = List<String>.from(jsonDecode(await file.readAsString()));

      // List lContacts = contents["contacts"];
      // lContacts.asMap().forEach((key,contact) {
      //   contacts[key] = Contact(contact["name"], contact["address"]);
      // });
    });
  }

  Future<File> tokensFile() async
  {
    await this.fileManager.getDocumentsFolder();
    String fileFolder = this.fileManager.documentsFolder;
    // print(fileFolder);
    await this.fileManager.checkPath(fileFolder);
    File file = File("${fileFolder}tokens${this.fileManager.ext}");
    if(!await file.exists())
    {
      await file.writeAsString(this.fileManager.encoder.convert(tokens));
    }
    return file;
  }

  Future<void> addToken(String name)
  async {
    print('ActiveContracts | Add Token "$name"');
    if(!tokens.contains(name))
    {
      tokens.add(name);
      await _updateFile();
      notifyListeners();
    }
  }

  Future<void> removeToken(String name) async {
    print('ActiveContracts | Remove Token "$name"');
    if(tokens.contains(name))
    {
      tokens.remove(name);
      await _updateFile();
      notifyListeners();
    }
  }

  void killService(String key)
  {
    if(services.containsKey(key))
    {
      print('ActiveContracts | KILL "$key"');
      services[key].kill(priority: Isolate.immediate);
      services.remove(key);
    }
  }

  Future<void> _updateFile() async
  {
    File _file = await tokensFile();
    await _file.writeAsString(fileManager.encoder.convert(tokens));
  }
}