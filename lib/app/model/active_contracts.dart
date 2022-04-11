import 'dart:convert';
import 'dart:isolate';
import 'dart:io';
import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:avme_wallet/app/controller/services/contract.dart';
import 'package:avme_wallet/app/model/token.dart';
import 'package:flutter/material.dart';

class ActiveContracts extends ChangeNotifier
{
  final FileManager fileManager;
  Contracts sContracts;
  bool initialized = false;
  Token token;
  List<String> tokens = [
    "AVME testnet",
    "AVME",
    "Local testnet"
  ];
  Map<String, Isolate> services = {};

  ActiveContracts(this.fileManager){
    Future<File> _fileTokens = tokensFile();
    token = Token();
    _fileTokens.then((File file) async {
      List<String> tokensInFile = List<String>.from(jsonDecode(await file.readAsString()));
      this.tokens = tokensInFile ?? this.tokens;
      sContracts = Contracts.getInstance();
      sContracts.initialize(this.tokens).then((_) {
        initialized = true;
        notifyListeners();
      });
    });
  }

  Future<File> tokensFile() async
  {
    await this.fileManager.getDocumentsFolder();
    String fileFolder = this.fileManager.documentsFolder;
    await this.fileManager.checkPath(fileFolder);
    File file = File("${fileFolder}tokens${this.fileManager.ext}");
    if(!await file.exists())
      await file.writeAsString(this.fileManager.encoder.convert(tokens));
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
      services.remove(services[key]);
    }
  }

  Future<void> _updateFile() async
  {
    File _file = await tokensFile();
    await _file.writeAsString(fileManager.encoder.convert(tokens));
  }

  void watchTokenValueChanges()
  {
    token.addListener(() {
      notifyListeners();
    });
  }
}