// @dart=2.12
import 'dart:math';

import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class ImportAccount extends StatefulWidget {
  const ImportAccount({Key? key}) : super(key: key);

  @override
  _ImportAccountState createState() => _ImportAccountState();
}

class _ImportAccountState extends State<ImportAccount> {

  FormMnemonic formMnemonic = FormMnemonic();
  int wrongMnemonic = -1;
  String warningMnemonic = " Oops, looks like you forgot to fill number ";

  @override
  Widget build(BuildContext context) {

    ScrollController write = ScrollController();
    String invalidMnemonic = '';

    SizeConfig().init(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.purpleVariant1,
                  AppColors.purpleBlue
                ]
            )
        ),
        child: Center(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.safeBlockHorizontal * 4,
                    ),
                    child: Card(
                      color: AppColors.cardBlue,
                      child: Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.safeBlockVertical * 4,
                              horizontal: SizeConfig.safeBlockVertical * 4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ///Header
                                Column(children: header(context),),
                                ///Fields
                                Column(
                                  children: [
                                    Text("Fill in mnemonic phrase below",style: AppTextStyles.spanWhite,),
                                    Text("to import an account",style: AppTextStyles.spanWhite,),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxHeight: SizeConfig.safeBlockVertical * 50
                                      ),
                                      child: Scrollbar(
                                          isAlwaysShown: true,
                                          thickness: 4,
                                          controller: write,
                                          child: SingleChildScrollView(
                                            controller: write,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 16),
                                                  child: formMnemonic.build(),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Text(invalidMnemonic,
                                                    style: TextStyle(color: Colors.red),),
                                                ),
                                                AppNeonButton(
                                                    onPressed: () async {
                                                      wrongMnemonic = formMnemonic.validate();
                                                      if(wrongMnemonic > -1)
                                                      {
                                                        setState((){
                                                          invalidMnemonic = warningMnemonic+(wrongMnemonic+1).toString();
                                                        });
                                                      }
                                                      else
                                                      {
                                                        setState((){
                                                          invalidMnemonic = "";
                                                        });
                                                        /*
                                                        Navigator.of(context).pop();
                                                        await showDialog(context: context, builder: (_) => StatefulBuilder(builder: (builder, setState){
                                                          return ProgressPopup(
                                                              title: "Creating",
                                                              future: appWalletManager.walletManager.makeAccount(phraseController.text, appWalletManager,mnemonic: this.walletSeed)
                                                                  .then((result) {
                                                                // Creates the user account
                                                                appWalletManager.changeCurrentWalletId = 0;
                                                                Navigator.pop(context);
                                                                Navigator.pushReplacementNamed(context, "app/overview");
                                                                NotificationBar().show(context, text: "Account #0 selected");
                                                              }));
                                                        }));
                                                         */
                                                        return;
                                                      }
                                                    },
                                                    expanded: false,
                                                    text: "IMPORT"
                                                ),
                                              ],
                                            ),
                                          )
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> header(BuildContext context)
  {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Close button
                GestureDetector(
                  child: Container(
                    color: Colors.transparent,
                    // color: Colors.red,
                    child: Icon(
                      Icons.arrow_back,
                      size: 32,
                      color: AppColors.labelDefaultColor,
                    ),
                  ),
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Text(
                    "Import Wallet",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: SizeConfig.titleSize)
                ),
              ],
            ),
          ),
          Expanded(child: Container(
            color: Colors.pink,
          ))
        ],
      ),
      Padding(
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.safeBlockVertical * 3,
        ),
        child: ScreenIndicator(
          height: 20,
          width: MediaQuery.of(context).size.width,
        ),
      ),];
  }



}

class FormMnemonic {

  //final String mnemonic;

  List<int> removedKeys = [];
  Map<int, String> mnemonicDict = {0:"bazinga",1:"ass",2:"cu",3:"aaaa"};
  Map<int, TextEditingController> mnemonicControlDict = {};

  FormMnemonic() {

    ///We're populating our dictionary of TextInputs and TextController to use later
    for(int i=0;i<24;i++)
    {
      removedKeys.add(i);
      mnemonicDict[i] = '';
      mnemonicControlDict[i] = new TextEditingController(
          text: ''
      );
    }
  }

  int validate()
  {
    int validated = -1;
    this.removedKeys.forEach((key) {
      print("${this.mnemonicControlDict[key]?.text} != ${this.mnemonicDict[key]}");
      if(this.mnemonicControlDict[key]?.text != this.mnemonicDict[key] && validated == -1)
        validated = key;
    });
    return validated;
  }

  Widget build()
  {
    Map<int,List<Widget>> columnMap = {};
    int column = 0;

    double paddingHorizontal = SizeConfig.safeBlockHorizontal * 2;
    EdgeInsets columnPadding = EdgeInsets.all(paddingHorizontal);
    this.mnemonicDict.forEach((key, value) {

      if(key.remainder(12) == 0 && key != 0)
        column++;

      columnMap[column] = columnMap[column] ?? [];
      columnMap[column]?.add(
        Padding(
          padding: column > 0 ? columnPadding.copyWith(left:paddingHorizontal) : columnPadding.copyWith(right:paddingHorizontal),
          child:Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(" ${key+1}.",
                    style: TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.labelSizeSmall
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.only(right:SizeConfig.safeBlockHorizontal * 4),
                    child: AppTextFormField(
                      enabled: this.removedKeys.contains(key),
                      controller: this.mnemonicControlDict[key],
                      textAlign: TextAlign.end,
                      // keyboardType: TextInputType.number,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                //
                // Expanded(
                //   child: TextField(
                //     controller: this.mnemonicControlDict[key],
                //     enabled: this.removedKeys.contains(key),
                //     style: TextStyle(
                //       color: Colors.white70,
                //       fontWeight: FontWeight.bold
                //     ),
                //     decoration: InputDecoration(
                //       floatingLabelBehavior: FloatingLabelBehavior.always,
                //       contentPadding: EdgeInsets.all(0),
                //       disabledBorder: UnderlineInputBorder(
                //         borderSide: BorderSide(color: Colors.grey, width: 1),
                //       ),
                //       enabledBorder: UnderlineInputBorder(
                //         borderSide: BorderSide(color: Colors.white, width: 2)
                //       ),
                //       labelStyle: TextStyle(
                //         color: AppColors.labelDefaultColor,
                //         fontWeight: FontWeight.w500,
                //         fontSize: 20
                //       ),
                //     )
                //   ),
                // ),
              ],
            ),
          ),
        ),
      );
      print("row[$column] ${key+1} - $value");
    });

    List<Widget> columnWidgets = [];
    columnMap.forEach((index,value) {
      columnWidgets.add(
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: value,
            ),
          )
      );
    });

    return Row(children: columnWidgets);
  }
}