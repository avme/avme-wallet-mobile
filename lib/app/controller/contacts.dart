import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:avme_wallet/app/model/contacts.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
class ContactsController extends ChangeNotifier {

  final FileManager fileManager;
  List<Contact> contacts = [];

  ContactsController(this.fileManager)
  {
    print("[ContactsController]");
    Future<File> fileContacts = this.fileManager.contactsFile();
    fileContacts.then((File file) async {
      Map contents = jsonDecode(await file.readAsString());
      print("CONTATOS CARREGADOS:");
      print(contents["contacts"]);
      List lContacts = contents["contacts"];
      lContacts.forEach((contact) {
        contacts.add(Contact(contact["name"], contact["address"]));
      });
    });
  }

  void addContact(String name ,String address)
  {
    contacts.add(Contact(name, address));
    _updateContactsFile();
  }

  void removeContact(int position)
  {
    contacts.removeAt(position);
    _updateContactsFile();
  }

  void updateContact(int position, String name, String address)
  {
    contacts[position] = Contact(name, address);
    _updateContactsFile();
  }

  void _updateContactsFile()
  {
    Future<File> fileContacts = this.fileManager.contactsFile();
    fileContacts.then((File file) async {
      Map<String, List> mContacts = {"contacts" : []};
      contacts.forEach((Contact contact) {
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