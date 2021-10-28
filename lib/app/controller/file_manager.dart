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

  Future<File> contactsFile() async
  {
    await getDocumentsFolder();
    String fileFolder = "${this.documentsFolder}$contacts";
    print(fileFolder);
    await checkPath(fileFolder);
    File file = File("${fileFolder}contacts$ext");
    if(!await file.exists())
    {

      await file.writeAsString(this.encoder.convert({
        "contacts" : [
          {
            "name": "User One",
            "address": "0x4214496147525148769976fb554a8388117e25b1"
          },
          {
            "name": "User Two",
            "address": "0x4214496147525148769976fb554a8388117e25b1"
          },
          {
            "name": "User Three",
            "address": "0x4214496147525148769976fb554a8388117e25b1"
          }
        ]
      }));
    }
    return file;
  }
}