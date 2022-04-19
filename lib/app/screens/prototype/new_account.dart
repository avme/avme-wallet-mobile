import 'dart:convert';
import 'dart:io';

import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/controller/wallet_manager.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/authentication.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../controller/file_manager.dart';

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
    bottom: 20,
  );

  Icon phraseIcon = Icon(
    Icons.refresh,
    color: Colors.transparent,
  );
  Icon rePhraseIcon = Icon(
    Icons.refresh,
    color: Colors.transparent,
  );

  String walletSeed;
  Map walletSeedMap;

  AvmeWallet appWalletManager;

  String warning1 = " Use these words in sequential order to recover your AVME Wallet";
  String warningMnemonic = " Oops, looks like you forgot to fill number ";
  String warning2 =
      " STORE THIS KEY PHRASE IN A SECURE LOCATION. ANYONE WITH THIS KEY PHRASE CAN ACCESS YOUR AVALANCHE WALLET. THERE IS NO WAY TO RECOVER LOST KEY PHRASES.";

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
                                  height: fieldSpacing,
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
                Text("Create New", style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.titleSize)),
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

  int maxCharacteresInsideTextField(BuildContext context) {
    // int size = (MediaQuery.of(context).size.width / 17).round();
    int size = (SizeConfig.safeBlockHorizontal * 7).round();
    return size;
  }

  List<int> selectedMnemonicWords(String seed) {
    Random random = Random();
    Map words = seed.split(' ').asMap();
    List<int> keys = [];
    while (keys.length < 3) {
      int key = random.nextInt(words.length);
      if (!keys.contains(key)) keys.add(key);
    }

    // print(keys);
    // print(words.length);
    return keys;
  }

  Widget getVerifyMnemonicWidget(String seed, List<int> selectedKeys) {
    Map<int, List<Widget>> columnMap = {};
    int row = 0;

    seed.split(' ').asMap().forEach((key, value) {
      if (key.remainder(6) == 0 && key != 0) row++;
      columnMap[row] = columnMap[row] ?? [];
      columnMap[row].add(
        Padding(
          padding: row > 0 ? const EdgeInsets.only(left: 8) : const EdgeInsets.only(right: 8),
          child: Row(
            children: [
              Text(
                " ${key + 1}." + (key > 8 ? "  " : "   "),
                style: TextStyle(color: Colors.blue),
              ),
              Expanded(
                child: TextField(
                    controller: new TextEditingController(
                      text: selectedKeys.contains(key) ? null : value,
                    ),
                    enabled: selectedKeys.contains(key),
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: EdgeInsets.all(0),
                      disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                      labelStyle: TextStyle(
                          color: phraseFocusNode.hasFocus ? Colors.white : AppColors.labelDefaultColor,
                          fontWeight: phraseFocusNode.hasFocus ? FontWeight.w900 : FontWeight.w500,
                          fontSize: 20),
                    )),
              ),
            ],
          ),
        ),
      );
      // print("row[$row] ${key+1} - $value");
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

  Widget getSeedList(Map seed) {
    Map<int, List<Widget>> columnMap = {};
    int row = 0;

    seed.forEach((key, value) {
      if (key.remainder(12) == 0 && key != 0) row++;

      columnMap[row] = columnMap[row] ?? [];
      columnMap[row].add(Row(
        children: [
          Text(
            " ${key + 1}. ",
            style: TextStyle(color: Colors.blue, fontSize: SizeConfig.fontSizeHuge),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: SizeConfig.fontSizeHuge),
          ),
        ],
      ));
      // print("row[$row] ${key+1} - $value");
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
                        title: "This is your key phrase",
                        padding: EdgeInsets.only(left: 32, right: 32, top: 16, bottom: 8),
                        cancelable: false,
                        children: [
                          Text(this.warning1, style: TextStyle(fontSize: SizeConfig.fontSizeLarge * 0.5 + 8)),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical),
                            child: Divider(),
                          ),
                          getSeedList(this.walletSeedMap),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical),
                            child: Divider(),
                          ),
                          Padding(
                            // padding: const EdgeInsets.symmetric(vertical: 32),
                            padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical),
                            child: Text(this.warning2, style: TextStyle(fontSize: SizeConfig.fontSizeLarge * 0.5 + 8)),
                          )
                        ],
                        actions: [
                          AppNeonButton(
                            text: "COPY PHRASE KEY",
                            expanded: false,
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: this.walletSeed));
                              NotificationBar().show(context, text: "Mnemonics copied to clipboard", onPressed: () {});
                            },
                          ),
                          AppNeonButton(
                            text: "OK",
                            expanded: false,
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ]);
                  });
            },
            child: TextField(
                controller: new TextEditingController(text: this.walletSeed.substring(0, maxCharacteresInsideTextField(context)).trim() + "..."),
                enabled: false,
                cursorColor: AppColors.labelDefaultColor,
                decoration: InputDecoration(
                  disabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Colors.grey[600])),
                  labelText: "Seed",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(borderSide: BorderSide(width: 2, color: AppColors.labelDefaultColor)),
                  labelStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: SizeConfig.labelSize),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.white),
                  ),
                )),
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
                  ))),
        ],
      ),
    );
  }

  Form passPhrase(BuildContext context) {
    return Form(
      key: _phraseFormState,
      child: Padding(
        padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 3),
        child: Stack(
          children: [
            TextFormField(
              validator: (string) {
                if (string.length <= 5)
                  return "This field cannot be empty";
                else
                  return null;
              },
              controller: this.phraseController,
              cursorColor: AppColors.labelDefaultColor,
              obscureText: true,
              focusNode: phraseFocusNode,
              onChanged: (string) {
                if (string.length > 5)
                  this.phraseIcon = new Icon(
                    Icons.done_sharp,
                    color: Colors.green,
                  );
                else
                  this.phraseIcon = new Icon(
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
                                child: this.phraseIcon,
                              ),
                            ),
                            SizedBox(
                              height: (_phraseFormState.currentState != null ? (_phraseFormState.currentState.validate() == true ? null : 20) : null),
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
    return Form(
      key: _rephraseFormState,
      child: Padding(
        padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 3),
        child: Stack(
          children: [
            TextFormField(
              validator: (string) {
                if (string == this.phraseController.text)
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
                if (string.length > 5 && string == this.phraseController.text)
                  this.rePhraseIcon = new Icon(
                    Icons.done_sharp,
                    color: Colors.green,
                  );
                else
                  this.rePhraseIcon = new Icon(
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
                              child: this.rePhraseIcon,
                            ),
                          ),
                          SizedBox(
                            height:
                                (_rephraseFormState.currentState != null ? (_rephraseFormState.currentState.validate() == true ? null : 20) : null),
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
        if (_phraseFormState.currentState.validate() == true && _rephraseFormState.currentState.validate() == true) {
          ///First we gathered the keys to hide and make the user verify

          formMnemonic = new FormMnemonic(mnemonic: this.walletSeed);
          FocusScopeNode currentFocus = FocusScope.of(this.context);
          currentFocus.unfocus();
          Future.delayed(Duration(milliseconds: 200), () {
            showDialog(
                context: context,
                builder: (_) => MnemonicsPreAccCreation(
                    warning1: warning1,
                    warning2: warning2,
                    walletSeedMap: walletSeedMap,
                    appWalletManager: appWalletManager,
                    walletSeed: walletSeed,
                    phraseController: phraseController));
          });
        }
      },
      text: 'CREATE ACCOUNT',
      expanded: false,
    );
  }
}

class MnemonicsPreAccCreation extends StatefulWidget {
  final String warning1, warning2, walletSeed;
  final Map<dynamic, dynamic> walletSeedMap;
  final AvmeWallet appWalletManager;
  final TextEditingController phraseController;

  const MnemonicsPreAccCreation(
      {Key key, this.warning1, this.warning2, this.walletSeed, this.walletSeedMap, this.appWalletManager, this.phraseController})
      : super(key: key);

  @override
  _MnemonicsPreAccCreationState createState() => _MnemonicsPreAccCreationState();
}

class _MnemonicsPreAccCreationState extends State<MnemonicsPreAccCreation> {
  ScrollController read = ScrollController();
  bool endOfScroll = false;
  bool showMnemonics = true;

  Authentication _authApi = Authentication();

  _listener() {
    final maxScroll = read.position.maxScrollExtent;
    //final minScroll = read.position.minScrollExtent;
    if (read.offset >= maxScroll) {
      setState(() {
        endOfScroll = true;
      });
    }

    if (read.offset < maxScroll) {
      setState(() {
        endOfScroll = false;
      });
    }
  }

  @override
  void initState() {
    read.addListener(_listener);
    super.initState();
  }

  @override
  void dispose() {
    read.removeListener(_listener);
    read.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: showMnemonics
          ? AppPopupWidget(title: "Warning", canClose: false, children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: SizeConfig.safeBlockVertical * 50),
                child: Scrollbar(
                  isAlwaysShown: true,
                  thickness: 4,
                  controller: read,
                  child: SingleChildScrollView(
                    controller: read,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: SizeConfig.safeBlockVertical * 2,
                          ),
                          child: Text(widget.warning1, style: TextStyle(fontSize: SizeConfig.fontSizeLarge * 0.5 + 10)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Divider(),
                        ),
                        getSeedList(widget.walletSeedMap),
                        Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: Text(widget.warning2, style: TextStyle(fontSize: SizeConfig.fontSizeLarge * 0.5 + 10)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ], actions: [
              AppNeonButton(
                enabled: endOfScroll,
                expanded: false,
                onPressed: () async {
                  setState(() {
                    showMnemonics = false;
                  });

                  if (await _authApi.canAuthenticate()) {
                    await showDialog(
                        context: context,
                        builder: (_) {
                          return AppPopupWidget(
                              title: 'Fingerprint Authentication',
                              padding: EdgeInsets.all(20),
                              canClose: false,
                              cancelable: false,
                              children: [
                                Text(
                                  'Would you like to enable\nfingerprint authentication?',
                                  style: TextStyle(
                                    fontSize: SizeConfig.fontSizeHuge,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical * 2,
                                ),
                                Row(
                                  children: [
                                    Expanded(flex: 1, child: SizedBox()),
                                    Expanded(
                                        flex: 3,
                                        child: AppNeonButton(
                                          textStyle: TextStyle(fontSize: SizeConfig.fontSizeLarge, color: AppColors.purple),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await showDialog(
                                                context: context,
                                                builder: (_) => StatefulBuilder(builder: (builder, setState) {
                                                      return ProgressPopup(
                                                          title: "Creating",
                                                          future: widget.appWalletManager.walletManager
                                                              .makeAccount(widget.phraseController.text, widget.appWalletManager,
                                                                  mnemonic: widget.walletSeed)
                                                              .then((result) {
                                                            // Creates the user account
                                                            widget.appWalletManager.changeCurrentWalletId = 0;
                                                            //Navigator.pop(context);
                                                            Navigator.pushReplacementNamed(context, "app/overview");
                                                            NotificationBar().show(context, text: "Account #0 selected");
                                                          }));
                                                    }));
                                          },
                                          text: 'NO',
                                        )),
                                    Expanded(flex: 1, child: SizedBox()),
                                    Expanded(
                                        flex: 3,
                                        child: AppNeonButton(
                                          textStyle: TextStyle(fontSize: SizeConfig.fontSizeLarge, color: AppColors.purple),
                                          onPressed: () async {
                                            dynamic _temp;
                                            _temp = await _authApi.saveSecret(widget.phraseController.text);

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
                                                            future: widget.appWalletManager.walletManager
                                                                .makeAccount(widget.phraseController.text, widget.appWalletManager,
                                                                    mnemonic: widget.walletSeed)
                                                                .then((result) {
                                                              // Creates the user account
                                                              widget.appWalletManager.changeCurrentWalletId = 0;
                                                              //Navigator.pop(context);
                                                              Navigator.pushReplacementNamed(context, "app/overview");
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
                                  future: widget.appWalletManager.walletManager
                                      .makeAccount(widget.phraseController.text, widget.appWalletManager, mnemonic: widget.walletSeed)
                                      .then((result) {
                                    // Creates the user account
                                    widget.appWalletManager.changeCurrentWalletId = 0;
                                    //Navigator.pop(context);
                                    Navigator.pushReplacementNamed(context, "app/overview");
                                    NotificationBar().show(context, text: "Account #0 selected");
                                  }));
                            }));
                  }
                },
                text: "CONTINUE",
              )
            ])
          : SizedBox(
              height: 10,
              width: 12,
            ),
    );
  }

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

  Widget getSeedList(Map seed) {
    Map<int, List<Widget>> columnMap = {};
    int row = 0;

    seed.forEach((key, value) {
      if (key.remainder(12) == 0 && key != 0) row++;

      columnMap[row] = columnMap[row] ?? [];
      columnMap[row].add(Row(
        children: [
          Text(
            " ${key + 1}. ",
            style: TextStyle(color: Colors.blue, fontSize: SizeConfig.fontSizeHuge),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: SizeConfig.fontSizeHuge),
          ),
        ],
      ));
      // print("row[$row] ${key+1} - $value");
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
    while (this.removedKeys.length < 3) {
      int key = random.nextInt(this.mnemonicDict.length);
      // int key = random.nextInt(3);
      if (!this.removedKeys.contains(key)) this.removedKeys.add(key);
    }

    ///We're populating our dictionary of TextController to use later
    this.mnemonicDict.forEach((key, value) {
      mnemonicControlDict[key] = new TextEditingController(
        text: this.removedKeys.contains(key) ? null : value,
      );
    });
  }

  ///Returns the wrong label position
  int validate() {
    int validated = -1;
    this.removedKeys.forEach((key) {
      print("${this.mnemonicControlDict[key].text} != ${this.mnemonicDict[key]}");
      if (this.mnemonicControlDict[key].text != this.mnemonicDict[key] && validated == -1) validated = key;
    });
    return validated;
  }

  Widget build() {
    Map<int, List<Widget>> columnMap = {};
    int column = 0;

    double paddingHorizontal = SizeConfig.safeBlockHorizontal * 2;
    EdgeInsets columnPadding = EdgeInsets.all(paddingHorizontal);
    this.mnemonicDict.forEach((key, value) {
      if (key.remainder(6) == 0 && key != 0) column++;

      columnMap[column] = columnMap[column] ?? [];
      columnMap[column].add(
        Padding(
          padding: column > 0 ? columnPadding.copyWith(left: paddingHorizontal) : columnPadding.copyWith(right: paddingHorizontal),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  " ${key + 1}." + (key > 8 ? "  " : "   "),
                  style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold, fontSize: SizeConfig.labelSizeSmall),
                ),
              ),
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

              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.only(right: SizeConfig.safeBlockHorizontal * 4),
                  child: AppTextFormField(
                    enabled: this.removedKeys.contains(key),
                    controller: this.mnemonicControlDict[key],
                    textAlign: TextAlign.end,
                    // keyboardType: TextInputType.number,
                    contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
      );
      print("row[$column] ${key + 1} - $value");
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
}
