import 'dart:convert';

import 'package:avme_wallet/app/controller/contacts.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/contacts.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/labeltext.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/qrcode_reader.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {

  final _contactsForm = GlobalKey<FormState>();

  List<int> checkerList = [];
  // Map<int, bool> checkerList = {};
  List<int> filter = [];
  bool editMode = false;
  bool deleteMode = false;
  bool editPopupEnabled = true;
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final bottomInset = SizeConfig.safeBlockVertical;
    EdgeInsets buttonPadding = EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 8
    );
    return Consumer<ContactsController>(
      builder: (context, controller, _){
        return ListView(
          children: [
            AppCard(
                child: Container(
                  padding: EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            //top: 12.0,
                            bottom: bottomInset,
                            left: 16.0
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppLabelText(
                            "Contacts",
                            textStyle:
                                TextStyle(color: AppColors.labelDefaultColor),
                            fontSize: SizeConfig.fontSizeHuge,
                          ),
                            // IconButton(onPressed: () {
                            //
                            // }, icon: FaIcon(FontAwesomeIcons.ellipsisV))
                            options(controller, setState)
                          ],
                        )
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: bottomInset*3),
                        child: searchBar(controller.contacts),
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
                                        this.checkerList.forEach((key) =>
                                          editPopup(controller, key: key,
                                            setter: setState));
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
                                                AppButton(
                                                  expanded:false,
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                      this.checkerList.forEach((selected) {
                                                        controller.removeContact(selected);
                                                      });
                                                      NotificationBar().show(
                                                        context,
                                                        text: selected == 1 ? "$selected Contact was removed." : "$selected Contacts were removed."
                                                      );
                                                      cancel();
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
                                      onPressed: () => setState(() => cancel()),
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
                                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2.2),
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
                                  : ListView(
                                    shrinkWrap: true,
                                    children: contactsList(controller.contacts),
                                  ),
                              ),
                            ),
                          )
                      )
                    ],
                  ),
                ),
            ),
          ],
        );
      }
    );
  }

  Widget options(ContactsController controller, StateSetter setter )
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
            String scanned = await Navigator.push(context, MaterialPageRoute(builder: (context) => QRScanner()));
            NotificationBar().show(context, text: "Scanned: \"$scanned\"");
            editPopup(controller, setter: setter, address: scanned);
          }, icon: Icon(Icons.qr_code_scanner)),
          SizedBox(
            width: 24,
            child: PopupMenuButton(
              padding: EdgeInsets.all(0),
                onSelected: (value) {
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
                    child: Text("Add",style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                    value: 0,
                  ),
                  PopupMenuItem(
                    child: Text("Edit",style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                    value: 1,
                  ),

                  // PopupMenuItem(
                  //   child: Text("Share"),
                  //   value: 2,
                  // ),
                  // PopupMenuItem(
                  //   child: Text("Import Contacts"),
                  //   value: 2,
                  // ),
                  // PopupMenuItem(
                  //   child: Text("Export Contacts"),
                  //   value: 2,
                  // ),
                ]
            ),
          ),
        ],
      ),
    );
  }

  void editPopup(ContactsController controller, {int key = -1, StateSetter setter, String address, String name}) {
    TextEditingController addressController = TextEditingController(
      text: key != -1 ? controller.contacts[key].address : address
    );
    TextEditingController nameController = TextEditingController(
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
                    LabelText("Address", fontSize: SizeConfig.fontSize*1.5,),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                AppTextFormField(
                  controller: addressController,
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
                    LabelText("Name", fontSize: SizeConfig.fontSize*1.5,),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                AppTextFormField(
                  controller: nameController,
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
                  height: SizeConfig.safeBlockVertical*3,
                ),
                Divider(),
                SizedBox(
                  height: SizeConfig.safeBlockVertical*3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppNeonButton(
                      expanded: false,
                      textStyle: TextStyle(fontSize: SizeConfig.fontSize*1.4),
                      onPressed: () => Navigator.of(context).pop(),
                      text: "Cancel"
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    AppButton(
                      expanded: false,
                      textStyle: TextStyle(fontSize: SizeConfig.fontSize*1.4),
                      onPressed: () {
                        if(_contactsForm.currentState != null && _contactsForm.currentState.validate())
                        {
                          setter((){
                            ///Update the contact
                            if(key != -1)
                            {
                              controller.updateContact(
                                key,
                                nameController.text,
                                addressController.text
                              );
                              NotificationBar().show(context, text:"Contact updated!");
                            }
                            ///Adds the contact
                            else
                            {
                              controller.addContact(
                                nameController.text,
                                addressController.text
                              );
                              NotificationBar().show(context, text:"Contact added!");
                            }
                          });
                          Navigator.of(context).pop();
                          cancel();
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
                //TODO: Remove this SizedBox?
                SizedBox(
                  height: 0,
                ),
              ],
            )
          )
      )
    );
  }

  Widget contactWidget(Contact contact, int position) {
    return GestureDetector(
      onTap: () {
        if(this.editMode)
          setState(() {
            if(this.checkerList.contains(position))
              this.checkerList.remove(position);
            else
              this.checkerList.add(position);
            this.selected = this.checkerList.length;
            editPopupEnabled = this.selected > 1 ? false : true;
          });
        else
          Share.share(
              "${contact.name} : ${contact.address}",
              subject: "Sharing \"${contact.address}\" address."
          );
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
                            value: this.checkerList.contains(position),
                            onChanged: (bool value) {},
                          ),
                        ),
                      )
                    ) : Container(),
                    Icon(
                      Icons.account_circle_outlined,
                      size: SizeConfig.titleSize*1.3,
                      color: AppColors.purple,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.name,
                              style: TextStyle(
                                  fontSize: SizeConfig.fontSizeLarge, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              contact.address,
                              style: TextStyle(
                                  fontSize: SizeConfig.fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
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
  }

  List<Widget> contactsList(Map<int,Contact> contacts)
  {
    List<Widget> ret = [];
    if(this.filter.isNotEmpty)
    {
      contacts.forEach((int key, Contact contact) {
        if(this.filter.contains(key))
        {
          if(this.filter.last == key){
            ret.add(
              contactWidget(contact, key)
            );
          }
          else
          {
            ret.add(
              Column(
                children: [
                  contactWidget(contact, key),
                  Divider()
                ],
              )
            );
          }
        }
      });
    }
    else
    {
      contacts.forEach((int key, Contact contact) {
        if(contacts.entries.last.value == contact)
        {
          ret.add(
              contactWidget(contact, key)
          );
        }
        else {
          ret.add(
              Column(
                children: [
                  contactWidget(contact, key),
                  Divider()
                ],
              )
          );
        }
      });
    }
    return ret;
  }

  Widget searchBar(Map<int, Contact> contacts)
  {
    return AppTextFormField(
      onChanged: (String typedText) {
        if(typedText.length > 0)
        {
          this.filter = [];
          contacts.forEach((int key,Contact contact) {
            RegExp inFilter = new RegExp(r''+typedText+'',multiLine: false, caseSensitive: false);
            if(inFilter.hasMatch(contact.name))
              return this.filter.add(key);
          });
        }
        else
          this.filter = [];
        setState((){});
      },
      icon: new Icon(Icons.search, color: AppColors.labelDefaultColor, size: 32,),
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

  void cancel() {
    this.editMode = false;
    this.checkerList = [];
    this.selected = 0;
    this.editPopupEnabled = true;
  }
}
