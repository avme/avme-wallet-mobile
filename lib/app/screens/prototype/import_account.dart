// @dart=2.12
import 'dart:math';

import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bip39/bip39.dart' as bip39;

class ImportAccount extends StatefulWidget {
  const ImportAccount({Key? key}) : super(key: key);

  @override
  _ImportAccountState createState() => _ImportAccountState();
}

class _ImportAccountState extends State<ImportAccount> {
  //Code below generates 22 focusNodes, for all AppTextInputFields but the first and last
  late TextEditingController controller1;
  late TextEditingController controller2;
  late TextEditingController controllerMnemonic;
  late AvmeWallet appWalletManager;
  late FocusNode phraseFocusNode;
  late FocusNode rePhraseFocusNode;
  late ScrollController write;
  final _phraseFormState = GlobalKey<FormState>();
  final _rephraseFormState = GlobalKey<FormState>();
  String mnemonicString = '';
  EdgeInsets textFieldButtonPadding = new EdgeInsets.only(
    left: 12,
    top: 20,
    right: 42,
    bottom: 20,
  );

  bool swap = false;

  @override
  void initState() {
    super.initState();
    appWalletManager = Provider.of<AvmeWallet>(context, listen: false);
    controller1 = TextEditingController();
    controller2 = TextEditingController();
    controllerMnemonic = TextEditingController();
    phraseFocusNode = FocusNode();
    rePhraseFocusNode = FocusNode();
    write = ScrollController();
    phraseFocusNode.addListener(() {
      setState(() => null);
    });
    rePhraseFocusNode.addListener(() {
      setState(() => null);
    });
  }

  @override
  void dispose() {
    //dispose all focus nodes
    controller1.dispose();
    controller2.dispose();
    controllerMnemonic.dispose();
    phraseFocusNode.dispose();
    rePhraseFocusNode.dispose();
    super.dispose();
  }

  int wrongMnemonic = -1;
  bool isAllFilled = true;
  String invalidMnemonic = '';
  List<String> mnemonicDict = List.filled(24, '', growable: false);

  Widget createList() {
    Widget textBox;

    textBox = Container(
      width: SizeConfig.screenWidth / 2,
      child: AppTextFormField(
        controller: controllerMnemonic,
        minLines: 1,
        maxLines: 24,
        inputFormatters: [MaxLinesTextInputFormatter(24)],
      ),
    );

    return textBox;
  }

  /*
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
      //print("row[$column] ${key + 1} - ${this.mnemonicControlDict[key]?.text}");
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
  */

  List<dynamic> validate() {
    String response = controllerMnemonic.text.trim().replaceAll('\n', ' ');
    final regex = RegExp(r'\ +');
    String responseNew = response.replaceAll(regex, ' ');
    List<String> responseList = responseNew.split(' ');
    print('responseNew $responseNew');
    print('List response $responseList');
    print(
        'responseList.length ${responseList.length} -- ${responseList.length < 24}');
    if (controllerMnemonic.text == '' || responseList.length < 24) {
      print('test1');
      return [false, responseNew];
    } else {
      print('test2');
      return [true, responseNew];
    }
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

  Widget mnemonicScreen() {
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
                                  "Fill in mnemonic phrase to import an account.",
                                  style: AppTextStyles.spanWhite,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "Separate words with space or new line",
                                  style: AppTextStyles.spanWhite,
                                  textAlign: TextAlign.center,
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
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.span
                                              .copyWith(color: Colors.red),
                                        ),
                                      ),
                                AppNeonButton(
                                    onPressed: () async {
                                      List<dynamic> response = validate();
                                      bool validated = response[0];
                                      mnemonicString = response[1];
                                      print(
                                          'response: $validated, $mnemonicString');
                                      if (validated == false) {
                                        setState(() {
                                          invalidMnemonic =
                                              'One or more words are missing';
                                          isAllFilled = false;
                                        });
                                      } else {
                                        if (await appWalletManager.walletManager
                                            .checkMnemonic(
                                                phrase: mnemonicString,
                                                phraseCount: 24)) {
                                          swap = !swap;
                                          setState(() {});
                                        } else {
                                          print('what');
                                          setState(() {
                                            invalidMnemonic =
                                                'Words do not correspond to mnemonic dictionary';
                                            isAllFilled = false;
                                          });
                                        }
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

  Widget getSeedList() {
    Map<int, List<Widget>> columnMap = {};
    List<String> mnemonicDict = mnemonicString.split(' ');
    int row = 0, count = 1;

    mnemonicDict.forEach((element) {
      if (count == 13) row++;
      print('row $row');

      columnMap[row] = columnMap[row] ?? [];
      columnMap[row]!.add(Row(
        children: [
          Text(
            " $count. ",
            style: TextStyle(
                color: Colors.blue, fontSize: SizeConfig.fontSizeHuge),
          ),
          Text(
            element,
            style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: SizeConfig.fontSizeHuge),
          ),
        ],
      ));
      print("row[$row] $count - $element");
      count++;
    });

    List<Widget> columnWidgets = [];
    columnMap.values.forEach((value) {
      columnWidgets.add(Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: value.toList(),
        ),
      ));
    });

    return Row(
      children: columnWidgets,
    );
  }

  int maxCharacteresInsideTextField(BuildContext context) {
    // int size = (MediaQuery.of(context).size.width / 17).round();
    int size = (SizeConfig.safeBlockHorizontal * 8).round();
    return size;
  }

  Widget seedField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 1),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AppPopupWidget(
                        canClose: true,
                        title: "Review seed",
                        padding: EdgeInsets.only(
                            left: 32, right: 32, top: 16, bottom: 8),
                        cancelable: false,
                        children: [
                          Text('These were the words you typed previously',
                              style: TextStyle(
                                  fontSize:
                                      SizeConfig.fontSizeLarge * 0.5 + 8)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: SizeConfig.blockSizeVertical),
                            child: Divider(),
                          ),
                          getSeedList(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: SizeConfig.blockSizeVertical),
                            child: Divider(),
                          ),
                        ],
                        actions: [
                          AppNeonButton(
                            text: "Ok",
                            expanded: false,
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ]);
                  });
            },
            child: TextField(
                controller: new TextEditingController(
                    text: mnemonicString
                            .substring(
                                0, maxCharacteresInsideTextField(context))
                            .trim() +
                        "..."),
                enabled: false,
                cursorColor: AppColors.labelDefaultColor,
                decoration: InputDecoration(
                  disabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 2, color: Colors.grey[600]!)),
                  labelText: "Seed",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 2, color: AppColors.labelDefaultColor)),
                  labelStyle: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: SizeConfig.labelSize),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.white),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Form passPhrase(BuildContext context) {
    Icon phraseIcon = Icon(
      Icons.refresh,
      color: Colors.transparent,
    );
    return Form(
      key: _phraseFormState,
      child: Padding(
        padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 3),
        child: Stack(
          children: [
            TextFormField(
              validator: (string) {
                if (string!.length <= 5)
                  return "This field cannot be empty";
                else
                  return null;
              },
              controller: controller1,
              cursorColor: AppColors.labelDefaultColor,
              obscureText: true,
              focusNode: phraseFocusNode,
              onChanged: (string) {
                if (string.length > 5)
                  phraseIcon = new Icon(
                    Icons.done_sharp,
                    color: Colors.green,
                  );
                else
                  phraseIcon = new Icon(
                    Icons.close_rounded,
                    color: Colors.red,
                  );
                setState(() => null);
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.red)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2, color: AppColors.labelDefaultColor)),
                labelText: "Passphrase",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: textFieldButtonPadding,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: AppColors.labelDefaultColor,
                  ),
                ),
                labelStyle: TextStyle(
                    color: phraseFocusNode.hasFocus
                        ? Colors.white
                        : AppColors.labelDefaultColor,
                    fontWeight: phraseFocusNode.hasFocus
                        ? FontWeight.w900
                        : FontWeight.w500,
                    fontSize: SizeConfig.labelSize),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.white),
                ),
              ),
            ),
            Positioned.fill(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      // color: Color.fromRGBO(255, 50, 50, 0.2),
                      child: SizedBox(
                        // height: 12,
                        width: 48,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 48,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: phraseIcon,
                              ),
                            ),
                            SizedBox(
                              height: (_phraseFormState.currentState != null
                                  ? (_phraseFormState.currentState!
                                              .validate() ==
                                          true
                                      ? null
                                      : 20)
                                  : null),
                            )
                          ],
                        ),
                      ),
                    )))
          ],
        ),
      ),
    );
  }

  Form rePassphrase(BuildContext context) {
    Icon rePhraseIcon = Icon(
      Icons.refresh,
      color: Colors.transparent,
    );
    return Form(
      key: _rephraseFormState,
      child: Padding(
        padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 3),
        child: Stack(
          children: [
            TextFormField(
              validator: (string) {
                if (string == controller1.text)
                  return null;
                else
                  return "Passphrases don't match";
              },
              controller: controller2,
              cursorColor: AppColors.labelDefaultColor,
              obscureText: true,
              focusNode: rePhraseFocusNode,
              onChanged: (string) {
                // print("${this.phraseController.text} | $string");
                if (string.length > 5 && string == controller1.text)
                  rePhraseIcon = new Icon(
                    Icons.done_sharp,
                    color: Colors.green,
                  );
                else
                  rePhraseIcon = new Icon(
                    Icons.close_rounded,
                    color: Colors.red,
                  );
                setState(() => null);
              },
              decoration: InputDecoration(
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.red)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2, color: AppColors.labelDefaultColor)),
                labelText: "Confirm passphrase",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2, color: AppColors.labelDefaultColor)),
                labelStyle: TextStyle(
                    color: rePhraseFocusNode.hasFocus
                        ? Colors.white
                        : AppColors.labelDefaultColor,
                    fontWeight: rePhraseFocusNode.hasFocus
                        ? FontWeight.w900
                        : FontWeight.w500,
                    fontSize: SizeConfig.labelSize),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.white),
                ),
              ),
              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            ),
            Positioned.fill(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 48,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: rePhraseIcon,
                            ),
                          ),
                          SizedBox(
                            height: (_rephraseFormState.currentState != null
                                ? (_rephraseFormState.currentState!
                                            .validate() ==
                                        true
                                    ? null
                                    : 20)
                                : null),
                          )
                        ],
                      ),
                    )))
          ],
        ),
      ),
    );
  }

  AppButton createAccount() {
    return AppButton(
      onPressed: () async {
        if (_phraseFormState.currentState!.validate() == true &&
            _rephraseFormState.currentState!.validate() == true) {
          FocusScopeNode currentFocus = FocusScope.of(this.context);
          currentFocus.unfocus();
          //create account outright .makeaccount thing
          await showDialog(
              context: context,
              builder: (_) => StatefulBuilder(builder: (builder, setState) {
                    return ProgressPopup(
                        title: "Creating",
                        future: appWalletManager.walletManager
                            .makeAccount(controller1.text, appWalletManager,
                                mnemonic: mnemonicString)
                            .then((result) {
                          // Creates the user account
                          appWalletManager.changeCurrentWalletId = 0;
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(
                              context, "app/overview");
                          NotificationBar()
                              .show(context, text: "Account #0 selected");
                        }));
                  }));
        }
      },
      text: 'CREATE ACCOUNT',
      expanded: false,
    );
  }

  Widget passwordScreen() {
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
                                ///Seed Phrase
                                seedField(context),

                                ///Passphrase
                                passPhrase(context),

                                ///Confirm Passphrase
                                rePassphrase(context),
                                SizedBox(
                                  height: SizeConfig.safeBlockVertical * 4,
                                ),
                                createAccount(),
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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return swap ? passwordScreen() : mnemonicScreen();
  }
}

class MaxLinesTextInputFormatter extends TextInputFormatter {
  MaxLinesTextInputFormatter(this._maxLines)
      : assert(_maxLines == -1 || _maxLines > 0);

  final int _maxLines;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    if (_maxLines > 0) {
      final regEx = RegExp("^.*((\n?.*){0,${_maxLines - 1}})");
      final newString = regEx.stringMatch(newValue.text) ?? "";
      final maxLength = newString.length;
      if (newValue.text.runes.length > maxLength) {
        final newSelection = newValue.selection.copyWith(
          baseOffset: min(newValue.selection.start, maxLength),
          extentOffset: min(newValue.selection.end, maxLength),
        );
        final iterator = RuneIterator(newValue.text);
        if (iterator.moveNext()) {
          for (var count = 0; count < maxLength; ++count) {
            if (!iterator.moveNext()) break;
          }
        }
        final truncated = newValue.text.substring(0, iterator.rawIndex);
        return TextEditingValue(
          text: truncated,
          selection: newSelection,
          composing: TextRange.empty,
        );
      }
      return newValue;
    }
    return newValue;
  }
}
