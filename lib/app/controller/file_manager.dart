import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class FileManager
{
  String documentsFolder;
  String ext = ".json";
  String accountFolder = "Accounts/";
  String transactions = "Transactions/";
  String filename = "accounts";

  Future<String> getDocumentsFolder() async
  {
    final directory = await getApplicationDocumentsDirectory();
    documentsFolder = directory.path+"/";
    return documentsFolder;
  }

  String filesFolder()
  {
    final path = this.documentsFolder;
    return "$path$accountFolder";
  }

  Future<File> accountFile () async
  {
    String fullPath;
    await checkPath(filesFolder());
    fullPath = filesFolder()+"$filename$ext";
    return File(fullPath);
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