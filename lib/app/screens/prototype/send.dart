import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/labeltext.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class Send extends StatefulWidget {

  final TabController appScaffoldTabController;

  const Send({Key key, @required this.appScaffoldTabController}) : super(key: key);

  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {
  String tokenDropdownValue = "Select Token";
  final _addressForm = GlobalKey<FormState>();
  TextEditingController addressController = new TextEditingController();
  FocusNode phraseFocusNode = new FocusNode();
  EdgeInsets textFieldButtonPadding = new EdgeInsets.only(
    left: 12,
    top: 20,
    right: 42,
    bottom:20,
  );

  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom:8.0),
                  child: AppLabelText("Address",),
                ),
                AppTextFormField(
                  key: _addressForm,
                  controller: addressController,
                  icon: new Icon(Icons.qr_code_scanner, color: AppColors.labelDefaultColor, size: 32,),
                  iconOnTap: () => NotificationBar().show(context, text:"Opening the camera"),
                  // labelText: "Dance floor baby",
                ),
              ],
            ),
          ),
        ),
        AppCard(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom:8.0),
                    child: AppLabelText("Available Tokens",),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.darkBlue,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                            width: 2,
                            color: AppColors.labelDefaultColor
                        )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: tokenDropdownValue,
                        icon: new Icon(Icons.keyboard_arrow_down, color: AppColors.labelDefaultColor, size: 40,),
                        elevation: 16,
                        style: const TextStyle(color: Colors.white),
                        underline: Container(
                          height:0,
                        ),

                        onChanged: (String value){
                          setState(() {
                            tokenDropdownValue = value;
                          });
                        },
                        items: <String>[
                          "Select Token",
                          "AVAX",
                          "AVME"
                        ].map<DropdownMenuItem<String>>((String value) =>
                            DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            )
                        ).toList(),
                      ),
                    ),
                  )
                ],
              ),
            )
        ),
        AppCard(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.darkBlue
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 14
              ),
              //Todo: Create an proper "address book"
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.account_circle_outlined, size: 32,),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text("Address book", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
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
              )
            ),
          ),
        ),
        AppCard(
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 12.0,
                    bottom: 20,
                    left: 16.0
                ),
                child: Text("Frequents", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.darkBlue
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      //TODO: Add last users/recordings/registered
                      /*1*/
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.account_circle_outlined, size: 32, color: AppColors.purple,),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text("Cleverson", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
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
                      Divider(color: AppColors.labelDisabledColor,),

                      /*2*/
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.account_circle_outlined, size: 32, color: AppColors.purple,),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text("Guilherme", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
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
                      Divider(color: AppColors.labelDisabledColor,),

                      /*3*/
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.account_circle_outlined, size: 32, color: AppColors.purple,),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text("Itamar", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
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
                    ],
                  )
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            bottom: 32.0
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: Container(),),
              Expanded(flex: 2,child: AppButton(
                text: 'CONTINUE',
                onPressed: () => NotificationBar().show(context, text:"Continuing to details screen"),
              ),),
              Expanded(flex: 3, child: Container(),),
            ],
          ),
        )
      ]
    );
  }
}
