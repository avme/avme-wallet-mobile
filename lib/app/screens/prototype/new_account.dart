import 'package:avme_wallet/app/controller/wallet_manager.dart';
import 'package:avme_wallet/app/model/app.dart';
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

  // FocusNode seedFocusNode = new FocusNode();
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
  WalletManager appWalletManager;

  String warning1 = " Use these words in sequential order to recover your AVME Wallet";
  String warning2 = " STORE THIS KEY PHRASE IN A SECURE LOCATION. ANYONE WITH THIS KEY PHRASE CAN ACCESS YOUR AVALANCHE WALLET. THERE IS NO WAY TO RECOVER LOST KEY PHRASES.";
  @override
  initState() {

    appWalletManager = Provider.of<AvmeWallet>(context, listen: false).walletManager;
    this.walletSeed = this.walletSeed ?? appWalletManager.newMnemonic();

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

    return Scaffold(
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
          child: ListView(
            shrinkWrap: true,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(
                      (MediaQuery.of(context).size.width * 0.1).toDouble()
                    ),
                    child: Card(
                      color: AppColors.cardBlue,
                      child: Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 32,
                              horizontal: 32,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ///Header
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
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 16,
                                                    bottom: 10,
                                                    // left: 16,
                                                    right: 16
                                                ),
                                                child: Icon(
                                                  Icons.arrow_back,
                                                  size: 32,
                                                  color: AppColors.labelDefaultColor,
                                                ),
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
                                                fontWeight: FontWeight.bold, fontSize: 28)
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(child: Container())
                                  ],
                                ),
                                ScreenIndicator(
                                  height: 20,
                                  width: MediaQuery.of(context).size.width,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Column(
                                    children: [
                                      ///Seed Phrase
                                      Padding(
                                        padding: const EdgeInsets.only(top:16),
                                        // padding: EdgeInsets.zero,
                                        child: Stack(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                // NotificationBar().show(context, text: "Display the full Seed");
                                                AppPopup().show(
                                                  context: context,
                                                  canClose: true,
                                                  title: Text("This is your key phrase",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                    left: 32,
                                                    right: 32,
                                                    top: 16,
                                                    bottom: 8
                                                  ),
                                                  children: [
                                                    Text(this.warning1),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                      child: Divider(color: Colors.white,),
                                                    ),
                                                    seedList(this.walletSeed),
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
                                                    fontSize: 20
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
                                                        this.walletSeed = appWalletManager.newMnemonic();
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
                                      ),
                                      ///Passphrase
                                      Form(
                                        key: _phraseFormState,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top:32),
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
                                                    fontSize: 20
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
                                                      // child: Padding(
                                                      //   padding: const EdgeInsets.all(8.0),
                                                      //   child: this.phraseIcon,
                                                      // ),
                                                    ),
                                                  )
                                                )
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      ///Confirm Passphrase
                                      Form(
                                        key: _rephraseFormState,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top:32),
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
                                                    fontSize: 20
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
                                      ),
                                      SizedBox(
                                        height: 32,
                                      ),
                                      ElevatedButton(
                                        // onPressed: () => createNewAccount(context),
                                        onPressed: () {
                                          if(_phraseFormState.currentState.validate() == true && _rephraseFormState.currentState.validate() == true)
                                          {
                                            FocusScopeNode currentFocus = FocusScope.of(context);
                                            currentFocus.unfocus();
                                            NotificationBar().show(context,text: "Creating account.");
                                            // return ;
                                            AppPopup().show(
                                              context: context,
                                              canClose: false,
                                              title: Text("Warning",
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w500
                                                ),
                                              ),
                                              padding: EdgeInsets.only(
                                                  left: 32,
                                                  right: 32,
                                                  top: 16,
                                                  bottom: 8
                                              ),
                                              children: [
                                                Text(this.warning1),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  child: Divider(color: Colors.white,),
                                                ),
                                                seedList(this.walletSeed),
                                                Padding(
                                                  // padding: const EdgeInsets.symmetric(vertical: 32),
                                                  padding: EdgeInsets.only(top: 24),
                                                  child: Text(this.warning2),
                                                )
                                              ],
                                              actions: [
                                                AppNeonButton(
                                                  text: "Continue",
                                                  expanded: false,
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              ]
                                            );
                                          }
                                        },
                                        child: Text("CREATE ACCOUNT"),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int maxCharacteresInsideTextField(BuildContext context)
  {
    int size = (MediaQuery.of(context).size.width / 17).round();
    return size;
  }

  Widget seedList(String seed)
  {
    Map<int,List<Widget>> columnMap = {};
    int row = 0;

    seed.split(' ').asMap().forEach((key, value) {

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
                ),),
            ],
          )
      );
      print("row[$row] ${key+1} - $value");
    });

    List<Widget> columnWidgets = [];
    columnMap.keys.forEach((key) {
      columnWidgets.add(
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: columnMap[key].toList(),
          ),
        )
      );
    });

    return Row(
      children: columnWidgets,
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    );
  }



  void createNewAccount(BuildContext context) async
  {
    bool empty = (phraseController == null || rePhraseController == null) ? true : false;
    bool notEqual = (phraseController.text != rePhraseController.text) ? true : false;
    bool short = (phraseController.text.length <= 5 || rePhraseController.text.length <= 5) ? true : false;

    if(short)
    {
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) =>
              SimpleWarning(
                  title: "Warning",
                  text:
                  "Your passphrase is too short!")
      );
      return;
    }
    if(empty)
    {
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) =>
              SimpleWarning(
                  title: "Warning",
                  text:
                  "Please, fill in all fields!")
      );
      return;
    }
    if(notEqual)
    {
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) =>
              SimpleWarning(
                  title: "Warning",
                  text:
                  "Passphrases don't match."
                      +"\n"+
                      "Please check your inputs.")
      );
      return;
    }
    BuildContext _loadingPopupContext;

    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          _loadingPopupContext = context;
          return LoadingPopUp(
              text:
              "Loading, please wait."
          );
        }
    );

    // Creates the user account
    //
    // await appState.walletManager.makeAccount(field1.text, appState);
    // Navigator.pop(_loadingPopupContext);
    // Navigator.pushReplacementNamed(context, "/home");
    // appState.changeCurrentWalletId = 0;
    // snack("Account #0 selected", context);
    // return;
  }
}
