import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:avme_wallet/app/src/controller/wallet/authentication.dart';
import 'package:avme_wallet/app/src/controller/wallet/wallet.dart';
import 'package:avme_wallet/app/src/helper/crypto/phrase.dart';
import 'package:avme_wallet/app/src/helper/enums.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/screen/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'package:avme_wallet/app/src/helper/size.dart';
import 'package:avme_wallet/app/src/screen/widgets/theme.dart';



class NewWallet extends StatefulWidget {
  @override
  _NewWalletState createState() => _NewWalletState();
}

class _NewWalletState extends State<NewWallet> {
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

  String walletSeed = PhraseGenerator.generate(Strenght.twelve);
  late Map walletSeedMap;
  //
  // AvmeWallet appWalletManager;

  String warning1 = " Use these words in sequential order to recover your AVME Wallet";
  String warningMnemonic = " Oops, looks like you forgot to fill number ";
  String warning2 =
      " STORE THIS KEY PHRASE IN A SECURE LOCATION.\nANYONE WITH THIS KEY PHRASE CAN ACCESS YOUR AVALANCHE WALLET.\nTHERE IS NO WAY TO RECOVER LOST KEY PHRASES.";

  int wrongMnemonic = -1;

  late FormMnemonic formMnemonic;

  int _dropValue = 12;

  bool _buttonStrength = true;

  @override
  initState() {
    // appWalletManager = Provider.of<AvmeWallet>(context, listen: false);
    walletSeedMap = walletSeed.split(' ').asMap();
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
    double fieldSpacing = DeviceSize.safeBlockVertical * 4;

    // this.labelSize = DeviceSize.safeBlockVertical * 6;

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
                      horizontal: DeviceSize.safeBlockHorizontal * 4,
                    ),
                    child: Card(
                      color: AppColors.cardBlue,
                      child: Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: DeviceSize.safeBlockVertical * 4,
                              horizontal: DeviceSize.safeBlockVertical * 4,
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
                                    Row(
                                      children: [
                                        Expanded(flex: 18, child: seedField(context)),
                                        Expanded(flex: 1, child: SizedBox()),
                                        Expanded(
                                          flex: 8,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: DeviceSize.blockSizeVertical * 0.8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                                color: AppColors.purple,
                                              ),
                                              child: ButtonTheme(
                                                alignedDropdown: true,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                                child: DropdownButton(
                                                  dropdownColor: AppColors.purple,
                                                  autofocus: false,
                                                  // elevation: 20,
                                                  onChanged: dropChange,
                                                  style: AppTextStyles.spanWhiteMedium,
                                                  value: _dropValue,
                                                  // isDense: true,
                                                  underline: SizedBox(),
                                                  isExpanded: true,
                                                  items: <int>[12, 24].map<DropdownMenuItem<int>>((int value) {
                                                    return DropdownMenuItem<int>(
                                                      child: Center(
                                                        child: Text(
                                                          value.toString(),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                      value: value,
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    ///Passphrase
                                    passPhrase(context),

                                    ///Confirm Passphrase
                                    rePassphrase(context),
                                    SizedBox(
                                      height: fieldSpacing,
                                    ),
                                  ],
                                ),
                                create(),
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
                Text("Create New", style: TextStyle(fontWeight: FontWeight.bold, fontSize: DeviceSize.titleSize)),
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
          vertical: DeviceSize.safeBlockVertical * 3,
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
    int size = (DeviceSize.safeBlockHorizontal * 4).round();
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
      columnMap[row]!.add(
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
                      fontSize: 20
                    ),
                  )
                ),
              ),
            ],
          ),
        ),
      );
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

    if (_dropValue == 24) {
      seed.forEach((key, value) {
        if (key.remainder(12) == 0 && key != 0) row++;

        columnMap[row] = columnMap[row] ?? [];
        columnMap[row]!.add(Row(
          children: [
            Text(
              " ${key + 1}. ",
              style: TextStyle(color: Colors.blue, fontSize: DeviceSize.fontSizeHuge),
            ),
            Text(
              value,
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: DeviceSize.fontSizeHuge),
            ),
          ],
        ));
        // print("row[$row] ${key+1} - $value");
      });
    } else {
      seed.forEach((key, value) {
        if (key.remainder(6) == 0 && key != 0) row++;

        columnMap[row] = columnMap[row] ?? [];
        columnMap[row]!.add(Row(
          children: [
            Text(
              " ${key + 1}. ",
              style: TextStyle(color: Colors.blue, fontSize: DeviceSize.fontSizeHuge),
            ),
            Text(
              value,
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: DeviceSize.fontSizeHuge),
            ),
          ],
        ));
        // print("row[$row] ${key+1} - $value");
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

  Widget seedField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: DeviceSize.safeBlockVertical * 1),
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
                      Text(this.warning1, textAlign: TextAlign.center, style: TextStyle(fontSize: DeviceSize.fontSizeLarge * 0.5 + 8)),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: DeviceSize.blockSizeVertical),
                        child: Divider(),
                      ),
                      getSeedList(this.walletSeedMap),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: DeviceSize.blockSizeVertical),
                        child: Divider(),
                      ),
                      Padding(
                        // padding: const EdgeInsets.symmetric(vertical: 32),
                        padding: EdgeInsets.only(top: DeviceSize.blockSizeVertical),
                        child: Text(this.warning2, style: TextStyle(fontSize: DeviceSize.fontSizeLarge * 0.5 + 8)),
                      )
                    ],
                    actions: [
                      AppNeonButton(
                        textStyle: TextStyle(color: Colors.white, fontSize: DeviceSize.spanSize * 1.6),
                        text: "COPY SEED",
                        expanded: false,
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: this.walletSeed));
                          AppHint.show("Mnemonic copied to clipboard");
                        },
                      ),
                      AppNeonButton(
                        textStyle: TextStyle(color: Colors.white, fontSize: DeviceSize.spanSize * 1.6),
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
                disabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Colors.grey.shade600)),
                labelText: "Seed",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(borderSide: BorderSide(width: 2, color: AppColors.labelDefaultColor)),
                labelStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: DeviceSize.labelSize),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.white),
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
                    setState(() {
                      late Strenght strength;
                      if(_dropValue == 12)
                      {
                        strength = Strenght.twelve;
                      }
                      else
                      {
                        strength = Strenght.twentyFour;
                      }
                      walletSeed = PhraseGenerator.generate(strength);
                      walletSeedMap = this.walletSeed.split(' ').asMap();
                    });
                    AppHint.show("A new key phrase was generated");
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
        padding: EdgeInsets.only(top: DeviceSize.safeBlockVertical * 3),
        child: Stack(
          children: [
            TextFormField(
              validator: (String? value) {
                value = value ?? "";
                if (value.length <= 5) {
                  return "This field cannot be empty";
                }
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
                    fontSize: DeviceSize.labelSize),
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
                          height: (_phraseFormState.currentState != null ? (_phraseFormState.currentState!.validate() == true ? null : 20) : null),
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
        padding: EdgeInsets.only(top: DeviceSize.safeBlockVertical * 3),
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
                {
                  this.rePhraseIcon = new Icon(
                    Icons.done_sharp,
                    color: Colors.green,
                  );
                }
                else {
                  this.rePhraseIcon = new Icon(
                    Icons.close_rounded,
                    color: Colors.red,
                  );
                }
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
                  fontSize: DeviceSize.labelSize),
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
                        (_rephraseFormState.currentState != null ? (_rephraseFormState.currentState!.validate() == true ? null : 20) : null),
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

  AppButton create() {
    bool isValid = false;
    bool phraseFormState = false;
    bool rePhraseFormState = false;
    if(_phraseFormState.currentState != null)
    {
      phraseFormState = _phraseFormState.currentState!.validate();
    }
    if(_rephraseFormState.currentState != null)
    {
      rePhraseFormState = _rephraseFormState.currentState!.validate();
    }
    if(phraseFormState && rePhraseFormState)
    {
      isValid = true;
    }
    return AppButton(
      onPressed: () async {
        if (_phraseFormState.currentState!.validate() == true
            && _rephraseFormState.currentState!.validate() == true) {
          ///First we gathered the keys to hide and make the user verify

          bool resume = await showDialog(
            context: context,
            builder: (_) => MnemonicsPreAccCreation(
              warning1: warning1,
              warning2: warning2,
              walletSeedMap: walletSeedMap,
              walletSeed: walletSeed,
              strength: _dropValue
            )
          ) ?? false;
          //Continues to the Wallet Creation
          if(!resume)
          { return; }


          bool isHardwareAllowed = Authentication.canAuthenticate;
          Print.warning("isHardwareAllowed $isHardwareAllowed");
          Completer<bool> askDeviceAuth = Completer();
          if(isHardwareAllowed)
          {
            await showDialog(
              context: context,
              builder: (_) {
                return AppPopupWidget(
                  title: "Fingerprint Authentication",
                  canClose: false,
                  cancelable: false,
                  margin: EdgeInsets.symmetric(horizontal: DeviceSize.safeBlockHorizontal * 12),
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(right: DeviceSize.safeBlockVertical * 2, left: DeviceSize.safeBlockVertical * 2),
                                child: SizedBox(
                                  width: DeviceSize.safeBlockVertical * 4.66,
                                  height: DeviceSize.safeBlockVertical * 4.66,
                                  child: Icon(
                                    Icons.question_mark_rounded, color: Colors.white, size: DeviceSize.safeBlockVertical * 3.5,),
                                ),
                              ),
                            )
                          ],
                        ),
                        Flexible(
                          child: Text('Would you like to enable fingerprint authentication?',),
                        ),
                      ],
                    ),
                  ],
                  actions: [
                    AppNeonButton(
                      expanded: false,
                      text: "IGNORE",
                      onPressed: () {
                        askDeviceAuth.complete(false);
                        Navigator.pop(context);
                      },
                    ),
                    AppButton(
                      expanded: false,
                      text: "ENABLE",
                      onPressed: () {
                        ///Marks
                        // bool askDeviceAuth = await Authentication.registerDeviceRecognition(widget.phraseController.text);
                        askDeviceAuth.complete(true);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              }
            );
          }
          else
          {
            askDeviceAuth.complete(false);
          }
          bool registerDeviceAuth = await askDeviceAuth.future;
          Strenght str = Strenght.twelve;
          if(_dropValue == 24)
          {
            str = Strenght.twentyFour;
          }
          Future fCreating = Wallet.createWallet(phraseController.text, str);
          await showDialog(
            context: context,
            builder: (_) => StatefulBuilder(builder: (builder, setState) {
              return ProgressPopup(
                title: "Creating",
                dismiss: true,
                future: fCreating.then((value) {
                  Navigator.pop(context);
                }),
              );
            })
          );
          Print.warning("registerDeviceAuth $registerDeviceAuth");
          if(registerDeviceAuth)
          {
            await Authentication.registerDeviceRecognition(phraseController.text);
          }

          Navigator.pushReplacementNamed(context, "/navigation/dashboard");
          AppHint.show("Account #0 Selected");
        }
      },
      enabled: isValid,
      text: 'CREATE WALLET',
      expanded: false,
    );
  }

  ValueChanged<int>? dropChange(int? value) {
    if (value != _dropValue) {
      setState(() {
        _dropValue = value!;
        setState(() {
          late Strenght strenght;
          if(_dropValue == 12)
          {
            strenght = Strenght.twelve;
          }
          else
          {
            strenght = Strenght.twentyFour;
          }
          this.walletSeed = PhraseGenerator.generate(strenght);
          this.walletSeedMap = this.walletSeed.split(' ').asMap();
        });
        AppHint.show("A new key phrase was generated with strength of $_dropValue words");
      });
    }
    return null;
  }
}

class MnemonicsPreAccCreation extends StatefulWidget {
  final String warning1;
  final String warning2;
  final String walletSeed;
  final Map walletSeedMap;
  final int strength;

  const MnemonicsPreAccCreation({
    Key? key,
    required this.warning1,
    required this.warning2,
    required this.walletSeed,
    required this.walletSeedMap,
    required this.strength
  }) : super(key: key);

  @override
  _MnemonicsPreAccCreationState createState() => _MnemonicsPreAccCreationState();
}

class _MnemonicsPreAccCreationState extends State<MnemonicsPreAccCreation> {
  ScrollController read = ScrollController();
  bool endOfScroll = false;
  bool showMnemonics = true;

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
    // authSetup();
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
            constraints: BoxConstraints(maxHeight: DeviceSize.safeBlockVertical * 50),
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
                        top: DeviceSize.safeBlockVertical * 2,
                      ),
                      child:
                      Text('${widget.warning1}\n(scroll down to continue)', style: TextStyle(fontSize: DeviceSize.fontSizeLarge * 0.5 + 10)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Divider(),
                    ),
                    getSeedList(widget.walletSeedMap),
                    Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text(widget.warning2, style: TextStyle(fontSize: DeviceSize.fontSizeLarge * 0.5 + 10)),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
        actions: [
          AppNeonButton(
            textStyle: TextStyle(color: Colors.white, fontSize: DeviceSize.spanSize * 1.6),
            enabled: endOfScroll,
            expanded: false,
            text: "CONTINUE",
            onPressed: () async {
              setState(() {
                showMnemonics = false;
              });
              Navigator.pop(context, true);
            }
          )
        ])
        : SizedBox(
        height: 10,
        width: 12,
      ),
    );
  }

  Widget getSeedList(Map seed) {
    Map<int, List<Widget>> columnMap = {};
    int row = 0;

    if (widget.strength == 24) {
      seed.forEach((key, value) {
        if (key.remainder(12) == 0 && key != 0) row++;

        columnMap[row] = columnMap[row] ?? [];
        columnMap[row]!.add(Row(
          children: [
            Text(
              " ${key + 1}. ",
              style: TextStyle(color: Colors.blue, fontSize: DeviceSize.fontSizeHuge),
            ),
            Text(
              value,
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: DeviceSize.fontSizeHuge),
            ),
          ],
        ));
        // print("row[$row] ${key+1} - $value");
      });
    } else {
      seed.forEach((key, value) {
        if (key.remainder(6) == 0 && key != 0) row++;

        columnMap[row] = columnMap[row] ?? [];
        columnMap[row]!.add(Row(
          children: [
            Text(
              " ${key + 1}. ",
              style: TextStyle(color: Colors.blue, fontSize: DeviceSize.fontSizeHuge),
            ),
            Text(
              value,
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: DeviceSize.fontSizeHuge),
            ),
          ],
        ));
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
}

class FormMnemonic {
  final String mnemonic;

  List<int> removedKeys = [];
  Map<int, String> mnemonicDict = {};
  Map<int, TextEditingController> mnemonicControlDict = {};

  FormMnemonic({required this.mnemonic}) {
    Random random = new Random.secure();

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
      //print("${this.mnemonicControlDict[key].text} != ${this.mnemonicDict[key]}");
      if (this.mnemonicControlDict[key]!.text != this.mnemonicDict[key] && validated == -1) validated = key;
    });
    return validated;
  }

  Widget build() {
    Map<int, List<Widget>> columnMap = {};
    int column = 0;

    double paddingHorizontal = DeviceSize.safeBlockHorizontal * 2;
    EdgeInsets columnPadding = EdgeInsets.all(paddingHorizontal);
    this.mnemonicDict.forEach((key, value) {
      if (key.remainder(6) == 0 && key != 0) column++;

      columnMap[column] = columnMap[column] ?? [];
      columnMap[column]!.add(
        Padding(
          padding: column > 0 ? columnPadding.copyWith(left: paddingHorizontal) : columnPadding.copyWith(right: paddingHorizontal),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  " ${key + 1}." + (key > 8 ? "  " : "   "),
                  style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold, fontSize: DeviceSize.labelSizeSmall),
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
                  padding: EdgeInsets.only(right: DeviceSize.safeBlockHorizontal * 4),
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
      //╚print("row[$column] ${key + 1} - $value");
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
