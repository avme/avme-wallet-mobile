import 'dart:convert';

import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
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
import 'package:provider/provider.dart';

import '../qrcode_reader.dart';

class Send extends StatefulWidget {

  final TabController appScaffoldTabController;

  const Send({Key key, @required this.appScaffoldTabController}) : super(key: key);

  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {
  final _preTokenForm = GlobalKey<FormState>();
  final _sendTokenForm = GlobalKey<FormState>();

  int tokenDropdownValue = 0;
  //Todo: use an asset list with both id and label/short name
  // final List availableTokens = <String>[
  //   "Select Token",
  //   "AVAX",
  //   "AVME"
  // ];
  final Map availableTokens = <int,String>{
    0 : "Select Token",
    1 : "AVAX",
    2 : "AVME"
  };

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
    Color cLabelStyle = AppColors.labelDefaultColor;
    OutlineInputBorder fieldBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: BorderSide(
            width: 2
        )
    );
    return Form(
      key: _preTokenForm,
      child: ListView(
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
                    controller: addressController,
                    validator: (value) {
                      if (value.length != 42 || !isHex(value)) {
                        return 'This is not a valid address';
                      }
                      return null;
                    },
                    onChanged: (value){
                      // String value = addressController.text;
                      if(_preTokenForm.currentState != null)
                        _preTokenForm.currentState.validate();
                    },
                    icon: new Icon(Icons.qr_code_scanner, color: AppColors.labelDefaultColor, size: 32,),
                    // iconOnTap: () => NotificationBar().show(context, text:"Opening the camera"),
                    iconOnTap: () async {
                      String response = await Navigator.push(context, MaterialPageRoute(builder: (context) => QRScanner()));
                      NotificationBar().show(context, text: "Scanned: \"$response\"");
                      setState(() {
                        addressController.text = response;
                      });
                    },
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
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      value: tokenDropdownValue,
                      icon: new Icon(Icons.keyboard_arrow_down, color: AppColors.labelDefaultColor, size: 28,),
                      elevation: 16,
                      validator: (selected) {
                        if(selected == 0)
                        {
                          return "Please select a token";
                        }
                        return null;
                      },
                      onChanged: (int selectedValue){
                        setState(() {
                          tokenDropdownValue = selectedValue;
                        });
                        if(_preTokenForm.currentState != null)
                          _preTokenForm.currentState.validate();
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBlue,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12
                        ),
                        enabledBorder: fieldBorder.copyWith(
                          borderSide: BorderSide(
                            width: 2,
                            color: cLabelStyle,
                          ),
                        ),
                        errorBorder: fieldBorder.copyWith(
                            borderSide: BorderSide(
                              width: 2,
                              color: AppColors.labelDefaultColor,
                            )
                        ),
                      ),
                      items: availableTokens.entries.map<DropdownMenuItem<int>>((entry) {
                        return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value)
                        );
                      }).toList(),
                    )
                  ],
                ),
              )
          ),
          AppCard(
            child: GestureDetector(
              onTap: () => NotificationBar().show(context, text:"Not implemented."),
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
                        // Divider(color: AppColors.labelDisabledColor,),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Center(
                        //     child: LabelText("Work in progress"),
                        //   ),
                        // ),

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
                Expanded(flex: 2, child: AppButton(
                  text: 'CONTINUE',
                  onPressed: () {
                    if(_preTokenForm.currentState != null && _preTokenForm.currentState.validate())
                    {
                      displaySendTokens(context);
                    }
                  },
                ),),
                Expanded(flex: 3, child: Container(),),
              ],
            ),
          )
        ]
      ),
    );
  }

  void displaySendTokens(BuildContext context)
  {
    NotificationBar().show(context, text:"Continuing to details screen");
    bool disableGasLimit = true;
    bool disableGasFee = true;
    String convertedValue = "0";
    BigInt weiValue;
    TextEditingController gasLimit = TextEditingController(
      text: env["MAX_GAS"]
    );
    TextEditingController gasFee = TextEditingController(
      text: env["GAS_PRICE"]
    );
    TextEditingController amount = TextEditingController();
    showDialog(context: context, builder: (_) =>
      StatefulBuilder(builder: (builder, setState) =>
          Consumer<AvmeWallet>(
            builder: (context, app, _) =>
            Form(
              key: _sendTokenForm,
              child: AppPopupWidget(
                  title: "SEND TOKENS",
                  canClose: true,
                  margin: EdgeInsets.all(8),
                  cancelable: false,
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32
                  ),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(availableTokens[tokenDropdownValue],
                          style: TextStyle(
                              fontSize: 18
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                            cursorColor: AppColors.labelDefaultColor,
                            controller: amount,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.end,
                            onChanged: (String value){
                              setState((){
                                double newValue = 0;
                                if(value.length == 0 || value == null)
                                  return newValue;
                                //IS AVAX
                                if(tokenDropdownValue == 1)
                                {
                                  newValue = double.tryParse(value) * double.tryParse(app.metaCoin.value);
                                }
                                //IS AVME
                                else if (tokenDropdownValue == 2)
                                {
                                  newValue = double.tryParse(value) * double.tryParse(app.token.value);
                                }
                                convertedValue = shortAmount(newValue.toString(),comma: true,length: 3);
                                // weiValue = bigIntFixedPointToWei(newValue.toString().replaceAll(r",", "."));
                                if(_sendTokenForm.currentState != null)
                                  _sendTokenForm.currentState.validate();
                              });
                            },
                            validator: (String value){
                              // bigIntValue > appState.accountList[appState.currentWalletId].rawTokenBalance
                              weiValue = bigIntFixedPointToWei(value.replaceAll(r",", "."));
                              //IS AVAX
                              print("AVAX TOKEN:${app.currentAccount.balance}");
                              print("AVME TOKEN:${app.currentAccount.tokenBalance}");
                              if(tokenDropdownValue == 1 && (weiValue > app.currentAccount.waiBalance))
                                return "Not enough balance (AVAX)";
                              //IS AVME
                              else if(tokenDropdownValue == 2 && (weiValue > app.currentAccount.rawTokenBalance))
                                return "Not enough balance (AVME)";
                              else
                                return null;
                            },
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 64),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "0.50"
                            ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text("\$ $convertedValue",
                          style: TextStyle(
                            fontSize: 18
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
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
                                  if(disableGasLimit)
                                  {
                                    gasLimit.text = env["MAX_GAS"];
                                  }
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
                                  disableGasFee = !disableGasFee;
                                  if(disableGasFee)
                                  {
                                    gasFee.text = env["GAS_PRICE"];
                                  }
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
                      padding: const EdgeInsets.only(top: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppButton(
                            expanded: false,
                            onPressed: () {
                              // Navigator.of(context).pop();
                              if (_sendTokenForm.currentState != null && _sendTokenForm.currentState.validate()) {
                                startTransaction(app, weiValue);
                              }
                            },
                            text: "CONFIRM",
                          ),
                        ],
                      ),
                    )
                  ],
                  actions: []
              ),
            ),
          )
      )
    );
  }

  void startTransaction(AvmeWallet app, BigInt value) async {
    ValueNotifier <String> transactionStatus = ValueNotifier("1 - Starting Transaction");
    await showDialog(context: context, builder: (_) =>
      StatefulBuilder(builder: (builder, setState){
        return ProgressPopup(
          title: "Warning",
          labelNotifier: transactionStatus,
          future: app.walletManager.sendTransaction(app, addressController.text, value, notifier:transactionStatus)
            .then((response) {
              if(response["status"] == 200)
              {
                Navigator.of(context).pop();
              }
              print(jsonEncode(response));
          })
        );
      })
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
