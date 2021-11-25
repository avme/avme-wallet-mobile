import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class FileManager
{
  String documentsFolder;
  String ext = ".json";
  String accountFolder = "Accounts/";
  String transactions = "Transactions/";
  String contacts = "Contacts/";
  String filename = "accounts";
  JsonEncoder encoder = JsonEncoder.withIndent('  ');

  FileManager(){
    this.getDocumentsFolder();
  }

  Future<String> getDocumentsFolder() async
  {
    final directory = await getApplicationDocumentsDirectory();
    documentsFolder = directory.path+"/";
    return documentsFolder;
  }

  Future<File> accountFile() async
  {
    String fileFolder = "${this.documentsFolder}$accountFolder";
    await checkPath(fileFolder);
    return File("$fileFolder$filename$ext");
  }

  Future<bool> checkPath(path) async
  {
    bool exists = await Directory(path).exists();
    if(!exists)
    {
      await Directory(path).create(recursive: true);
      exists = true;
    }
    return exists;
  }
}