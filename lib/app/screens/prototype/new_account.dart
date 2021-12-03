import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/controller/wallet_manager.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class NewAccount extends StatefulWidget {
  @override
  _NewAccountState createState() => _NewAccountState();
}

class _NewAccountState extends State<NewAccount> {

  final _phraseFormState = GlobalKey<FormState>();
  final _rephraseFormState = GlobalKey<FormState>();

  FocusNode phraseFocusNode = new FocusNode();
  FocusNode rePhraseFocusNode = new FocusNode();

  TextEditingController phraseController = new TextEditingController();
  TextEditingController rePhraseController = new TextEditingController();

  EdgeInsets textFieldButtonPadding = new EdgeInsets.only(
    left: 12,
    top: 20,
    right: 42,
    bottom:20,
  );

  Icon phraseIcon = Icon(Icons.refresh, color: Colors.transparent,);
  Icon rePhraseIcon = Icon(Icons.refresh, color: Colors.transparent,);

  String walletSeed;
  Map walletSeedMap;

  AvmeWallet appWalletManager;

  String warning1 = " Use these words in sequential order to recover your AVME Wallet";
  String warningMnemonic = " Oops, looks like you forgot to fill number ";
  String warning2 = " STORE THIS KEY PHRASE IN A SECURE LOCATION. ANYONE WITH THIS KEY PHRASE CAN ACCESS YOUR AVALANCHE WALLET. THERE IS NO WAY TO RECOVER LOST KEY PHRASES.";

  int wrongMnemonic = -1;

  FormMnemonic formMnemonic;

  @override
  initState() {

    appWalletManager = Provider.of<AvmeWallet>(context, listen: false);
    this.walletSeed = this.walletSeed ?? appWalletManager.walletManager.newMnemonic();
    this.walletSeedMap = this.walletSeed.split(' ').asMap();
    phraseFocusNode.addListener(() {
      setState(() => null);
    });

    rePhraseFocusNode.addListener(() {
      setState(() => null);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double fieldSpacing = SizeConfig.safeBlockVertical * 4;

    // this.labelSize = SizeConfig.safeBlockVertical * 6;

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
                                    ///Seed Phrase
                                    seedField(context),
                                    ///Passphrase
                                    passPhrase(context),
                                    ///Confirm Passphrase
                                    rePassphrase(context),
                                    SizedBox(
                                      height: fieldSpacing,
                                    ),
                                    createAccount(),
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
                    "Create New",
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

  int maxCharacteresInsideTextField(BuildContext context)
  {
    int size = (MediaQuery.of(context).size.width / 17).round();
    return size;
  }

  List<int> selectedMnemonicWords(String seed)
  {
    Random random = Random();
    Map words = seed.split(' ').asMap();
    List<int> keys = [];
    while(keys.length < 3)
    {
      int key = random.nextInt(words.length);
      if (!keys.contains(key))
        keys.add(key);
    }

    // print(keys);
    // print(words.length);
    return keys;
  }

  Widget getVerifyMnemonicWidget(String seed, List<int> selectedKeys)
  {
    Map<int,List<Widget>> columnMap = {};
    int row = 0;

    seed.split(' ').asMap().forEach((key, value) {
      if(key.remainder(6) == 0 && key != 0)
        row++;
      columnMap[row] = columnMap[row] ?? [];
      columnMap[row].add(
        Padding(
          padding: row > 0 ? const EdgeInsets.only(left:8) : const EdgeInsets.only(right:8),
          child: Row(
            children: [
              Text(" ${key+1}." + (key > 8 ? "  " : "   "),
                style: TextStyle(
                  color: Colors.blue
                ),
              ),
              Expanded(
                child: TextField(
                  controller: new TextEditingController(
                    text: selectedKeys.contains(key) ? null : value,
                  ),
                  enabled: selectedKeys.contains(key),
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold
                  ),
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: EdgeInsets.all(0),
                    disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2)
                    ),
                    labelStyle: TextStyle(
                      color: phraseFocusNode.hasFocus ? Colors.white : AppColors.labelDefaultColor,
                      fontWeight: phraseFocusNode.hasFocus ? FontWeight.w900 : FontWeight.w500,
                      fontSize: 20
                    ),
                  )
                ),
              ),
            ],
          ),
        ),
      );
      // print("row[$row] ${key+1} - $value");
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

  Widget getSeedList(Map seed)
  {

    Map<int,List<Widget>> columnMap = {};
    int row = 0;

    seed.forEach((key, value) {

      if(key.remainder(6) == 0 && key != 0)
        row++;

      columnMap[row] = columnMap[row] ?? [];
      columnMap[row].add(
        Row(
          children: [
            Text(" ${key+1}. ",
              style: TextStyle(
                color: Colors.blue
              ),
            ),
            Text(value,
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        )
      );
      // print("row[$row] ${key+1} - $value");
    });

    List<Widget> columnWidgets = [];
    columnMap.values.forEach((value) {
      columnWidgets.add(
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: value.toList(),
          ),
        )
      );
    });

    return Row(
      children: columnWidgets,
    );
  }

  Widget seedField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top:SizeConfig.safeBlockVertical * 1),
      // padding: EdgeInsets.zero,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(context: context, builder: (_) {
                return AppPopupWidget(
                  canClose: true,
                  title: "This is your key phrase",
                  padding: EdgeInsets.only(
                    left: 32,
                    right: 32,
                    top: 16,
                    bottom: 8
                  ),
                  cancelable: false,
                  children: [
                    Text(this.warning1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12),
                      child: Divider(),
                    ),
                    getSeedList(this.walletSeedMap),
                    Padding(
                      // padding: const EdgeInsets.symmetric(vertical: 32),
                      padding: EdgeInsets.only(top: 24),
                      child: Text(this.warning2),
                    )
                  ],
                  actions: [
                    AppNeonButton(
                      text: "Ok",
                      expanded: false,
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ]
                );
              }
            );
            },
            child: TextField(
              controller: new TextEditingController(
                text:
                this.walletSeed.substring(0, maxCharacteresInsideTextField(context)).trim() + "..."
              ),
              enabled: false,
              cursorColor: AppColors.labelDefaultColor,
              decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2,
                    color: Colors.grey[600]
                  )
                ),
                labelText: "Seed",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 2,
                    color: AppColors.labelDefaultColor
                  )
                ),
                labelStyle: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: SizeConfig.labelSize
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2,
                    color: Colors.white
                  ),
                ),
              )
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: double.infinity,
                width: 48,
                child: IconButton(
                  onPressed: () {
                    NotificationBar().show(context, text: "A new key phrase was generated");
                    setState(() {
                      this.walletSeed = appWalletManager.walletManager.newMnemonic();
                      this.walletSeedMap = this.walletSeed.split(' ').asMap();
                    });
                  },
                  icon: Icon(Icons.refresh),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
              )
            )
          ),
        ],
      ),
    );
  }

  Form passPhrase(BuildContext context) {
    return Form(
      key: _phraseFormState,
      child: Padding(
        padding: EdgeInsets.only(top:SizeConfig.safeBlockVertical * 3),
        child: Stack(
          children: [
            TextFormField(
              validator: (string) {
                if(string.length  <=5)
                  return "This field cannot be empty";
                else
                  return null;
              },
              controller: this.phraseController,
              cursorColor: AppColors.labelDefaultColor,
              obscureText: true,
              focusNode: phraseFocusNode,
              onChanged: (string) {
                if(string.length > 5)
                  this.phraseIcon = new Icon(Icons.done_sharp, color: Colors.green,);
                else
                  this.phraseIcon = new Icon(Icons.close_rounded, color: Colors.red,);
                setState(() => null);
              },
              decoration: InputDecoration(
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2,
                    color: Colors.red
                  )
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2,
                    color: AppColors.labelDefaultColor
                  )
                ),
                labelText: "Passphrase",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: textFieldButtonPadding,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2,
                    color: AppColors.labelDefaultColor,
                  ),
                ),
                labelStyle: TextStyle(
                  color: phraseFocusNode.hasFocus ? Colors.white : AppColors.labelDefaultColor,
                  fontWeight: phraseFocusNode.hasFocus ? FontWeight.w900 : FontWeight.w500,
                  fontSize: SizeConfig.labelSize
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2,
                    color: Colors.white
                  ),
                ),
              )
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
                            child: this.phraseIcon,
                          ),
                        ),
                        SizedBox(
                          height:
                          (_phraseFormState.currentState != null ?
                          (_phraseFormState.currentState.validate() == true ? null : 20) :
                          null),
                        )
                      ],
                    ),
                  ),
                )
              )
            )
          ],
        ),
      ),
    );
  }

  Form rePassphrase(BuildContext context) {
    return Form(
      key: _rephraseFormState,
      child: Padding(
        padding: EdgeInsets.only(top:SizeConfig.safeBlockVertical * 3),
        child: Stack(
          children: [
            TextFormField(
              validator: (string) {
                if(string == this.phraseController.text)
                  return null;
                else
                  return "Passphrases don't match";
              },
              controller: this.rePhraseController,
              cursorColor: AppColors.labelDefaultColor,
              obscureText: true,
              focusNode: rePhraseFocusNode,
              onChanged: (string) {
                // print("${this.phraseController.text} | $string");
                if(string.length > 5 && string == this.phraseController.text)
                  this.rePhraseIcon = new Icon(Icons.done_sharp, color: Colors.green,);
                else
                  this.rePhraseIcon = new Icon(Icons.close_rounded, color: Colors.red,);
                setState(() => null);
              },
              decoration: InputDecoration(
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2,
                    color: Colors.red
                  )
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2,
                    color: AppColors.labelDefaultColor
                  )
                ),
                labelText: "Confirm passphrase",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2,
                    color: AppColors.labelDefaultColor
                  )
                ),
                labelStyle: TextStyle(
                  color: rePhraseFocusNode.hasFocus ? Colors.white : AppColors.labelDefaultColor,
                  fontWeight: rePhraseFocusNode.hasFocus ? FontWeight.w900 : FontWeight.w500,
                  fontSize: SizeConfig.labelSize
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2,
                    color: Colors.white
                  ),
                ),
              )
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
                          child: this.rePhraseIcon,
                        ),
                      ),
                      SizedBox(
                        height:
                        (_rephraseFormState.currentState != null ?
                        (_rephraseFormState.currentState.validate() == true ? null : 20) :
                        null),
                      )
                    ],
                  ),
                )
              )
            )
          ],
        ),
      ),
    );
  }

  AppButton createAccount() {
    return AppButton(
      onPressed: () {
        ScrollController read = ScrollController();
        if(_phraseFormState.currentState.validate() == true && _rephraseFormState.currentState.validate() == true)
        {
          ///First we gathered the keys to hide and make the user verify
          formMnemonic = new FormMnemonic(mnemonic: this.walletSeed);
          String invalidMnemonic = "";
          FocusScopeNode currentFocus = FocusScope.of(this.context);
          currentFocus.unfocus();
          Future.delayed(Duration(milliseconds: 200), (){
            showDialog(context: context, builder: (_) =>
              StatefulBuilder(builder: (builder, setState) =>
                AppPopupWidget(
                  title: "Warning",
                  canClose: false,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: SizeConfig.safeBlockVertical * 40
                      ),
                      child: Scrollbar(
                        isAlwaysShown: true,
                        thickness: 4,
                        controller: read,
                        child: SingleChildScrollView(
                          controller: read,
                          child: Column(
                            children: [
                              Text(this.warning1),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Divider(),
                              ),
                              getSeedList(this.walletSeedMap),
                              Padding(
                                padding: EdgeInsets.only(top: 24),
                                child: Text(this.warning2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                  actions: [
                    AppNeonButton(
                      expanded: false,
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await showDialog(context: context, builder: (_) =>
                          StatefulBuilder(builder: (builder, setState) =>
                            AppPopupWidget(
                              title: "Verify Mnemonic",
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              children: [
                                Text("Fill in Mnemonic Phrase Below"),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: formMnemonic.build(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(invalidMnemonic,
                                    style: TextStyle(color: Colors.red),),
                                ),
                              ],
                              actions: [
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
                                      return;
                                    }
                                  },
                                  expanded: false,
                                  text: "VERIFY"
                                ),
                              ]
                            )
                          )
                        );
                        // Navigator.of(context).pop();
                      },
                      text: "Continue",
                    )
                  ]
                )
              )
            );
          });
        }
      },
      text: 'CREATE ACCOUNT',
      expanded: false,
    );
  }
}

class FormMnemonic {

  final String mnemonic;

  List<int> removedKeys = [];
  Map<int, String> mnemonicDict = {};
  Map<int, TextEditingController> mnemonicControlDict = {};

  FormMnemonic({this.mnemonic}) {
    Random random = new Random();

    this.mnemonicDict = this.mnemonic.split(" ").asMap();

    ///Selecting what keys the user must fill
    while(this.removedKeys.length < 3)
    {
      int key = random.nextInt(this.mnemonicDict.length);
      // int key = random.nextInt(3);
      if (!this.removedKeys.contains(key))
        this.removedKeys.add(key);
    }

    ///We're populating our dictionary of TextController to use later
    this.mnemonicDict.forEach((key, value) {
      mnemonicControlDict[key] = new TextEditingController(
        text: this.removedKeys.contains(key) ? null : value,
      );
    });
  }

  ///Returns the wrong label position
  int validate()
  {
    int validated = -1;
    this.removedKeys.forEach((key) {
      print("${this.mnemonicControlDict[key].text} != ${this.mnemonicDict[key]}");
      if(this.mnemonicControlDict[key].text != this.mnemonicDict[key] && validated == -1)
        validated = key;
    });
    return validated;
  }

  Widget build()
  {
    Map<int,List<Widget>> columnMap = {};
    int row = 0;

    this.mnemonicDict.forEach((key, value) {

      if(key.remainder(6) == 0 && key != 0)
        row++;

      columnMap[row] = columnMap[row] ?? [];
      columnMap[row].add(
        Padding(
          padding: row > 0 ? const EdgeInsets.only(left:8) : const EdgeInsets.only(right:8),
          child:Row(
            children: [
              Text(" ${key+1}." + (key > 8 ? "  " : "   "),
                style: TextStyle(
                  color: Colors.blue
                ),
              ),
              Expanded(
                child: TextField(
                  controller: this.mnemonicControlDict[key],
                  enabled: this.removedKeys.contains(key),
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold
                  ),
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: EdgeInsets.all(0),
                    disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2)
                    ),
                    labelStyle: TextStyle(
                      color: AppColors.labelDefaultColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 20
                    ),
                  )
                ),
              ),
            ],
          ),
        ),
      );
      print("row[$row] ${key+1} - $value");
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

