import 'package:avme_wallet/app/src/helper/file_manager.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';

import 'package:avme_wallet/app/src/helper/enums.dart';

import '../../helper/print.dart';

class Contact {
  String name;
  String address;
  Contact(this.name, this.address);
}

class Contacts extends ChangeNotifier {
  Map<int,Contact> contacts = {};

  String filename = 'contacts.json';
  String folder = AppRootFolder.Accounts.name;

  Contacts() { _init(); }

  void _init() async {
    bool exists = await FileManager.fileExists(folder, filename);
    Print.warning("$folder/$filename: $exists");

    if(!exists)
    {
      await FileManager.writeString(folder, filename, []/*jsonEncode([])*/);
      return;
    }

    Object source = await FileManager.readFile(folder, filename);
    if(source is String)
    {
      Map contents = jsonDecode(source) as Map;
      List list = contents["contacts"];
      list.asMap().forEach((key,contact) {
        contacts[key] = Contact(contact["name"], contact["address"]);
      });
    }
    Print.warning("Contacts: ${source.runtimeType}");
  }

  void addContact(String name ,String address) async {
    int newKey;
    (contacts.isEmpty) ? newKey = 0 : newKey = contacts.keys.last + 1;
    contacts[newKey] = Contact(name, address);
    _updateContactsFile();
  }

  void _updateContactsFile() async
  {
    Map<String, List> _contacts = {"contacts" : []};
    contacts.values.forEach((Contact contact) {
      _contacts["contacts"]!.add(
        {
          "name" : contact.name,
          "address" : contact.address
        }
      );
    });
    bool didSave = await FileManager.writeString(folder, filename, jsonEncode(_contacts));
    if(!didSave) {
      throw "Error at Account.add: Could not save the account's data";
    }
  }

  void removeContact(int position) async
  {
    if (contacts.containsKey(position)) {
      contacts.remove(position);
    }
    _updateContactsFile();
  }

  void updateContact(int position, String name, String address) async
  {
    contacts[position] = Contact(name, address);
    _updateContactsFile();
  }

  // Contacts()
  // {
  //   Future<File> fileContacts = this.contactsFile();
  //   fileContacts.then((File file) async {
  //     Map contents = jsonDecode(await file.readAsString());
  //     List lContacts = contents["contacts"];
  //     lContacts.asMap().forEach((key,contact) {
  //       contacts[key] = Contact(contact["name"], contact["address"]);
  //     });
  //   });
  // }

  // Future<File> contactsFile() async
  // {
  //   await this.fileManager.getDocumentsFolder();
  //   String fileFolder = "${this.fileManager.documentsFolder}Contacts/";
  //   await this.fileManager.checkPath(fileFolder);
  //   File file = File("${fileFolder}contacts${this.fileManager.ext}");
  //   if(!await file.exists())
  //   {
  //     await file.writeAsString(this.fileManager.encoder.convert({
  //       "contacts" : []
  //     }));
  //   }
  //   return file;
  // }
  //
  // void addContact(String name ,String address)
  // async {
  //   int newKey;
  //   (contacts.isEmpty) ? newKey = 0 : newKey = contacts.keys.last + 1;
  //   contacts[newKey] = Contact(name, address);
  //   //add to Recently Thinged database for testing porpuses.  Should be instead added to when the user sends tokens instead
  //   await RecentlySentTable.instance.insert(RecentlySent(name: name, address: address));
  //   _updateContactsFile();
  // }
  //
  // void removeContact(int position)
  // async {
  //   if (contacts.containsKey(position)) {
  //     String address = contacts[position].address;
  //     contacts.remove(position);
  //     await RecentlySentTable.instance.delete(address);
  //   }
  //   // contacts.removeWhere((key, value) => key == position);
  //   // contacts.removeAt(position);
  //   _updateContactsFile();
  // }
  //
  // void updateContact(int position, String name, String address)
  // async {
  //   String tempAddress = contacts[position].address;
  //   contacts[position] = Contact(name, address);
  //   await RecentlySentTable.instance.delete(tempAddress);
  //   await RecentlySentTable.instance.insert(RecentlySent(name: name,address: address));
  //   _updateContactsFile();
  // }
  //
  // void _updateContactsFile()
  // {
  //   Future<File> fileContacts = contactsFile();
  //   fileContacts.then((File file) async {
  //     Map<String, List> mContacts = {"contacts" : []};
  //     contacts.values.forEach((Contact contact) {
  //       mContacts["contacts"].add(
  //           {
  //             "name" : contact.name,
  //             "address" : contact.address
  //           }
  //       );
  //     });
  //     file.writeAsString(fileManager.encoder.convert(mContacts));
  //   });
  // }
}