import 'package:avme_wallet/app/lib/utils.dart';
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
  Map<int,List> generatedKeys = {};
  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    List<Widget> drawerElements = [];

    widget.app.accountList.forEach((key,accountObject) {
        // bool selected = key == widget.app.currentWalletId ? true : false;
        DecorationTween balanceTween = DecorationTween(
            begin: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      appColors.preColorList[key][0],
                      appColors.preColorList[key][1]
                    ]
                )
            ),
            end: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      appColors.preColorList[key][2],
                      appColors.preColorList[key][3]
                    ]
                )
            )
        );

        drawerElements.add(
            GradientCard(
                address: accountObject.address,
                onPressed: (){
                  widget.app.setCurrentWallet(key);
                  Navigator.of(context).pop();
                  NotificationBar().show(context, text:"Account \"${widget.app.accountList[key].title}\" selected.");
                },
                onIconPressed: () {},
                balance: accountObject.currencyBalance == null || accountObject.currencyTokenBalance == null ? "0,0000000" :
                "${shortAmount((accountObject.currencyBalance +
                    accountObject.currencyTokenBalance).toString(),comma: true, length: 7)}",
                label: accountObject.title,
                balanceTween: balanceTween,
            ),
        );
    });

    List<Widget> finalDrawer = [];

    drawerElements.asMap().forEach((pos,element) {
      if(pos == (drawerElements.length - 1))
        finalDrawer.add(element);
      else
        finalDrawer.add(Padding(
          padding: EdgeInsets.only(bottom: 28),
          child: element,
        ));
    });

    return CustomAppDrawer(header(),finalDrawer.asMap(),footer(widget.app));
  }

  Widget header()
  {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        top:12,
        right: 16,
        bottom: 28,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Accounts",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)
                    ),
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
                      onTap: (){
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
        ]
      ),
    );
  }

  Widget footer(AvmeWallet app)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppNeonButton(
          onPressed: () => NotificationBar().show(context, text: "Import was taped"),
          text: "IMPORT",
          expanded: false,
          paddingText: EdgeInsets.symmetric(horizontal: 16),
          textStyle: TextStyle(
              color: Colors.white
          ),
        ),
        AppButton(
          onPressed: () async {
            newAccountPopup(app);
          },
          text: "NEW",
          expanded: false,
          paddingText: EdgeInsets.symmetric(horizontal: 24),
          textStyle: TextStyle(
              color: Colors.white
          ),
        ),
      ],
    );
  }

  void newAccountPopup(AvmeWallet app)
  {
    showDialog(context: context, builder: (_) =>
      StatefulBuilder(
        builder: (builder, setState) =>
          FuturePopupWidget(
            title: "CREATE NEW ACCOUNT",
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
            margin: EdgeInsets.all(8),
            cancelable: false,
            // future: futureDelayed(seconds: 8),
            future: previewAccounts(setState, app),
          )
      )
    );
  }

  Future futureDelayed({int seconds}) async
  {
    await Future.delayed(Duration(seconds: seconds ?? 10),(){
      print("DONE");
    });
    return
    [
      Center(child:Text("i cant let you go"))
    ];
  }

  Future<List<Widget>> previewAccounts(StateSetter setter, AvmeWallet app) async
  {
    final int flexIndex = 1;
    final int flexAddress = 4;
    final int flexBalance = 2;
    final double darkBorderPadding = 8.0;

    String password = env["DEFAULT_PASSWORD"];

    this.generatedKeys = this.generatedKeys.length > 0
        ? this.generatedKeys
        : await app.walletManager.previewAvaxBalance(password);

    return [
      Text("Choose an Account from the List"),
      SizedBox(
        height: 24,
      ),
      ///Header
      Container(
        decoration:BoxDecoration(
            borderRadius: borderRadius,
            color: AppColors.darkBlue
        ),
        child: Padding(
          padding: EdgeInsets.all(darkBorderPadding),
          child: Row(
            children: [
              Expanded(flex: flexIndex, child: Text("Index")),
              Expanded(flex: flexAddress, child: Text("Account"),),
              Expanded(flex: flexBalance, child: Text("AVAX Balance", textAlign: TextAlign.center,),)
            ],
          ),
        ),
      ),
      SizedBox(
        height: 12,
      ),
      Container(
        decoration:BoxDecoration(
            borderRadius: borderRadius,
            color: AppColors.darkBlue
        ),
        child: Padding(
          padding: EdgeInsets.all(darkBorderPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 1 / 3
            ),
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
                      setter: setter
                    );
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
        onPressed: (){
          TextEditingController addressController = TextEditingController(
            text: this.generatedKeys[this.selectedIndex][0]
          );
          TextEditingController nameController = TextEditingController();
          Navigator.pop(context);
          showDialog(context: context, builder: (_) =>
            StatefulBuilder(
              builder: (builder, setState) =>
                AppPopupWidget(
                  title: "Warning",
                  margin: EdgeInsets.all(8),
                  cancelable: true,
                  padding: EdgeInsets.only(
                    left: 32,
                    right: 32,
                    top: 32,
                    bottom: 8
                  ),
                  actions: [
                    AppButton(
                      expanded: false,
                      onPressed: () async {
                        Navigator.pop(context);
                        await createAccount(
                          name: nameController.text,
                          app: app,
                          password: password
                        );
                      },
                      text: "CONFIRM"
                    )
                  ],
                  children: [
                    Text("Please confirm the selected account and/or assign a name."),
                    SizedBox(
                      height: 32,
                    ),
                    Row(
                      children: [
                        LabelText("Selected Account", fontSize: 18,),
                      ],
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                        newAccountPopup(app);
                      },
                      child: AppTextFormField(
                        controller: addressController,
                        enabled: false,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8
                        ),
                        isDense: true,
                      ),
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    Row(
                      children: [
                        LabelText("(OPTIONAL) Name", fontSize: 18,),
                      ],
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    AppTextFormField(
                      controller: nameController,
                      hintText: "Name for your Account",
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8
                      ),
                      isDense: true,
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    Divider(),
                  ],
                )
            )
          );
        }
      )
      : Container()
    ];
  }

  Future<void> createAccount({AvmeWallet app, String password, String name}) async
  {
    showDialog(
      context: context,
      builder: (_) =>
        ProgressPopup(
          title: "Finished",
          future: app.walletManager.makeAccount(
              password,
              app,
              title: name,
              slot: this.selectedIndex).then((value) async {
            // Navigator.pop(context);
            if(name.length == 0)
            {
              name = "-unnamed ${this.selectedIndex}-";
            }
            await app.login(password, context);
            return [
              Text("The Account \"$name\" was added!"),
            ];
          })
        )
    );

  }

  Widget accountRow({
    int flexIndex,
    int flexAddress,
    int flexBalance,
    int index,
    String address,
    String balance,
    StateSetter setter
  }){
    print("rendering with $selectedIndex");
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GestureDetector(
        onTap: (){
          print("clicky $selectedIndex , $index");
          setter((){
            selectedIndex = selectedIndex != index ? index : -1;
          });
        },
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: selectedIndex == index ? AppColors.purple : AppColors.cardDefaultColor
              // color: AppColors.purple
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
            child: Row(
              children: [
                ///Index
                Expanded(flex: flexIndex, child: Text(index.toString()),),
                ///Account Address (Shortened)
                Expanded(flex: flexAddress, child: Text("${address.substring(0,8)}...${address.substring(34,42)}"),),
                ///Balance
                Expanded(flex: flexBalance, child: Text(balance, textAlign: TextAlign.center,),),
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
  final Map<dynamic,Widget> routes;
  final String side;
  const CustomAppDrawer(
      this.header,
      this.routes,
      this.footer,
      {this.side = "RIGHT"});

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
              ? BorderRadius.only(
              topLeft: labelRadius.topLeft * 2,
              bottomLeft: labelRadius.bottomLeft * 2
          )
              : BorderRadius.only(
              topRight: labelRadius.topRight * 2,
              bottomRight: labelRadius.bottomRight * 2
          ),
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
                        if(entry.key.runtimeType == int)
                          return entry.value;
                        else
                          return ListTile(
                            title: Text("${entry.key}"),
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => entry.value));
                            },
                          );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 28.0
                    ),
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