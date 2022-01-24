import 'package:avme_wallet/app/controller/database/recently_sent.dart';
import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:avme_wallet/app/model/contacts.dart';
import 'package:avme_wallet/app/model/recently_sent.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
class ContactsController extends ChangeNotifier {

  final FileManager fileManager;
  Map<int,Contact> contacts = {};

  ContactsController(this.fileManager)
  {
    Future<File> fileContacts = this.contactsFile();
    fileContacts.then((File file) async {
      Map contents = jsonDecode(await file.readAsString());
      List lContacts = contents["contacts"];
      lContacts.asMap().forEach((key,contact) {
        contacts[key] = Contact(contact["name"], contact["address"]);
      });
    });
  }

  Future<File> contactsFile() async
  {
    await this.fileManager.getDocumentsFolder();
    String fileFolder = "${this.fileManager.documentsFolder}Contacts/";
    print(fileFolder);
    await this.fileManager.checkPath(fileFolder);
    File file = File("${fileFolder}contacts${this.fileManager.ext}");
    if(!await file.exists())
    {
      /*
      await file.writeAsString(this.fileManager.encoder.convert({
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
    */
    }
    return file;
  }

  void addContact(String name ,String address)
  async {
    int newKey;
    (contacts.isEmpty) ? newKey = 0 : newKey = contacts.keys.last + 1;
    contacts[newKey] = Contact(name, address);
    //add to Recently Thinged database for testing porpuses.  Should be instead added to when the user sends tokens instead
    await RecentlySentTable.instance.insert(RecentlySent(name: name, address: address));
    _updateContactsFile();
  }

  void removeContact(int position)
  async {
    if (contacts.containsKey(position)) {
      String address = contacts[position].address;
      contacts.remove(position);
      await RecentlySentTable.instance.delete(address);
    }
    // contacts.removeWhere((key, value) => key == position);
    // contacts.removeAt(position);
    _updateContactsFile();
  }

  void updateContact(int position, String name, String address)
  async {
    String tempAddress = contacts[position].address;
    contacts[position] = Contact(name, address);
    await RecentlySentTable.instance.delete(tempAddress);
    await RecentlySentTable.instance.insert(RecentlySent(name: name,address: address));
    _updateContactsFile();
  }

  void _updateContactsFile()
  {
    Future<File> fileContacts = contactsFile();
    fileContacts.then((File file) async {
      Map<String, List> mContacts = {"contacts" : []};
      contacts.values.forEach((Contact contact) {
        mContacts["contacts"].add(
          {
            "name" : contact.name,
            "address" : contact.address
          }
        );
      });
      file.writeAsString(fileManager.encoder.convert(mContacts));
    });
  }
}