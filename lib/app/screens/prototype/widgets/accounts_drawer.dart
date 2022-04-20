import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/app_drawer.dart';
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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    List<Widget> drawerElements = [];

    widget.app.accountList.forEach((key, accountObject) {
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
          onPressed: () => NotificationBar().show(context, text: "Import was taped"),
          text: "IMPORT",
          expanded: false,
          paddingText: EdgeInsets.symmetric(horizontal: 16),
          textStyle: TextStyle(color: Colors.white, fontSize: SizeConfig.fontSize * 1.2),
        ),
        AppButton(
          onPressed: () async {
            passwordScreen(app);
          },
          text: "NEW",
          expanded: false,
          paddingText: EdgeInsets.symmetric(horizontal: 24),
          textStyle: TextStyle(color: Colors.white, fontSize: SizeConfig.fontSize * 1.2),
        ),
      ],
    );
  }

  void passwordScreen(AvmeWallet app) {
    showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (builder, setState) => AppPopupWidget(
                  title: "Verify Password",
                  cancelable: false,
                  showIndicator: false,
                  padding: EdgeInsets.all(20),
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: SizeConfig.safeBlockVertical * 2,
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
                            authenticate(app, passwordInput.text);
                            passwordInput.clear();
                          },
                        ),
                        SizedBox(
                          height: SizeConfig.safeBlockVertical * 4,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            authenticate(app, passwordInput.text);
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
                )));
  }

  void authenticate(AvmeWallet app, String passwordInput) async {
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
      bool valid = await app.login(passwordInput, context, display: true);
      if (valid) {
        FocusScope.of(context).unfocus();
        newAccountPopup(app, passwordInput);
      }
    }
  }

  void newAccountPopup(AvmeWallet app, String passwordInput) {
    showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (builder, setState) => FuturePopupWidget(
                  title: "CREATE NEW ACCOUNT",
                  textStyle: TextStyle(fontSize: SizeConfig.titleSize * 0.8, fontWeight: FontWeight.bold),
                  margin: EdgeInsets.all(8),
                  cancelable: false,
                  padding: EdgeInsets.only(
                    left: SizeConfig.safeBlockHorizontal * 8,
                    right: SizeConfig.safeBlockHorizontal * 8,
                    top: SizeConfig.safeBlockVertical * 4,
                  ),
                  future: previewAccounts(setState, app, passwordInput),
                )));
  }

  Future<List<Widget>> previewAccounts(StateSetter setter, AvmeWallet app, String passwordInput) async {
    final int flexIndex = 1;
    final int flexAddress = 4;
    final int flexBalance = 2;
    final double darkBorderPadding = 8.0;

    String password = passwordInput;

    this.generatedKeys = this.generatedKeys.length > 0 ? this.generatedKeys : await app.walletManager.previewAvaxBalance(password);

    return [
      Text(
        "Choose an Account from the List",
        style: TextStyle(fontSize: SizeConfig.fontSize * 1.5),
      ),
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
                  children: this.generatedKeys.entries.map((publicKeyEntry) {
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
                TextEditingController addressController = TextEditingController(text: this.generatedKeys[this.selectedIndex][0]);
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
                                      Navigator.pop(context);
                                      await createAccount(name: nameController.text, app: app, password: password);
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
                                    newAccountPopup(app, passwordInput);
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

  Future<void> createAccount({AvmeWallet app, String password, String name}) async {
    showDialog(
        context: context,
        builder: (_) => ProgressPopup(
            title: "Finished",
            future: app.walletManager.makeAccount(password, app, title: name, slot: this.selectedIndex).then((value) async {
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
