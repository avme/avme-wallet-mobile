import 'dart:convert';

import 'package:avme_wallet/app/controller/contacts.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/contacts.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/qrcode_reader.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {

  final _contactsForm = GlobalKey<FormState>();

  List<Contact> filtered = [];
  List<bool> checkerList = [];
  bool editMode = false;
  bool deleteMode = false;
  bool editPopupEnabled = true;
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    EdgeInsets buttonPadding = EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 8
    );
    return Consumer<ContactsController>(
      builder: (context, controller, _){
        return ListView(
          children: [
            AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 12.0,
                          bottom: 20,
                          left: 16.0
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LabelText("Contacts", fontSize: 18),
                          // IconButton(onPressed: () {
                          //
                          // }, icon: FaIcon(FontAwesomeIcons.ellipsisV))
                          options(controller)
                        ],
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: searchBar(controller),
                    ),
                    this.editMode ? Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(child: Text("$selected Selected"))
                              ],
                            ),
                          ),
                          Expanded(
                              flex: 4,
                              child:
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ///Display edit popup
                                  AppButton(
                                    onPressed: this.editPopupEnabled ? () {
                                      this.checkerList.asMap().forEach((key, selected) {
                                        if(selected)
                                          editPopup(
                                            controller,
                                            key: key,
                                            setter: setState
                                          );
                                      });
                                    } : null,
                                    iconData: Icons.edit,
                                    text: "Edit",
                                    expanded: false,
                                    paddingBetweenIcons: 6,
                                    height: 38,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    buttonPadding: buttonPadding,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  ///Display Delete confirmation
                                  AppButton(
                                    onPressed: (){
                                      showDialog<void>(
                                        context: context,
                                        barrierDismissible: false, // user must tap button!
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: AppColors.darkBlue,
                                            title: Text('Warning!'),
                                            insetPadding: EdgeInsets.symmetric(horizontal: 20),
                                            content: SingleChildScrollView(
                                              child: RichText(
                                                text: TextSpan(
                                                  children: <TextSpan> [
                                                    TextSpan(
                                                      text: 'You\'re about to delete '
                                                    ),
                                                    TextSpan(
                                                      text: (this.selected > 1 ? '$selected contacts' : '$selected contact'),
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold
                                                      )
                                                    ),
                                                    TextSpan(
                                                      text: ', this process cannot be reverted!'
                                                    )
                                                  ]
                                                ),

                                              )
                                            ),
                                            actions: [
                                              AppNeonButton(
                                                expanded:false,
                                                onPressed: () => Navigator.of(context).pop(),
                                                text: "Cancel"
                                              ),
                                              //TODO: Fix the .removeContact method, causing errors due to List range, fix sequence please
                                              AppButton(
                                                expanded:false,
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  setState(() {
                                                    this.checkerList.asMap().forEach((key, selected) {
                                                      if(selected)
                                                        controller.removeContact(key);
                                                    });
                                                    this.selected = 0;
                                                    NotificationBar().show(
                                                      context,
                                                      text: selected == 1 ? "$selected Contact was removed." : "$selected Contacts was removed."
                                                    );
                                                  });
                                                },
                                                text: "Delete"
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    iconData: Icons.delete_outline,
                                    text: "Delete",
                                    expanded: false,
                                    paddingBetweenIcons: 6,
                                    height: 38,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    buttonPadding: buttonPadding,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  AppButton(
                                    onPressed: () => setState(() {
                                      this.editMode = !this.editMode;
                                      this.selected = 0;
                                      this.checkerList.asMap().keys.forEach((key)  =>
                                        this.checkerList[key] = false
                                      );
                                    }),
                                    iconData: Icons.close,
                                    text: "Cancel",
                                    expanded: false,
                                    paddingBetweenIcons: 6,
                                    height: 38,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    buttonPadding: buttonPadding,
                                  )
                                ],
                              )
                          ),
                        ],
                      ),
                    ) : Container(),
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.darkBlue
                        ),
                        child: GestureDetector(
                          onLongPress: (){
                            if(!this.editMode && controller.contacts.length > 0)
                            {
                              NotificationBar().show(context, text: "Entering Editing mode");
                              setState(() {
                                this.editMode = true;
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
                              child:
                                controller.contacts.length == 0
                                ? ListView(
                                  shrinkWrap: true,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Center(
                                        child: Text("No contacts found.")
                                      ),
                                    )
                                  ],
                                )
                                : ListView.builder(
                                shrinkWrap: true,
                                itemCount: filtered.length == 0 ? controller.contacts.length : filtered.length,
                                itemBuilder: (BuildContext context, index){
                                  List contactList = filtered.length == 0 ? controller.contacts : filtered;
                                  final contact = contactList[index];

                                  if(checkerList.length < (index + 1))
                                    checkerList.add(false);

                                  if(contactList.length > (index + 1))
                                    return Column(
                                      children: [
                                        contactWidget(contact, index),
                                        Divider(color: AppColors.labelDisabledColor,)
                                      ],
                                    );
                                  return contactWidget(contact, index);
                                },
                              ),
                            ),
                          ),
                        )
                    )
                  ],
                ),
            ),
          ],
        );
      }
    );
  }

  Widget options(ContactsController controller)
  {
    return Theme(
      data: avmeTheme.copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(onPressed:() async {
            String response = await Navigator.push(context, MaterialPageRoute(builder: (context) => QRScanner()));
            NotificationBar().show(context, text: "Scanned: \"$response\"");
            setState(() {
            // addressController.text = response;
            });
          }, icon: Icon(Icons.qr_code)),
          SizedBox(
            width: 24,
            child: PopupMenuButton(
              padding: EdgeInsets.all(0),
                onSelected: (value) {
                  print(value);
                  switch (value) {
                    ///New Contact
                    case 0:
                      editPopup(controller, setter: setState);
                      break;

                    ///Enter Edit mode
                    case 1:
                      setState(() {
                        this.editMode = true;
                      });
                      break;

                    default:
                      NotificationBar().show(context, text: "Not implemented!");
                      break;
                  }
                },
                itemBuilder: (context) =>
                [
                  PopupMenuItem(
                    child: Text("Add"),
                    value: 0,
                  ),
                  PopupMenuItem(
                    child: Text("Edit"),
                    value: 1,
                  ),

                  PopupMenuItem(
                    child: Text("Share"),
                    value: 2,
                  ),
                  PopupMenuItem(
                    child: Text("Import Contacts"),
                    value: 2,
                  ),
                  PopupMenuItem(
                    child: Text("Export Contacts"),
                    value: 2,
                  ),
                ]
            ),
          ),
        ],
      ),
    );
  }

  void editPopup(ContactsController controller, {int key = -1, StateSetter setter}) {
    TextEditingController address = TextEditingController(
      text: key != -1 ? controller.contacts[key].address : null
    );
    TextEditingController name = TextEditingController(
      text: key != -1 ? controller.contacts[key].name : null
    );
    showDialog(context: context, builder:(_) =>
        StatefulBuilder(builder: (builder, setState) =>
          Form(
            key: _contactsForm,
            child: AppPopupWidget(
              title: (key != -1 ? "Editing Contact" : "New Contact"),
              canClose: true,
              margin: EdgeInsets.all(16),
              cancelable: false,
              padding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 32
              ),
              children: [
                Row(
                  children: [
                    LabelText("Address", fontSize: 18,),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                AppTextFormField(
                  controller: address,
                  hintText: "e.g. 0x123456789ABCDEF...",
                  validator: (value) {
                    if (value.length != 42 || !isHex(value)) {
                      return 'This is not a valid address';
                    }
                    return null;
                  },
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8
                  ),
                  isDense: true,
                ),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  children: [
                    LabelText("Name", fontSize: 18,),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                AppTextFormField(
                  controller: name,
                  hintText: "Your contact's name",
                  validator: (value) {
                    if (value.length == 0) {
                      return 'This is not a valid name';
                    }
                    return null;
                  },
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8
                  ),
                  isDense: true,
                ),
                SizedBox(
                  height: 24.0,
                ),
                Divider(color: AppColors.labelDisabledColor,),
                SizedBox(
                  height: 24.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppNeonButton(
                      expanded: false,
                      onPressed: () => Navigator.of(context).pop(),
                      text: "Cancel"
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    AppButton(
                      expanded: false,
                      onPressed: () {
                        if(_contactsForm.currentState != null && _contactsForm.currentState.validate())
                        {
                          setter((){
                            ///Update the contact
                            if(key != -1)
                            {
                              controller.updateContact(
                                  key,
                                  name.text,
                                  address.text
                              );
                              NotificationBar().show(context, text:"Contact updated!");
                            }
                            ///Adds the contact
                            else
                            {
                              controller.addContact(
                                  name.text,
                                  address.text
                              );
                              NotificationBar().show(context, text:"Contact added!");
                            }
                          });
                          Navigator.of(context).pop();
                        }
                        else
                        {
                          return null;
                        }
                      },
                      text: "Save Contact"
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
              ],
            )
          )
      )
    );
  }

  Widget contactWidget(Contact contact, int position) {
    return GestureDetector(
      onTap: (){
        if(this.editMode)
          setState(() {
            this.checkerList[position] = !checkerList[position];
            this.selected = 0;
            this.checkerList.forEach((selected) {
              if(selected)
                this.selected++;
            });
            if(this.selected > 1)
              editPopupEnabled = false;
            else
              editPopupEnabled = true;
          });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    this.editMode ? Container(
                      child: Padding(
                        padding: const EdgeInsets.only(right:6.0),
                        child: SizedBox(
                          height: 48,
                          width: 24,
                          child: Checkbox(
                            fillColor: MaterialStateProperty.resolveWith(getColor),
                            value: this.checkerList[position],
                            onChanged: (bool value) {},
                          ),
                        ),
                      )
                    ) : Container(),
                    Icon(Icons.account_circle_outlined, size: 32, color: AppColors.purple,),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(contact.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                            Text(contact.address, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.arrow_forward_ios, color: AppColors.labelDefaultColor,)
                    ],
                  )
              ),
            ],
          ),
        ),
      ),
    );
    // Divider(color: AppColors.labelDisabledColor,),
  }

  Widget searchBar(ContactsController controller)
  {
    return AppTextFormField(
      onChanged: (String filter) {
        if(filter.length > 0)
        {
          this.filtered = [];
          controller.contacts.forEach((Contact contact) {
            RegExp inFilter = new RegExp(r''+filter+'',multiLine: false, caseSensitive: false);
            if(inFilter.hasMatch(contact.name))
              return this.filtered.add(contact);
          });
        }
        else
        {
          this.filtered = [];
        }
        setState((){});
      },
      icon: new Icon(Icons.search, color: AppColors.labelDefaultColor, size: 32,),
      // iconOnTap: () => NotificationBar().show(context, text:"Opening the camera"),
    );
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return AppColors.purple;
    }
    return AppColors.purple;
  }
}
