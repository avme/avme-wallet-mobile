// @dart=2.12
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/authentication.dart';
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

import '../../controller/authapi.dart';
import '../../controller/file_manager.dart';
import 'import_account.dart';
import 'import_account_tile.dart';

class ImportAccountTile extends StatefulWidget {
  const ImportAccountTile({Key? key}) : super(key: key);

  @override
  _ImportAccountTileState createState() => _ImportAccountTileState();
}

class _ImportAccountTileState extends State<ImportAccountTile> {
  //Code below generates 22 focusNodes, for all AppTextInputFields but the first and last
  late List<FocusNode> focusNodes;
  late TextEditingController controller1, controller2;
  late AvmeWallet appWalletManager;
  late FocusNode phraseFocusNode, rePhraseFocusNode;
  late ScrollController write;
  final _phraseFormState = GlobalKey<FormState>();
  final _rephraseFormState = GlobalKey<FormState>();
  late AuthApi _authApi;
  bool swap = false;

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(23, (index) => FocusNode());
    appWalletManager = Provider.of<AvmeWallet>(context, listen: false);
    controller1 = TextEditingController();
    controller2 = TextEditingController();
    phraseFocusNode = FocusNode();
    rePhraseFocusNode = FocusNode();
    write = ScrollController();
    authSetup();
    formMnemonic();
  }

  @override
  void dispose() {
    //dispose all focus nodes
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  int wrongMnemonic = -1, _dropValue = 12;
  bool isAllFilled = true;
  String invalidMnemonic = '', mnemonicString = '';

  EdgeInsets textFieldButtonPadding = new EdgeInsets.only(
    left: 12,
    top: 20,
    right: 42,
    bottom: 20,
  );

  List<DropdownMenuItem<int>> _dropList = <int>[12, 24].map<DropdownMenuItem<int>>((int value) {
    return DropdownMenuItem<int>(
      child: Center(
        child: Text(
          value.toString(),
          textAlign: TextAlign.center,
        ),
      ),
      value: value,
    );
  }).toList();

  List<int> removedKeys = [];
  Map<int, String> mnemonicDict = {};
  Map<int, TextEditingController> mnemonicControlDict = {};

  Future<void> authSetup() async => _authApi = await AuthApi.init();

  void formMnemonic() {
    ///We're populating our dictionary of TextInputs and TextController to use later
    for (int i = 0; i < 24; i++) {
      removedKeys.add(i);
      mnemonicDict[i] = '';
      mnemonicControlDict[i] = new TextEditingController(text: '');
    }
  }

  Widget createList(int length) {
    Map<int, List<Widget>> columnMap = {};
    int column = 0;

    double paddingHorizontal = SizeConfig.safeBlockHorizontal * 2;
    EdgeInsets columnPadding = EdgeInsets.all(paddingHorizontal);

    Function(String) onFieldSubmitted;
    FocusNode? focusNodeInput;
    bool doColumn = false;

    this.mnemonicDict.forEach((key, value) {
      if (length == 24) {
        if (key.remainder(12) == 0 && key != 0) column++;

        if (key == 0) {
          focusNodeInput = null;
          onFieldSubmitted = (_) => FocusScope.of(context).requestFocus(focusNodes[key]);
        } else if (key == 23) {
          focusNodeInput = focusNodes[key - 1];
          onFieldSubmitted = (_) {};
        } else {
          focusNodeInput = focusNodes[key - 1];
          onFieldSubmitted = (_) => FocusScope.of(context).requestFocus(focusNodes[key]);
        }
        doColumn = true;
      } else {
        if (key.remainder(6) == 0 && key != 0) column++;

        if (key == 0) {
          focusNodeInput = null;
          onFieldSubmitted = (_) => FocusScope.of(context).requestFocus(focusNodes[key]);
        } else if (key == 11) {
          focusNodeInput = focusNodes[key - 1];
          onFieldSubmitted = (_) {};
        } else {
          focusNodeInput = focusNodes[key - 1];
          onFieldSubmitted = (_) => FocusScope.of(context).requestFocus(focusNodes[key]);
        }
        if (key < 12)
          doColumn = true;
        else
          doColumn = false;
      }
      if (doColumn) {
        columnMap[column] = columnMap[column] ?? [];
        columnMap[column]?.add(
          Padding(
            padding: column > 0 ? columnPadding.copyWith(left: paddingHorizontal) : columnPadding.copyWith(right: paddingHorizontal),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "${key + 1}.",
                    style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold, fontSize: SizeConfig.labelSizeSmall),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.only(right: SizeConfig.safeBlockHorizontal * 4),
                    child: AppTextFormField(
                      focusNode: focusNodeInput,
                      enabled: this.removedKeys.contains(key),
                      controller: this.mnemonicControlDict[key],
                      textAlign: TextAlign.end,
                      // keyboardType: TextInputType.number,
                      contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      isDense: true,
                      onFieldSubmitted: onFieldSubmitted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // print("row[$column] ${key + 1} - ${this.mnemonicControlDict[key]?.text}");
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
    mnemonicString = '';
    int validated = 0;
    if (_dropValue == 12) {
      for (int i = 0; i < 12; i++) {
        print("${this.mnemonicControlDict[i]?.text} != (null)");
        if (this.mnemonicControlDict[i]?.text != '') ++validated;
        mnemonicString += '${this.mnemonicControlDict[i]!.text} ';
        print('validated $validated');
      }
    } else {
      this.removedKeys.forEach((key) {
        print("${this.mnemonicControlDict[key]?.text} != (null)");
        if (this.mnemonicControlDict[key]?.text != '') ++validated;
        mnemonicString += '${this.mnemonicControlDict[key]!.text} ';
        print('validated $validated');
      });
    }
    mnemonicString = mnemonicString.trim().replaceAll('\n', ' ');
    final regex = RegExp(r'\ +');
    mnemonicString = mnemonicString.replaceAll(regex, ' ');
    return validated;
  }

  void dropChange(dynamic value) {
    if (value != _dropValue) {
      setState(() {
        _dropValue = value;
        NotificationBar().show(context, text: "Changed to $_dropValue mnemonic length");
      });
    }
  }

  //--

  Widget getSeedList() {
    Map<int, List<Widget>> columnMap = {};
    List<String> mnemonicDict = mnemonicString.split(' ');
    int row = 0, count = 1;

    if (mnemonicDict.length == 12) {
      mnemonicDict.forEach((element) {
        if (count == 7) row++;
        print('row $row');

        columnMap[row] = columnMap[row] ?? [];
        columnMap[row]!.add(Row(
          children: [
            Text(
              " $count. ",
              style: TextStyle(color: Colors.blue, fontSize: SizeConfig.fontSizeHuge),
            ),
            Text(
              element,
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: SizeConfig.fontSizeHuge),
            ),
          ],
        ));
        print("row[$row] $count - $element");
        count++;
      });
    } else {
      mnemonicDict.forEach((element) {
        if (count == 13) row++;
        print('row $row');

        columnMap[row] = columnMap[row] ?? [];
        columnMap[row]!.add(Row(
          children: [
            Text(
              " $count. ",
              style: TextStyle(color: Colors.blue, fontSize: SizeConfig.fontSizeHuge),
            ),
            Text(
              element,
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: SizeConfig.fontSizeHuge),
            ),
          ],
        ));
        print("row[$row] $count - $element");
        count++;
      });
    }

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

  void handlePaste() async {
    final ClipboardData? _data = await Clipboard.getData('text/plain');
    if (_data != null || _data!.text != '') {
      //
      String _mnemonicTemp = _data.text!;
      _mnemonicTemp = _mnemonicTemp.trim().replaceAll('\n', ' ');
      final regex = RegExp(r'\ +');
      _mnemonicTemp = _mnemonicTemp.replaceAll(regex, ' ');
      if (await appWalletManager.walletManager.checkMnemonic(phrase: _mnemonicTemp, phraseCount: _dropValue)) {
        print('good');
        List<String> _mnemonicList = _mnemonicTemp.split(' ');
        for (int i = 0; i < _dropValue; i++) {
          this.mnemonicControlDict[i]!.text = _mnemonicList[i];
        }
      } else {
        NotificationBar().show(context, text: "Invalid Mnemonic");
      }
    }
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
                        padding: EdgeInsets.only(left: 32, right: 32, top: 16, bottom: 8),
                        cancelable: false,
                        children: [
                          Text('These were the words you typed previously', style: TextStyle(fontSize: SizeConfig.fontSizeLarge * 0.5 + 8)),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical),
                            child: Divider(),
                          ),
                          getSeedList(),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical),
                            child: Divider(),
                          ),
                        ],
                        actions: [
                          AppNeonButton(
                            textStyle: TextStyle(color: Colors.white, fontSize: SizeConfig.spanSize * 1.6),
                            text: "OK",
                            expanded: false,
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ]);
                  });
            },
            child: TextField(
                controller: new TextEditingController(text: mnemonicString.substring(0, maxCharacteresInsideTextField(context)).trim() + "..."),
                enabled: false,
                cursorColor: AppColors.labelDefaultColor,
                decoration: InputDecoration(
                  disabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Colors.grey[600]!)),
                  labelText: "Seed",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(borderSide: BorderSide(width: 2, color: AppColors.labelDefaultColor)),
                  labelStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: SizeConfig.labelSize),
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
                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Colors.red)),
                errorBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: AppColors.labelDefaultColor)),
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
                    color: phraseFocusNode.hasFocus ? Colors.white : AppColors.labelDefaultColor,
                    fontWeight: phraseFocusNode.hasFocus ? FontWeight.w900 : FontWeight.w500,
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
                              height:
                                  (_phraseFormState.currentState != null ? (_phraseFormState.currentState!.validate() == true ? null : 20) : null),
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
                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Colors.red)),
                errorBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: AppColors.labelDefaultColor)),
                labelText: "Confirm passphrase",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: AppColors.labelDefaultColor)),
                labelStyle: TextStyle(
                    color: rePhraseFocusNode.hasFocus ? Colors.white : AppColors.labelDefaultColor,
                    fontWeight: rePhraseFocusNode.hasFocus ? FontWeight.w900 : FontWeight.w500,
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
                            height:
                                (_rephraseFormState.currentState != null ? (_rephraseFormState.currentState!.validate() == true ? null : 20) : null),
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
        if (_phraseFormState.currentState!.validate() == true && _rephraseFormState.currentState!.validate() == true) {
          FocusScopeNode currentFocus = FocusScope.of(this.context);
          currentFocus.unfocus();

          if (_authApi.isHardwareAllowed()) {
            await showDialog(
                context: context,
                builder: (_) {
                  return AppPopupWidget(title: 'Fingerprint', padding: EdgeInsets.all(20), canClose: false, cancelable: false, children: [
                    Text(
                      'Would you like to add\nfingerprint authentication?',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSizeHuge,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 3,
                    ),
                    Row(
                      children: [
                        Expanded(flex: 1, child: SizedBox()),
                        Expanded(
                            flex: 3,
                            child: AppNeonButton(
                              textStyle: TextStyle(fontSize: SizeConfig.fontSizeLarge, color: Colors.white),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await showDialog(
                                    context: context,
                                    builder: (_) => StatefulBuilder(builder: (builder, setState) {
                                          return ProgressPopup(
                                              title: "Creating",
                                              future: appWalletManager.walletManager
                                                  .makeAccount(controller1.text, appWalletManager, mnemonic: mnemonicString)
                                                  .then((result) {
                                                // Creates the user account
                                                appWalletManager.selectedId = 0;
                                                // Navigator.pop(context);
                                                // Navigator.pushReplacementNamed(context, "app/overview");
                                                Navigator.of(context).pushNamedAndRemoveUntil('app/overview', (Route<dynamic> route) => false);
                                                NotificationBar().show(context, text: "Account #0 selected");
                                              }));
                                        }));
                              },
                              text: 'NO',
                            )),
                        Expanded(flex: 1, child: SizedBox()),
                        Expanded(
                            flex: 3,
                            child: AppButton(
                              textStyle: TextStyle(fontSize: SizeConfig.fontSizeLarge, color: Colors.white),
                              onPressed: () async {
                                dynamic _temp;
                                _temp = await _authApi.saveSecret(controller1.text);
                                if (_temp is String) {
                                  NotificationBar().show(context, text: 'Fingerprint enabled', onPressed: () {});
                                  Provider.of<AvmeWallet>(context, listen: false).fingerprintAuth =
                                      !(Provider.of<AvmeWallet>(context, listen: false).fingerprintAuth);
                                  file(true);
                                  Navigator.of(context).pop();
                                  await showDialog(
                                      context: context,
                                      builder: (_) => StatefulBuilder(builder: (builder, setState) {
                                            return ProgressPopup(
                                                title: "Creating",
                                                future: appWalletManager.walletManager
                                                    .makeAccount(controller1.text, appWalletManager, mnemonic: mnemonicString)
                                                    .then((result) {
                                                  // Creates the user account
                                                  appWalletManager.selectedId = 0;
                                                  // Navigator.pop(context);
                                                  // Navigator.pushReplacementNamed(context, "app/overview");
                                                  Navigator.of(context).pushNamedAndRemoveUntil('app/overview', (Route<dynamic> route) => false);
                                                  NotificationBar().show(context, text: "Account #0 selected");
                                                }));
                                          }));
                                } else {
                                  NotificationBar().show(context, text: 'Fingerprint scanning cancelled', onPressed: () {});
                                }
                              },
                              text: 'YES',
                            )),
                        Expanded(flex: 1, child: SizedBox())
                      ],
                    )
                  ]);
                });
          } else {
            await showDialog(
                context: context,
                builder: (_) => StatefulBuilder(builder: (builder, setState) {
                      return ProgressPopup(
                          title: "Creating",
                          future:
                              appWalletManager.walletManager.makeAccount(controller1.text, appWalletManager, mnemonic: mnemonicString).then((result) {
                            // Creates the user account
                            appWalletManager.selectedId = 0;
                            // Navigator.pop(context);
                            // Navigator.pushReplacementNamed(context, "app/overview");
                            Navigator.of(context).pushNamedAndRemoveUntil('app/overview', (Route<dynamic> route) => false);
                            NotificationBar().show(context, text: "Account #0 selected");
                          }));
                    }));
          }
        }
      },
      text: 'CREATE ACCOUNT',
      expanded: false,
    );
  }

  ///TODO: Might wanna find a way to change this later, so the authApi can automatically change to true
  Future<int> file(dynamic input) async {
    //More info on settings.json
    final FileManager fileManager = FileManager();

    Future<File> settingsFile() async {
      await fileManager.getDocumentsFolder();
      String fileFolder = "${fileManager.documentsFolder}";
      await fileManager.checkPath(fileFolder);

      File file = File("${fileFolder}settings${fileManager.ext}");

      if (!await file.exists()) {
        await file.writeAsString(fileManager.encoder.convert({
          "display": {"deviceGroupCustom": "0"},
          "options": {"fingerprintAuth": false}
        }));
      }
      return file;
    }

    Future<File> file = settingsFile();
    Map<String, dynamic> fileRead = {};

    await file.then((value) async {
      fileRead = json.decode(await value.readAsString());
    });

    fileRead["options"]["fingerprintAuth"] = input;

    file.then((File file) async {
      file.writeAsString(fileManager.encoder.convert(fileRead));
    });

    return 0;
  }

  Widget passwordScreen() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[AppColors.purpleVariant1, AppColors.purpleBlue])),
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
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Text("Import Wallet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.titleSize)),
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
                begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[AppColors.purpleVariant1, AppColors.purpleBlue])),
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
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 10,
                                      child: Text(
                                        "Fill in mnemonic phrase to import an account",
                                        style: AppTextStyles.spanWhite,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 0.8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(6)),
                                          color: AppColors.purple,
                                        ),
                                        height: SizeConfig.blockSizeVertical * 6,
                                        // height: (SizeConfig.blockSizeVertical * 12) - 8,
                                        child: ButtonTheme(
                                          alignedDropdown: true,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                                          child: DropdownButton(
                                              dropdownColor: AppColors.purple,
                                              autofocus: false,
                                              onChanged: (v) => dropChange(v),
                                              style: AppTextStyles.spanWhiteMedium,
                                              value: _dropValue,
                                              underline: SizedBox(),
                                              isExpanded: true,
                                              // selectedItemBuilder: (BuildContext context) {
                                              //   return <String>['12', '24'].map<Widget>((String item) {
                                              //     return Container(
                                              //         alignment: Alignment.center, width: double.maxFinite, child: Text(item, textAlign: TextAlign.end));
                                              //   }).toList();
                                              // },
                                              items: _dropList),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Container(
                                          padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 0.8),
                                          child: AppButton(
                                            onPressed: () => handlePaste(),
                                            text: '',
                                            paddingBetweenIcons: SizeConfig.blockSizeHorizontal * 5,
                                            iconData: Icons.content_paste,
                                          )),
                                    ),
                                  ],
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: SizeConfig.safeBlockVertical * 50),
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 2),
                                    child: Scrollbar(
                                        isAlwaysShown: true,
                                        thickness: 4,
                                        controller: write,
                                        child: SingleChildScrollView(
                                          controller: write,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
                                                child: createList(_dropValue),
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
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          invalidMnemonic,
                                          style: AppTextStyles.span.copyWith(color: Colors.red),
                                        ),
                                      ),
                                Container(
                                  child: AppNeonButton(
                                    textStyle: TextStyle(color: Colors.white, fontSize: SizeConfig.spanSize * 1.6),
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => ImportAccount()),
                                      );
                                    },
                                    text: 'LAYOUT',
                                  ),
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical * 2,
                                ),
                                Container(
                                  child: AppButton(
                                      onPressed: () async {
                                        if (validate() != _dropValue) {
                                          print('test1');
                                          setState(() {
                                            invalidMnemonic = 'Oops, looks like you forgot to fill a field';
                                            isAllFilled = false;
                                          });
                                        } else {
                                          print('mnemonicString $mnemonicString @ _dropValue $_dropValue');
                                          if (await appWalletManager.walletManager.checkMnemonic(phrase: mnemonicString, phraseCount: _dropValue)) {
                                            setState(() {
                                              invalidMnemonic = '';
                                              isAllFilled = true;
                                              swap = !swap;
                                            });
                                          } else {
                                            setState(() {
                                              invalidMnemonic = 'Words do not correspond to mnemonic dictionary';
                                              isAllFilled = false;
                                            });
                                          }
                                        }
                                      },
                                      // expanded: false,
                                      text: "IMPORT"),
                                ),
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
