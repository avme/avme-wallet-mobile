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
  //Code below generates 22 focusNodes, for all AppTextInputFields but the first and last
  late List<FocusNode> focusNodes;
  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(23, (index) => FocusNode());
    FormMnemonic();
  }

  @override
  void dispose() {
    //dispose all focus nodes
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  int wrongMnemonic = -1;
  bool isAllFilled = true;
  String invalidMnemonic = '';

  List<int> removedKeys = [];
  Map<int, String> mnemonicDict = {};
  Map<int, TextEditingController> mnemonicControlDict = {};

  FormMnemonic() {
    ///We're populating our dictionary of TextInputs and TextController to use later
    for (int i = 0; i < 24; i++) {
      removedKeys.add(i);
      mnemonicDict[i] = '';
      mnemonicControlDict[i] = new TextEditingController(text: '');
    }
  }

  Widget createList() {
    Map<int, List<Widget>> columnMap = {};
    int column = 0;

    double paddingHorizontal = SizeConfig.safeBlockHorizontal * 2;
    EdgeInsets columnPadding = EdgeInsets.all(paddingHorizontal);

    Function(String) onFieldSubmitted;
    FocusNode? focusNodeInput;

    this.mnemonicDict.forEach((key, value) {
      if (key.remainder(12) == 0 && key != 0) column++;

      if (key == 0) {
        focusNodeInput = null;
        onFieldSubmitted =
            (_) => FocusScope.of(context).requestFocus(focusNodes[key]);
      } else if (key == 23) {
        focusNodeInput = focusNodes[key - 1];
        onFieldSubmitted = (_) {};
      } else {
        focusNodeInput = focusNodes[key - 1];
        onFieldSubmitted =
            (_) => FocusScope.of(context).requestFocus(focusNodes[key]);
      }

      columnMap[column] = columnMap[column] ?? [];
      columnMap[column]?.add(
        Padding(
          padding: column > 0
              ? columnPadding.copyWith(left: paddingHorizontal)
              : columnPadding.copyWith(right: paddingHorizontal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "${key + 1}.",
                  style: TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.labelSizeSmall),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.only(
                      right: SizeConfig.safeBlockHorizontal * 4),
                  child: AppTextFormField(
                    focusNode: focusNodeInput,
                    enabled: this.removedKeys.contains(key),
                    controller: this.mnemonicControlDict[key],
                    textAlign: TextAlign.end,
                    // keyboardType: TextInputType.number,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    isDense: true,
                    onFieldSubmitted: onFieldSubmitted,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      print("row[$column] ${key + 1} - ${this.mnemonicControlDict[key]?.text}");
    });

    List<Widget> columnWidgets = [];
    columnMap.forEach((index, value) {
      columnWidgets.add(Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: value,
        ),
      ));
    });

    return Row(children: columnWidgets);
  }

  int validate() {
    int validated = 0;
    this.removedKeys.forEach((key) {
      print("${this.mnemonicControlDict[key]?.text} != (null)");
      if (this.mnemonicControlDict[key]?.text != '') ++validated;
      print('validated $validated');
    });
    return validated;
  }

  @override
  Widget build(BuildContext context) {
    ScrollController write = ScrollController();

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
            ])),
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
                            Column(
                              children: header(context),
                            ),

                            ///Fields
                            Column(
                              children: [
                                Text(
                                  "Fill in mnemonic phrase",
                                  style: AppTextStyles.spanWhite,
                                ),
                                Text(
                                  "to import an account",
                                  style: AppTextStyles.spanWhite,
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxHeight:
                                          SizeConfig.safeBlockVertical * 50),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom:
                                            SizeConfig.blockSizeVertical * 2),
                                    child: Scrollbar(
                                        isAlwaysShown: true,
                                        thickness: 4,
                                        controller: write,
                                        child: SingleChildScrollView(
                                          controller: write,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 16),
                                                child: createList(),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ),
                                ),
                                isAllFilled
                                    ? Padding(
                                        padding: const EdgeInsets.all(0),
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          invalidMnemonic,
                                          style: AppTextStyles.span
                                              .copyWith(color: Colors.red),
                                        ),
                                      ),
                                AppNeonButton(
                                    onPressed: () async {
                                      if (validate() != 24) {
                                        setState(() {
                                          invalidMnemonic =
                                              'Oops, looks like you forgot to fill a field';
                                          isAllFilled = false;
                                        });
                                      } else {
                                        setState(() {
                                          invalidMnemonic = '';
                                          isAllFilled = true;
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
                                    text: "IMPORT"),
                              ],
                            )
                          ],
                        ),
                      )),
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

  List<Widget> header(BuildContext context) {
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
                  onTap: () {
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
                Text("Import Wallet",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.titleSize)),
              ],
            ),
          ),
          Expanded(
              child: Container(
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
      ),
    ];
  }
}
