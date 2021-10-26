import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List<Map<String, String>> contacts = [
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
    },
    {
      "name": "User Four",
      "address": "0x4214496147525148769976fb554a8388117e25b1"
    },
    {
      "name": "User Five",
      "address": "0x4214496147525148769976fb554a8388117e25b1"
    },
    {
      "name": "User Six",
      "address": "0x4214496147525148769976fb554a8388117e25b1"
    },
    {
      "name": "User Seven",
      "address": "0x4214496147525148769976fb554a8388117e25b1"
    },
    {
      "name": "User Eight",
      "address": "0x4214496147525148769976fb554a8388117e25b1"
    },
    {
      "name": "User Nine",
      "address": "0x4214496147525148769976fb554a8388117e25b1"
    },
    {
      "name": "User Ten",
      "address": "0x4214496147525148769976fb554a8388117e25b1"
    },
  ];

  List<Map<String, String>> filtered = [];
  bool editingMode = false;
  // String filter = "";

  @override
  Widget build(BuildContext context) {
    EdgeInsets buttonPadding = EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 8
    );
    return ListView(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelText("Contacts"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: searchBar(),
              ),
              this.editingMode ? Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(child: Text("0 Selected"))
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton(
                            onPressed: (){},
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
                          AppButton(
                            onPressed: (){},
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
                            onPressed: (){},
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
                    NotificationBar().show(context, text: "Entering Editing mode");

                    setState(() {
                      this.editingMode = true;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
                        child:
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length == 0 ? contacts.length : filtered.length,
                          itemBuilder: (BuildContext context, index){
                            List contactList = filtered.length == 0 ? contacts : filtered;
                            final contact = contactList[index];
                            if(contactList.length > (index + 1))
                              return Column(
                                children: [
                                  contactWidget(contact),
                                  Divider(color: AppColors.labelDisabledColor,)
                                ],
                              );
                            return contactWidget(contact);
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

  Widget contactWidget(Map<String, String> contact) {
    // return Row(
    //   children: [
    //     Text(contact["name"]),
    //     Text(contact["address"]),
    //   ],
    // );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                editingMode ? Container(
                  // color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.only(right:6.0),
                    child: SizedBox(
                      height: 48,
                      width: 24,
                      child: Checkbox(
                        value: false,
                        onChanged: (value) {},

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
                        Text(contact["name"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        Text(contact["address"], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),),
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
    );
    // Divider(color: AppColors.labelDisabledColor,),
  }

  Widget searchBar()
  {
    return AppTextFormField(
      onChanged: (String filter) {
        if(filter.length > 0)
        {
          this.filtered = [];
          contacts.forEach((contact) {
            RegExp inFilter = new RegExp(r''+filter+'',multiLine: false, caseSensitive: false);
            if(inFilter.hasMatch(contact["name"]))
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
}
