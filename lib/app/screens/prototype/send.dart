import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/labeltext.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../qrcode_reader.dart';

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
                  // iconOnTap: () => NotificationBar().show(context, text:"Opening the camera"),
                  iconOnTap: () async {
                    String response = await Navigator.push(context, MaterialPageRoute(builder: (context) => QRScanner()));
                    NotificationBar().show(context, text: "Scanned: \"$response\"");
                    setState(() {
                      addressController.text = response;
                    });
                  },
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
                onPressed: () => displaySendTokens(context),
              ),),
              Expanded(flex: 3, child: Container(),),
            ],
          ),
        )
      ]
    );
  }

  void displaySendTokens(BuildContext context)
  {
    NotificationBar().show(context, text:"Continuing to details screen");
    bool disableGasLimit = true;
    bool disableGasFee = true;
    TextEditingController gasLimit = TextEditingController(
      text: env["MAX_GAS"]
    );
    TextEditingController gasFee = TextEditingController(
      text: env["GAS_PRICE"]
    );
    showDialog(context: context, builder: (_) =>
      StatefulBuilder(builder: (builder, setState) =>
          AppPopupWidget(
              title: "SEND TOKENS",
              canClose: true,
              margin: EdgeInsets.all(8),
              cancelable: false,
              padding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 32
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Metacoin",
                          style: TextStyle(
                              fontSize: 18
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text("2",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 64),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text("\$ 128.35",
                          style: TextStyle(
                            fontSize: 18
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                      ],
                    )
                  ],
                ),

                /*Gas Limit*/

                Divider(color: Colors.white,),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            setState((){
                              disableGasLimit = !disableGasLimit;
                            });
                          },
                          child: Container(
                            color:Colors.transparent,
                            child: Row(
                              children: [
                                SizedBox(
                                  height:22,
                                  width:22,
                                  child: Checkbox(
                                    value: disableGasLimit,
                                    fillColor: MaterialStateProperty.resolveWith(getColor),
                                    onChanged: (bool value) => setState(() {
                                      disableGasLimit = value;
                                      if(value)
                                      {
                                        gasLimit.text = env["MAX_GAS"];
                                      }
                                    })
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:8.0),
                                  child: Text(
                                    "Automatic gas limit",
                                    style: TextStyle(
                                      fontSize: 12.0
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              "Gas limit in (WEI)",
                              style: TextStyle(
                                  fontSize: 12.0
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 2,
                      child: AppTextFormField(
                        enabled: !disableGasLimit,
                        controller: gasLimit,
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.number,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4
                        ),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                /*Recommended fees*/

                Divider(color: Colors.white,),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            setState((){
                              disableGasLimit = !disableGasLimit;
                            });
                          },
                          child: Container(
                            color:Colors.transparent,
                            child: Row(
                              children: [
                                SizedBox(
                                  height:22,
                                  width:22,
                                  child: Checkbox(
                                      value: disableGasFee,
                                      fillColor: MaterialStateProperty.resolveWith(getColor),
                                      onChanged: (bool value) => setState(() {
                                        disableGasFee = value;
                                        if(value)
                                        {
                                          gasFee.text = env["GAS_PRICE"];
                                        }
                                      })
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:8.0),
                                  child: Text(
                                    "Recommended fees",
                                    style: TextStyle(
                                        fontSize: 12.0
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              "Gas price (In GWEI)",
                              style: TextStyle(
                                  fontSize: 12.0
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 2,
                      child: AppTextFormField(
                        enabled: !disableGasFee,
                        controller: gasFee,
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.number,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4
                        ),
                        isDense: true,
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: AppButton(
                    expanded: false,
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    text: "CONFIRM",
                  ),
                )
              ],
              actions: []
          )
      )
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
