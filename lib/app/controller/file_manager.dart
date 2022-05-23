import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class FileManager {
  String documentsFolder;
  String ext = ".json";
  String accountFolder = "Accounts/";
  String importedAccountFolder = "Accounts/ImportedAccounts/";
  String transactions = "Transactions/";
  String filename = "accounts";
  String filenameImport = 'importedAccount';
  JsonEncoder encoder = JsonEncoder.withIndent('  ');

  FileManager() {
    this.getDocumentsFolder();
  }

  Future<String> getDocumentsFolder() async {
    final directory = await getApplicationDocumentsDirectory();
    documentsFolder = directory.path + "/";
    return documentsFolder;
  }

  Future<File> accountFile() async {
    String fileFolder = "${this.documentsFolder}$accountFolder";
    await checkPath(fileFolder);
    return File("$fileFolder$filename$ext");
  }

  Future<File> importedAccountFile() async {
    String fileFolder = "${this.documentsFolder}$importedAccountFolder";
    int i = await checkPathFile(fileFolder);
    return File("$fileFolder$filenameImport$i$ext");
  }

  /// For loading accounts
  Future<List<dynamic>> importedAccountFileRead() async {
    String fileFolder = "${this.documentsFolder}$importedAccountFolder";
    List<dynamic> list = await retrieveAllFiles(fileFolder);
    return list;
  }

  Future<bool> checkPath(path) async {
    bool exists = await Directory(path).exists();
    if (!exists) {
      await Directory(path).create(recursive: true);
      exists = true;
    }
    return exists;
  }

  Future<int> checkPathFile(path) async {
    int i = 0;
    bool exists = true;
    await Directory(path).create(recursive: true);
    while (exists) {
      exists = await File("$path$filenameImport$i$ext").exists();
      if (exists) ++i;
    }
    return i;
  }

  Future<List<dynamic>> retrieveAllFiles(path) async {
    int i = 0;
    bool exists = false, done = false;
    File file;
    List<File> list = [];
    List<dynamic> listReturn = [];

    Future<void> finish() async {
      if (list.isNotEmpty) {
        for (int i = 0; i < list.length; i++) {
          listReturn.add(jsonDecode(await list[i].readAsString()));
        }
      }
    }

    await Directory(path).create(recursive: true);
    while (!done) {
      exists = await File("$path$filenameImport$i$ext").exists();
      if (exists) {
        file = File("$path$filenameImport$i$ext");
        list.add(file);
        ++i;
      } else {
        await finish();
        done = true;
      }
    }
    return listReturn;
  }
}
