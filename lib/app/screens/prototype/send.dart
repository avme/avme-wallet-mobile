import 'dart:convert';

import 'package:avme_wallet/app/controller/services/contract.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/active_contracts.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/labeltext.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  String tokenDropdownValue = "Select a Token";
  //Todo: use an asset list with both id and label/short nam
  List<String> availableTokens = ["Select a Token"];

  TextEditingController addressController = new TextEditingController();
  FocusNode phraseFocusNode = new FocusNode();
  EdgeInsets textFieldButtonPadding = new EdgeInsets.only(
    //There is another declaration of textFieldButtonPadding in new_account.dart
    //but this one in send.dart is never used
    left: 12,
    top: 20,
    right: 42,
    bottom:20,
  );

  ActiveContracts activeContracts;

  @override
  void initState() {
    activeContracts = Provider.of<ActiveContracts>(context, listen: false);
    availableTokens.addAll(activeContracts.tokens);
    print(availableTokens);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);

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
              padding: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical*2,horizontal: SizeConfig.safeBlockHorizontal*2), //all 18
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom:8.0),
                    child: AppLabelText("Address",),
                  ),
                  AppTextFormField(
                    controller: addressController,
                    hintText: '0x4214496147525148769976fb554a8388117e25b1',
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
                padding: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical*2,horizontal: SizeConfig.safeBlockHorizontal*2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom:8.0),
                      child: AppLabelText("Available Tokens",),
                    ),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: tokenDropdownValue,
                      icon: new Icon(Icons.keyboard_arrow_down, color: AppColors.labelDefaultColor, size: 28,),
                      elevation: 16,
                      validator: (String selected) {
                        if(selected == "Select a Token")
                        {
                          return "Please select a token";
                        }
                        return null;
                      },
                      onChanged: (String selectedValue){
                        tokenDropdownValue = selectedValue;
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
                      items: availableTokens.map<DropdownMenuItem<String>>((value) {
                          if(value != availableTokens.first)
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right:SizeConfig.safeBlockVertical * 1.5),
                                    child: resolveImage(activeContracts.sContracts.contractsRaw[value]["logo"], width: SizeConfig.safeBlockVertical * 3.5),
                                  ),
                                  Text(value, style: AppTextStyles.label,),
                                ],
                              ),
                            );
                          else
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                        }
                      ).toList()
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
                  //Todo: Implement "address/contact list"
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
                        Divider(),

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
                        Divider(),

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
                Expanded(flex: 2, child: Container(),),
                Expanded(flex: 2, child: AppButton(
                  text: 'CONTINUE',
                  onPressed: () {
                    if(_preTokenForm.currentState != null && _preTokenForm.currentState.validate())
                    {
                      displaySendTokens(context);
                    }
                  },
                ),),
                Expanded(flex: 2, child: Container(),),
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
                scrollable: true,
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
                      Text(availableTokens.firstWhere((element) => element == tokenDropdownValue),
                        style: TextStyle(
                          fontSize: SizeConfig.labelSize*0.5+6
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical,
                      ),
                      TextFormField(
                        cursorColor: AppColors.labelDefaultColor,
                        controller: amount,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.end,
                        onChanged: (String value){
                          setState((){
                            if(double.tryParse(value) != null && double.tryParse(value) > 0)
                            {
                              double newValue = 0;
                              if(value.length == 0 || value == null)
                                return newValue;
                              //IS AVAX
                              if(tokenDropdownValue == 1)
                              {
                                newValue = double.tryParse(value) * double.tryParse(app.networkToken.value);
                              }
                              //IS AVME
                              else if (tokenDropdownValue == 2)
                              {
                                newValue = double.tryParse(value) * double.tryParse(app.activeContracts.token.tokenValues[tokenDropdownValue]);
                              }
                              convertedValue = shortAmount(newValue.toString(),comma: true,length: 3);
                              // weiValue = bigIntFixedPointToWei(newValue.toString().replaceAll(r",", "."));
                              if(_sendTokenForm.currentState != null)
                                _sendTokenForm.currentState.validate();
                            }
                            else
                            {
                              convertedValue = "0";
                            }
                          });
                        },
                        validator: (String value){
                          if(double.tryParse(value) != null && double.tryParse(value) > 0)
                          {
                            weiValue = bigIntFixedPointToWei(value.replaceAll(r",", "."));
                            //IS AVAX
                            print("AVAX TOKEN:${app.currentAccount.balance}");
                            print("AVME TOKEN:${app.currentAccount.tokenBalance}");
                            if(tokenDropdownValue == 1 && (weiValue > app.currentAccount.waiBalance))
                              return "Not enough balance (AVAX)";
                            //IS AVME
                            else if(tokenDropdownValue == 2 && (weiValue > app.currentAccount.rawTokenBalance))
                              return "Not enough balance (AVME)";
                          }
                          else if (double.tryParse(value) == null)
                          {
                            if(tokenDropdownValue == 1)
                              return "Not enough balance (AVAX)";
                            else if(tokenDropdownValue == 2)
                              return "Not enough balance (AVME)";
                          }
                          return null;
                        },
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: SizeConfig.titleSize*2.2),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "0.50"
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical,
                      ),
                      Text("\$ $convertedValue",
                        style: TextStyle(
                            fontSize: SizeConfig.titleSize*0.7
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical,
                      ),
                    ],
                  ),
                  /*Gas Limit*/
                  Divider(),
                  Padding(
                    padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical*2, bottom: SizeConfig.safeBlockVertical),
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
                    height: SizeConfig.safeBlockVertical*2,
                  ),
                  /*Recommended fees*/
                  Divider(),
                  Padding(
                    padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical*2, bottom: SizeConfig.safeBlockVertical),
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
                    padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical*4),
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
    ValueNotifier<int> percentage = ValueNotifier(10);
    ValueNotifier<String> label = ValueNotifier("Starting Transaction");
    List<ValueNotifier> loadingNotifier = [
      percentage,
      label
    ];
    await showDialog(context: context, builder: (_) =>
      StatefulBuilder(builder: (builder, setState){
        return ProgressPopup(
          title: "Warning",
          listNotifier: loadingNotifier,
          future: app.walletManager.sendTransaction(app, addressController.text, value, tokenDropdownValue, listNotifier:loadingNotifier)
            .then((response) async{
              if(response["status"] == 200)
              {
                Navigator.of(context).pop();
                await Future.delayed(Duration(milliseconds: 250));
                displayTransactionHash(response["message"]);
              }
              else
                Navigator.of(context).pop();
          })
        );
      })
    );
  }

  void displayTransactionHash(String message)
  {
    showDialog(context:context, builder: (_) =>
      AppPopupWidget(
        title: "Transaction done",
        cancelable: false,
        canClose: true,
        showIndicator: false,
        children: [
          AppButton(onPressed: () async{
            print(message);
            NotificationBar().show(context,text: "Opening in browser $message");
            Navigator.of(context).pop();
            await Future.delayed(Duration(seconds: 2));
            if(await canLaunch(message))
              await launch(message);
            else
            {
              NotificationBar().show(context,text: "cant launch url $message");
              print("cant launch url $message");
            }

          }, text: "Open on Browser")
        ]
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
