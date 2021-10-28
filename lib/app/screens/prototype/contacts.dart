import 'package:avme_wallet/app/controller/contacts.dart';
import 'package:avme_wallet/app/model/contacts.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {

  List<Contact> filtered = [];
  List<bool> checkerList = [];
  bool editingMode = false;
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
                    child: Text("Contacts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: searchBar(controller),
                  ),
                  this.editingMode ? Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
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
                                  onPressed: (){
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
                                    this.editingMode = !this.editingMode;
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
                          if(!this.editingMode && controller.contacts.length > 0)
                          {
                            NotificationBar().show(context, text: "Entering Editing mode");
                            setState(() {
                              this.editingMode = true;
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

  Widget contactWidget(Contact contact, int position) {
    return GestureDetector(
      onTap: (){
        if(this.editingMode)
          setState(() {
            this.checkerList[position] = !checkerList[position];
            this.selected = 0;
            this.checkerList.forEach((selected) {
              if(selected)
                this.selected++;
            });
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
                    this.editingMode ? Container(
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
