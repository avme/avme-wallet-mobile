import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:avme_wallet/app/controller/authapi.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/controller/wallet_manager.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/app_drawer.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/app_hint.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/gradient_card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../../../controller/file_manager.dart';

class AccountsDrawer extends StatefulWidget {
  final AvmeWallet app;

  const AccountsDrawer({Key key, @required this.app}) : super(key: key);

  @override
  _AccountsDrawerState createState() => _AccountsDrawerState();
}

class _AccountsDrawerState extends State<AccountsDrawer> {
  BorderRadius borderRadius = BorderRadius.circular(8);
  int selectedIndex = -1;
  Map<int, List> generatedKeys = {};
  TextEditingController passwordInput = TextEditingController(text: "");
  TextEditingController controllerMnemonic = TextEditingController(text: "");
  ScrollController write = ScrollController();
  bool canAuthenticate = false, isAllFilled = true;
  String invalidMnemonic = '';
  AuthApi authApi;

  @override
  void initState() {
    startFingerprint();
    super.initState();
  }

  void startFingerprint() async {
    authApi = await AuthApi.init();
  }

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    List<Widget> drawerElements = [];

    widget.app.accountList.forEach((key, accountObject) {
      bool isNotFirstKey = (key != 0);
      // bool selected = key == widget.app.currentWalletId ? true : false;
      DecorationTween balanceTween = DecorationTween(
          begin: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[appColors.preColorList[key][0], appColors.preColorList[key][1]])),
          end: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[appColors.preColorList[key][2], appColors.preColorList[key][3]])));

      drawerElements.add(
        GradientCard(
          address: accountObject.address,
          onPressed: () {
            widget.app.selectedId = key;
            Navigator.of(context).pop();
            NotificationBar().show(context, text: "Account \"${widget.app.accountList[key].title}\" selected.");
          },
          onIconPressed: () {},
          iconChild: isNotFirstKey
              ? Container(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {
                      if (key != 0) {
                        showDialog(
                            context: context,
                            builder: (_) => StatefulBuilder(
                                builder: (builder, setState) => AppPopupWidget(
                                      title: "Delete Account",
                                      cancelable: false,
                                      showIndicator: false,
                                      padding: EdgeInsets.all(20),
                                      children: [
                                        Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: SizeConfig.blockSizeHorizontal * 4,
                                                  left: SizeConfig.blockSizeHorizontal * 2,
                                                  right: SizeConfig.blockSizeHorizontal * 2),
                                              child: Text(
                                                'Are you sure you want to delete\naccount ${widget.app.accountList[key].title}?',
                                                style: AppTextStyles.spanWhiteMedium,
                                              ),
                                            ),
                                            Container(
                                                width: SizeConfig.screenWidth / 3,
                                                child: AppNeonButton(
                                                  onPressed: () async {
                                                    print('Pressed key $key with following info:');
                                                    print(widget.app.accountList[key].title);
                                                    Navigator.pop(context);
                                                    await deleteAccountByName(widget.app, widget.app.accountList[key].title, key);
                                                  },
                                                  text: 'YES',
                                                  // size: SizeConfig.fontSizeLarge,
                                                  textStyle: AppTextStyles.spanWhite,
                                                )),
                                            SizedBox(
                                              height: SizeConfig.blockSizeVertical * 2,
                                            ),
                                            Container(
                                                width: SizeConfig.screenWidth / 3,
                                                child: AppNeonButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  text: 'NO',
                                                  // size: SizeConfig.fontSizeLarge,
                                                  textStyle: AppTextStyles.spanWhite,
                                                )),
                                          ],
                                        ),
                                      ],
                                    )));
                      } else {
                        AppHint.show('Cannot delete Default Account');
                      }
                    },
                    child: Icon(
                      Icons.delete_outline,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                )
              : Container(),
          balance: _totalBalance(accountObject),
          label: accountObject.title,
          balanceTween: balanceTween,
        ),
      );
    });

    List<Widget> finalDrawer = [];

    drawerElements.asMap().forEach((pos, element) {
      if (pos == (drawerElements.length - 1))
        finalDrawer.add(element);
      else
        finalDrawer.add(Padding(
          padding: EdgeInsets.only(bottom: 28),
          child: element,
        ));
    });

    return CustomAppDrawer(header(), finalDrawer.asMap(), footer(widget.app));
  }

  Future<void> deleteAccountByName(AvmeWallet app, String name, int key) async {
    showDialog(
        context: context,
        builder: (_) => ProgressPopup(
            title: "Finished",
            future: app.walletManager.deleteAccountByName(widget.app.accountList[key].title).then((value) async {
              //Do the whole thing idk
              return value ? [Text('Account $name deleted successfully')] : [Text('Account $name failed to delete')];
            })));
  }

  String _totalBalance(AccountObject accountObject) {
    List tokensValue = accountObject.tokensBalanceList.entries.map((e) => e.value["balance"]).toList();

    double totalValue = accountObject.networkBalance;

    tokensValue.forEach((value) => totalValue += value);

    print(tokensValue);
    return "${shortAmount(totalValue.toString(), comma: true, length: 7)}";
  }

  Widget header() {
    return Padding(
      padding: EdgeInsets.only(
        top: SizeConfig.safeBlockVertical * 2,
        bottom: SizeConfig.safeBlockHorizontal * 6,
        left: SizeConfig.safeBlockHorizontal * 4,
        right: SizeConfig.safeBlockHorizontal * 4,
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Accounts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.fontSizeLarge * 1.2)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ///Close button
                  GestureDetector(
                    child: Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 16,
                          bottom: 10,
                        ),
                        child: Icon(
                          Icons.account_circle_outlined,
                          size: 36,
                          color: AppColors.purple,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        ScreenIndicator(
          height: 20,
          width: MediaQuery.of(context).size.width,
          position: 0,
          equal: true,
        ),
      ]),
    );
  }

  Widget footer(AvmeWallet app) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppNeonButton(
          onPressed: () async {
            passwordScreen(app, true);
          },
          text: "IMPORT",
          expanded: false,
          paddingText: EdgeInsets.symmetric(horizontal: 16),
          textStyle: TextStyle(color: Colors.white, fontSize: SizeConfig.fontSize * 1.2),
        ),
        AppButton(
          onPressed: () async {
            passwordScreen(app, false);
          },
          text: "NEW",
          expanded: false,
          paddingText: EdgeInsets.symmetric(horizontal: 24),
          textStyle: TextStyle(color: Colors.white, fontSize: SizeConfig.fontSize * 1.2),
        ),
      ],
    );
  }

  void importScreen(AvmeWallet app, String password) {
    String invalidMnemonic = '';
    showDialog(
        context: context,
        builder: (_) => StatefulBuilder(builder: (builder, setState) {
              void verifyMnemonic(AvmeWallet app, String mnemonics) async {
                List<dynamic> validate() {
                  String response = mnemonics.trim().replaceAll('\n', ' ');
                  final regex = RegExp(r'\ +');
                  String responseNew = response.replaceAll(regex, ' ');
                  List<String> responseList = responseNew.split(' ');
                  if (responseList.length == 12 || responseList.length == 24) {
                    return [true, responseNew, responseList.length];
                  } else {
                    return [false, responseNew, responseList.length];
                  }
                }

                List<dynamic> response = validate();
                bool validated = response[0];
                String mnemonicString = response[1];
                int _phraseCount = response[2];
                if (validated == false) {
                  setState(() {
                    invalidMnemonic = 'One or more words are missing';
                    isAllFilled = false;
                  });
                } else {
                  if (await app.walletManager.checkMnemonic(phrase: mnemonicString, phraseCount: _phraseCount)) {
                    controllerMnemonic.clear();
                    Navigator.of(context).pop();
                    newAccountPopup(app, true, password, mnemonics: mnemonicString);
                  } else {
                    setState(() {
                      invalidMnemonic = 'Words do not correspond to mnemonic dictionary';
                      isAllFilled = false;
                    });
                  }
                }
              }

              void handlePaste() async {
                final ClipboardData _data = await Clipboard.getData('text/plain');
                if (_data != null || _data.text != '') {
                  //
                  String _mnemonicTemp = _data.text;
                  _mnemonicTemp = _mnemonicTemp.trim().replaceAll('\n', ' ');
                  final regex = RegExp(r'\ +');
                  _mnemonicTemp = _mnemonicTemp.replaceAll(regex, ' ');
                  setState(() {
                    controllerMnemonic.text = _mnemonicTemp;
                  });
                }
              }

              return AppPopupWidget(
                title: "Import Seed",
                cancelable: false,
                showIndicator: false,
                padding: EdgeInsets.all(20),
                children: [
                  Column(
                    children: [
                      ScreenIndicator(
                        height: SizeConfig.safeBlockVertical * 2,
                        width: MediaQuery.of(context).size.width,
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 3,
                      ),
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Fill in mnemonic phrase to import an account",
                            style: AppTextStyles.spanWhite,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Separate words with space or new line",
                            style: AppTextStyles.spanWhite,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Supports both 12 and 24 word mnemonic length",
                            style: AppTextStyles.spanWhite,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 3,
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
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Container(
                                        width: SizeConfig.screenWidth / 1.5,
                                        child: AppTextFormField(
                                          controller: controllerMnemonic,
                                          minLines: 1,
                                          maxLines: 24,
                                          inputFormatters: [MaxLinesTextInputFormatter(24)],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 1,
                      ),
                      isAllFilled
                          ? Padding(
                              padding: const EdgeInsets.all(0),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                invalidMnemonic,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.span.copyWith(color: Colors.red),
                              ),
                            ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 1,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Navigator.of(context).pop();
                          handlePaste();
                        },
                        child: Text("PASTE"),
                        // style: ElevatedButton.styleFrom(
                        //   padding: EdgeInsets.symmetric(vertical: 21, horizontal: 0),
                        // style: _btnStyleLogin,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Navigator.of(context).pop();
                          verifyMnemonic(app, controllerMnemonic.text);
                        },
                        child: Text("IMPORT SEED"),
                        // style: ElevatedButton.styleFrom(
                        //   padding: EdgeInsets.symmetric(vertical: 21, horizontal: 0),
                        // style: _btnStyleLogin,
                      ),
                    ],
                  ),
                ],
              );
            }));
  }

  void passwordScreen(AvmeWallet app, bool import) async {
    showDialog(
        context: context,
        builder: (_) => StatefulBuilder(builder: (builder, setState) {
              return AppPopupWidget(
                title: "Verify Password",
                cancelable: false,
                showIndicator: false,
                padding: EdgeInsets.all(20),
                children: [
                  Column(
                    children: [
                      ScreenIndicator(
                        height: SizeConfig.safeBlockVertical * 2,
                        width: MediaQuery.of(context).size.width,
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 3,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Please type your passphrase.',
                            style: AppTextStyles.span.copyWith(fontSize: SizeConfig.fontSize * 1.5),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 2,
                      ),
                      AppTextFormField(
                        controller: passwordInput,
                        obscureText: true,
                        hintText: "**********",
                        onFieldSubmitted: (_) {
                          Navigator.of(context).pop();
                          authenticate(app, passwordInput.text, import);
                          passwordInput.clear();
                        },
                        icon: canAuthenticate
                            ? Icon(
                                Icons.fingerprint,
                                color: AppColors.labelDefaultColor,
                                size: 32,
                              )
                            : Container(),
                        iconOnTap: () async {
                          if (canAuthenticate) {
                            dynamic _temp = await authApi.retrieveSecret();
                            if (_temp is String) {
                              Navigator.of(context).pop();
                              authenticate(app, _temp, import);
                            }
                          }
                        },
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 4,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          authenticate(app, passwordInput.text, import);
                          passwordInput.clear();
                        },
                        child: Text("VERIFY PASSWORD"),
                        // style: ElevatedButton.styleFrom(
                        //   padding: EdgeInsets.symmetric(vertical: 21, horizontal: 0),
                        // style: _btnStyleLogin,
                      ),
                    ],
                  ),
                ],
              );
            }));
    canAuthenticate = authApi.canAuthenticate();
    if (canAuthenticate) {
      dynamic _temp = await authApi.retrieveSecret();
      if (_temp is String) {
        Navigator.of(context).pop();
        authenticate(app, _temp, import);
      }
    }
  }

  void authenticate(AvmeWallet app, String passwordInput, bool import) async {
    bool empty = (passwordInput == null || passwordInput.length == 0) ? true : false;
    if (empty)
      showDialog(
          context: context,
          builder: (BuildContext context) => AppPopupWidget(
                title: 'Warning',
                cancelable: false,
                showIndicator: false,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical / 2, bottom: SizeConfig.safeBlockVertical * 3),
                    child: Text('The password field cannot be empty'),
                  ),
                  AppButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    expanded: false,
                    text: "OK",
                  )
                ],
              ));
    else {
      AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);
      bool valid = (await app.walletManager.authenticate(passwordInput, app, restart: false))["status"] == 200 ? true : false;
      if (valid) {
        // Navigator.of(context).pop();
        FocusScope.of(context).unfocus();
        import ? importScreen(app, passwordInput) : newAccountPopup(app, false, passwordInput);
      } else {
        NotificationBar().show(context, text: "Failed to Authenticate");
      }
    }
  }

  void newAccountPopup(AvmeWallet app, bool import, String password, {String mnemonics}) async {
    await showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
              builder: (builder, setState) {
                if (import) {
                  return ProgressPopup(
                    title: "Loading",
                    future: app.walletManager.previewAvaxBalance(mnemonics, mnemonic: true).then((Map data) {
                      printWarning("$data");
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (_) => StatefulBuilder(
                              builder: (builder, setState) => AppPopupWidget(
                                    title: "IMPORT NEW ACCOUNT",
                                    textStyle: TextStyle(fontSize: SizeConfig.titleSize * 0.8, fontWeight: FontWeight.bold),
                                    margin: EdgeInsets.all(8),
                                    cancelable: false,
                                    padding: EdgeInsets.only(
                                      left: SizeConfig.safeBlockHorizontal * 8,
                                      right: SizeConfig.safeBlockHorizontal * 8,
                                      top: SizeConfig.safeBlockVertical * 4,
                                    ),
                                    children: previewAccounts(setState, app, import, password, data, mnemonics: mnemonics),
                                  )));
                    }),
                  );
                } else {
                  return ProgressPopup(
                    title: "Loading",
                    future: app.walletManager.previewAvaxBalance(password).then((Map data) {
                      printWarning("$data");
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (_) => StatefulBuilder(
                              builder: (builder, setState) => AppPopupWidget(
                                    title: "CREATE NEW ACCOUNT",
                                    textStyle: TextStyle(fontSize: SizeConfig.titleSize * 0.8, fontWeight: FontWeight.bold),
                                    margin: EdgeInsets.all(8),
                                    cancelable: false,
                                    padding: EdgeInsets.only(
                                      left: SizeConfig.safeBlockHorizontal * 8,
                                      right: SizeConfig.safeBlockHorizontal * 8,
                                      top: SizeConfig.safeBlockVertical * 4,
                                    ),
                                    children: previewAccounts(setState, app, import, password, data),
                                  )));
                    }),
                  );
                }
              },
            ));
  }

  List<Widget> previewAccounts(StateSetter setter, AvmeWallet app, bool import, String password, Map generatedKeys, {String mnemonics}) {
    final int flexIndex = 1;
    final int flexAddress = 4;
    final int flexBalance = 2;
    final double darkBorderPadding = 8.0;

    //Checking to make sure user chose a different option

    // this.generatedKeys = this.generatedKeys.length > 0 ? this.generatedKeys : await app.walletManager.previewAvaxBalance(password);
    // this.generatedKeys = this.generatedKeys.length > 0 ? this.generatedKeys : await app.walletManager.previewAvaxBalanceImport(mnemonics);
    // Now accounts can be generated either from the same or a different seed, so we always have to generate new

    // import
    //     ? generatedKeys = await app.walletManager.previewAvaxBalanceImport(mnemonics)
    //     : generatedKeys = await app.walletManager.previewAvaxBalance(password);

    return [
      Text(
        "Choose an Account from the List",
        style: TextStyle(fontSize: SizeConfig.fontSize * 1.5),
      ),
      import
          ? Padding(
              padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
              child: Text(
                "generated from the seed you provided",
                style: TextStyle(fontSize: SizeConfig.fontSize * 1.5),
              ),
            )
          : SizedBox(),
      SizedBox(
        height: 24,
      ),

      ///Header
      Container(
        decoration: BoxDecoration(borderRadius: borderRadius, color: AppColors.darkBlue),
        child: Padding(
          padding: EdgeInsets.all(darkBorderPadding),
          child: Row(
            children: [
              Expanded(
                  flex: flexIndex * 2,
                  child: Text(
                    "Index",
                    style: TextStyle(fontSize: SizeConfig.fontSize * 1.5),
                  )),
              Expanded(
                flex: flexAddress,
                child: Text(
                  "Account",
                  style: TextStyle(fontSize: SizeConfig.fontSize * 1.5),
                ),
              ),
              Expanded(
                flex: flexBalance,
                child: Text(
                  "AVAX Balance",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: SizeConfig.fontSize * 1.5),
                ),
              )
            ],
          ),
        ),
      ),
      SizedBox(
        height: 12,
      ),
      Container(
        decoration: BoxDecoration(borderRadius: borderRadius, color: AppColors.darkBlue),
        child: Padding(
          padding: EdgeInsets.all(darkBorderPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 1 / 3),
            child: ListView(
              shrinkWrap: true,
              children: [
                ///Account Row
                Column(
                  children: generatedKeys.entries.map((publicKeyEntry) {
                    return accountRow(
                        flexIndex: flexIndex,
                        flexAddress: flexAddress,
                        flexBalance: flexBalance,
                        index: publicKeyEntry.key,
                        address: "${publicKeyEntry.value[0]}",
                        balance: "${publicKeyEntry.value[1]}",
                        setter: setter);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      SizedBox(
        height: 18,
      ),
      this.selectedIndex > -1

          ///Choose this account
          ? AppButton(
              text: "CHOOSE THIS ACCOUNT",
              onPressed: () {
                TextEditingController addressController = TextEditingController(text: generatedKeys[this.selectedIndex][0]);
                TextEditingController nameController = TextEditingController();
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (_) => StatefulBuilder(
                        builder: (builder, setState) => AppPopupWidget(
                              scrollable: true,
                              title: "Warning",
                              margin: EdgeInsets.all(8),
                              cancelable: true,
                              padding: EdgeInsets.only(left: 32, right: 32, top: 32, bottom: 8),
                              actions: [
                                AppButton(
                                    expanded: false,
                                    onPressed: () async {
                                      // If no name, check if any unnamed exists, create the highest possible
                                      if (nameController.text.isEmpty) {
                                        String _title;
                                        //Default, in case it doesn't find any unnamed accounts, only default account
                                        if (app.accountList.length == 1) {
                                          print('app.accountList.length == 1');
                                          _title = 'unnamed 1';
                                        } else {
                                          //Searches for the list and flicks to true if it finds unnamed number.
                                          //Then it does a last search to know which unnamed it can make
                                          //Create a list of 9 false slots, then make the first one is true, being the default account
                                          List<bool> numbers = List.filled(9, false);
                                          numbers[0] = true;
                                          for (int i = 1; i < app.accountList.length; i++) {
                                            for (AccountObject account in app.accountList.values) {
                                              if (account.title == 'unnamed $i') numbers[i] = true;
                                            }
                                          }
                                          //Checking which slot in the list is false
                                          for (int i = 0; i < numbers.length; i++) {
                                            if (numbers[i] == false) {
                                              _title = 'unnamed $i';
                                              break;
                                            }
                                          }
                                        }
                                        Navigator.pop(context);
                                        await createAccount(
                                          name: _title,
                                          app: app,
                                          password: password,
                                          mnemonics: mnemonics,
                                          import: import,
                                        );
                                      } else {
                                        // If custom name, check if name already exists
                                        bool alreadyExists = false;
                                        for (int i = 0; i < app.accountList.length; i++) {
                                          if (nameController.text == app.accountList[i].title) {
                                            print('alreadyExists = true');
                                            alreadyExists = true;
                                          }
                                        }
                                        if (!alreadyExists) {
                                          Navigator.pop(context);
                                          await createAccount(
                                            name: nameController.text,
                                            app: app,
                                            password: password,
                                            mnemonics: mnemonics,
                                            import: import,
                                          );
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (_) => StatefulBuilder(builder: (builder, setState) {
                                                    return AppPopupWidget(
                                                      cancelable: false,
                                                      title: 'Error',
                                                      children: [Text('Name already exists')],
                                                      actions: [AppButton(onPressed: () => Navigator.pop(context), text: 'CANCEL')],
                                                    );
                                                  }));
                                        }
                                      }
                                    },
                                    text: "CONFIRM")
                              ],
                              children: [
                                Text(
                                  "Please confirm the selected account and/or assign a name.",
                                  style: TextStyle(fontSize: SizeConfig.fontSize * 1.5),
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical * 4,
                                ),
                                Row(
                                  children: [
                                    LabelText(
                                      "Selected Account",
                                      fontSize: SizeConfig.fontSize * 1.5,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical * 2,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print('tapped');
                                    Navigator.pop(context);
                                    newAccountPopup(app, false, password);
                                  },
                                  child: AppTextFormField(
                                    controller: addressController,
                                    enabled: false,
                                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    isDense: true,
                                  ),
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical * 3,
                                ),
                                Row(
                                  children: [
                                    LabelText(
                                      "(OPTIONAL) Name",
                                      fontSize: SizeConfig.fontSize * 1.5,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 16.0,
                                ),
                                AppTextFormField(
                                  controller: nameController,
                                  hintText: "Name for your Account",
                                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  isDense: true,
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical * 3,
                                ),
                                Divider(),
                              ],
                            )));
              })
          : Container()
    ];
  }

  Future<void> createAccount({AvmeWallet app, String password, String name, String mnemonics, bool import}) async {
    showDialog(
        context: context,
        builder: (_) => ProgressPopup(
            title: "Finished",
            future: app.walletManager
                .makeAccount(password, app, title: name, slot: this.selectedIndex, mnemonic: mnemonics, import: import)
                .then((value) async {
              // Navigator.pop(context);
              if (name.length == 0) {
                name = "-unnamed ${this.selectedIndex}-";
              }
              await app.login(password, context);
              return [
                Text("The Account \"$name\" was added!"),
              ];
            })));
  }

  Widget accountRow({int flexIndex, int flexAddress, int flexBalance, int index, String address, String balance, StateSetter setter}) {
    print("rendering with $selectedIndex");
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GestureDetector(
        onTap: () {
          print("clicky $selectedIndex , $index");
          setter(() {
            selectedIndex = selectedIndex != index ? index : -1;
          });
        },
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.rectangle, color: selectedIndex == index ? AppColors.purple : AppColors.cardDefaultColor
              // color: AppColors.purple
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
            child: Row(
              children: [
                ///Index
                Expanded(
                  flex: flexIndex,
                  child: Text(index.toString(), style: TextStyle(fontSize: SizeConfig.fontSize * 1.4)),
                ),

                ///Account Address (Shortened)
                Expanded(
                  flex: flexAddress,
                  child: Text("${address.substring(0, 8)}...${address.substring(34, 42)}", style: TextStyle(fontSize: SizeConfig.fontSize * 1.4)),
                ),

                ///Balance
                Expanded(
                  flex: flexBalance,
                  child: Text(balance, textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.fontSize * 1.4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomAppDrawer extends StatefulWidget {
  final Widget header;
  final Widget footer;
  final Map<dynamic, Widget> routes;
  final String side;
  const CustomAppDrawer(this.header, this.routes, this.footer, {this.side = "RIGHT"});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<CustomAppDrawer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 8 * 7,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: ClipRRect(
          borderRadius: widget.side.toUpperCase() == "RIGHT"
              ? BorderRadius.only(topLeft: labelRadius.topLeft * 2, bottomLeft: labelRadius.bottomLeft * 2)
              : BorderRadius.only(topRight: labelRadius.topRight * 2, bottomRight: labelRadius.bottomRight * 2),
          child: Drawer(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24.0),
              child: Column(
                children: [
                  widget.header,
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 1.5),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: widget.routes.entries.map((entry) {
                        if (entry.key.runtimeType == int)
                          return entry.value;
                        else
                          return ListTile(
                            title: Text("${entry.key}"),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => entry.value));
                            },
                          );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 28.0),
                    child: widget.footer,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PreviewAccounts extends StatefulWidget {
  const PreviewAccounts({Key key}) : super(key: key);

  @override
  _PreviewAccountsState createState() => _PreviewAccountsState();
}

class _PreviewAccountsState extends State<PreviewAccounts> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MaxLinesTextInputFormatter extends TextInputFormatter {
  MaxLinesTextInputFormatter(this._maxLines) : assert(_maxLines == -1 || _maxLines > 0);

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
