import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/app_drawer.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/gradient_card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountsDrawer extends StatefulWidget {

  final AvmeWallet app;

  const AccountsDrawer({Key key, @required this.app}) : super(key: key);

  @override
  _AccountsDrawerState createState() => _AccountsDrawerState();
}

class _AccountsDrawerState extends State<AccountsDrawer> {
  BorderRadius borderRadius = BorderRadius.circular(8);
  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    List<Widget> drawerElements = [
      header(context)
    ];

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

    drawerElements.add(
        footer(context)
    );

    List<Widget> finalDrawer = [];

    drawerElements.asMap().forEach((pos,element) {
      if(pos == 0)
        finalDrawer.add(element);
      else
        finalDrawer.add(Padding(
          padding: EdgeInsets.only(bottom: 28),
          child: element,
        ));
    });

    return AppDrawer(finalDrawer.asMap());
  }

  Widget header(BuildContext context)
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

  Widget footer(BuildContext context)
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
          onPressed: () async{
            final int flexIndex = 1;
            final int flexAddress = 4;
            final int flexBalance = 2;
            final double darkBorderPadding = 8.0;
            AvmeWallet app = Provider.of<AvmeWallet>(context,listen: false);
            Map<int,List> pkeys = await app.walletManager.previewAccounts("");
            showDialog(context: context, builder: (_) =>
              StatefulBuilder(
                builder: (builder, setState) =>
                  AppPopupWidget(
                    title: "CREATE NEW ACCOUNT",
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                    margin: EdgeInsets.all(8),
                    actions: [],
                    children: [
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
                                  children: pkeys.entries.map((publicKeyEntry) {
                                    return AccountRow(
                                        flexIndex: flexIndex,
                                        flexAddress: flexAddress,
                                        flexBalance: flexBalance,
                                        index: "${publicKeyEntry.key}",
                                        address: "${publicKeyEntry.value[0]}",
                                        balance: "${publicKeyEntry.value[1]}",
                                      );
                                  }).toList(),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              )
            );
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
}

class AccountRow extends StatelessWidget {

  final int flexIndex;
  final int flexAddress;
  final int flexBalance;
  final String index;
  final String address;
  final String balance;

  const AccountRow({
    @required this.flexIndex,
    @required this.flexAddress,
    @required this.flexBalance,
    @required this.index,
    @required this.address,
    @required this.balance
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ///Index
        Expanded(flex: flexIndex, child: Text(index),),
        ///Account Address (Shortened)
        Expanded(flex: flexAddress, child: Text("${address.substring(0,8)}...${address.substring(34,42)}"),),
        ///Balance
        Expanded(flex: flexBalance, child: Text(balance, textAlign: TextAlign.center,),),
      ],
    );
  }
}