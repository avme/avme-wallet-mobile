import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/transaction_information.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/gradient_container.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/receive_popup.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:avme_wallet/app/screens/widgets/transaction_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../../controller/database/value_history.dart';
import '../send.dart';

//TODO: Refactor this class!

class History extends StatefulWidget {
  final TabController appScaffoldTabController;

  const History({Key key, @required this.appScaffoldTabController}) : super(key: key);
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  //DropdownButton
  String selectedDate = 'LAST WEEK';

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    SizeConfig().init(context);

    return Consumer<AvmeWallet>(
      builder: (context, app, _) {
        return ListView(
          children: [
            BalanceAndButtons(
              balanceTween: DecorationTween(
                  begin: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: <Color>[
                        appColors.preColorList[app.currentWalletId][0],
                        appColors.preColorList[app.currentWalletId][1],
                      ])),
                  end: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: <Color>[
                        appColors.preColorList[app.currentWalletId][2],
                        appColors.preColorList[app.currentWalletId][3],
                      ]))),
              totalBalance: _totalBalance(app),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: app.currentAccount.address));
                NotificationBar().show(context, text: "Address copied to clipboard", onPressed: () {});
              },
              onReceivePressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder: (builder, setState) {
                        return ReceivePopup(
                          title: "Share QR Address",
                          accountTitle: app.currentAccount.address,
                          address: app.currentAccount.address,
                          onQrPressed: () {
                            NotificationBar().show(context, text: "Address copied to clipboard", onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: app.currentAccount.address));
                            });
                          },
                        );
                      });
                    });
              },
              onSendPressed: () {
                widget.appScaffoldTabController.index = 3;
              },
              onBuyPressed: () {
                NotificationBar().show(context, text: "Not implemented");
              },
            ),
            // Padding(
            //   padding: const EdgeInsets.all(12.0),
            //   child: Row(
            //     // crossAxisAlignment: CrossAxisAlignment.end,
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     children: [
            //       Expanded(
            //         flex: 3,
            //         child:Align(
            //         alignment: Alignment.centerRight,
            //           child: LabelText("Show:")
            //         )
            //       ),
            //       Expanded(
            //         flex: 1,
            //         child: Padding(
            //           padding: const EdgeInsets.only(left: 16.0, right:16.0),
            //           child: AppButton(
            //               onPressed: () => {},
            //               text: "All",
            //               paddingText: EdgeInsets.all(0),
            //               height: 36,
            //           ),
            //         ),
            //       )
            //     ],
            //   ),
            // ),
            /*
            Padding(
              padding: EdgeInsets.only(right: SizeConfig.safeBlockHorizontal*5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Show:  ',style: TextStyle(fontSize: SizeConfig.fontSize*1.3),),
                  Container(
                    height:32,
                    decoration: BoxDecoration(
                      color: AppColors.purpleVariant1,
                      border: Border.all(
                        color: AppColors.purpleVariant1,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal*2),
                      child: DropdownButton<String>(
                        alignment: AlignmentDirectional.center,
                        underline: Container(
                          color: Colors.transparent,
                        ),
                        value: selectedDate,
                        icon: Visibility(visible: false, child: Icon(Icons.arrow_downward),),
                        style: AppTextStyles.label.copyWith(fontSize: SizeConfig.fontSize*1.2),
                        onChanged: (String newValue){
                          if (newValue==null) newValue = 'LAST WEEK';
                          setState(() {
                            selectedDate = newValue;
                          });
                        },
                        items: <String>['LAST DAY','LAST WEEK','LAST MONTH'].map((String value){
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,textAlign: TextAlign.end,),
                          );
                        }).toList(),
                      ),
                    ),
                  ),],
              ),
            ),
            Text('Selected date: $selectedDate'),
            //Working as intended!
            */
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 20, left: 16.0),
                    child: Text(
                      "Transactions",
                      style: AppTextStyles.label,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.darkBlue),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder(
                        future: listTransactions(app.currentAccount.address, app),
                        builder: (BuildContext context, snapshot) {
                          if (snapshot.data == null) {
                            return Text("loading");
                          } else
                            return snapshot.data;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  String _totalBalance(AvmeWallet app) {
    List tokensValue = app.currentAccount.tokensBalanceList.entries.map((e) => e.value["balance"]).toList();

    double totalValue = app.currentAccount.networkBalance;

    tokensValue.forEach((value) => totalValue += value);

    print(tokensValue);
    return "${shortAmount(totalValue.toString(), comma: true, length: 7)}";
  }

  Future<Widget> listTransactions(String address, AvmeWallet app) async {
    SizeConfig().init(context);
    List transactionsMap = await TransactionInformation().fileTransactions(address);
    if (transactionsMap == null) {
      return Center(
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 1 / 2,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 2.5, horizontal: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text("😕",
                            style: TextStyle(
                              fontSize: SizeConfig.labelSize,
                            )),
                        SizedBox(
                          height: 6,
                        ),
                        Text("No recent activity to show.",
                            style: TextStyle(
                              fontSize: SizeConfig.labelSize * 0.6,
                            )),
                      ],
                    ),
                  ],
                ),
              )));
    }

    RegExp amountValidator = RegExp(r'\((.*?)\)', multiLine: false, caseSensitive: false);
    List<Widget> _widgetsList = [];

    transactionsMap.asMap().forEach((key, card) {
      DateTime date = DateTime.fromMicrosecondsSinceEpoch(card["unixDate"], isUtc: false);
      intl.DateFormat dateFormat = intl.DateFormat('MM/dd/yyyy hh:mm:ss');
      card["formatedAmount"] = weiToFixedPoint(amountValidator.firstMatch(card["value"]).group(1).replaceAll(" wei", ""));
      card["date"] = dateFormat.format(date);
      double tokenValue;
      try {
        if (card["tokenName"] == 'AVAX') {
          tokenValue = double.tryParse(app.networkToken.value) * double.tryParse(card["formatedAmount"]);
        } else {
          tokenValue = double.tryParse(app.activeContracts.token.tokenValue(card["tokenName"])) * double.tryParse(card["formatedAmount"]);
        }
      } catch (e) {
        card["tokenName"] = "N/A";
        tokenValue = 0.00;
        print(e);
      }
      _widgetsList.add(
        HistoryTable(
          sent: true,
          tokenAmount: "${shortAmount(card["formatedAmount"])} ${card["tokenName"]}",
          //TODO: Save the amount in money and retrieve to show how much was sent in dollars
          value: '\$${tokenValue.toStringAsFixed(2)}',
          date: card["date"],
          onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionDetails(card)))},
        ),
      );
      if (key != transactionsMap.length - 1) _widgetsList.add(Divider());
    });
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 3),
      child: ListView(
        shrinkWrap: true,
        children: _widgetsList,
      ),
    );
  }
}

class HistoryTable extends StatefulWidget {
  final bool sent;
  final String tokenAmount;
  final String date;
  final String value;
  final Function onTap;

  const HistoryTable({Key key, @required this.sent, @required this.tokenAmount, @required this.date, @required this.value, @required this.onTap})
      : super(key: key);

  @override
  _HistoryTableState createState() => _HistoryTableState();
}

class _HistoryTableState extends State<HistoryTable> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [widget.sent == true ? Icon(Icons.arrow_upward) : Icon(Icons.arrow_downward)],
                ),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.sent == true ? LabelText("SENT") : LabelText("RECEIVED"),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      widget.date,
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.value,
                      style: TextStyle(color: AppColors.lightBlue),
                    ),
                    Text(
                      "${widget.tokenAmount}",
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BalanceAndButtons extends StatefulWidget {
  final String totalBalance;
  final String difference;
  final Function onPressed;

  final Function onSendPressed;
  final Function onReceivePressed;
  final Function onBuyPressed;
  final DecorationTween balanceTween;

  BalanceAndButtons({
    Key key,
    @required this.totalBalance,
    @required this.onPressed,
    @required this.onSendPressed,
    @required this.onReceivePressed,
    @required this.onBuyPressed,
    this.difference = "+18,69% (\$0.00) today",
    this.balanceTween,
  }) : super(key: key);

  @override
  _BalanceAndButtonsState createState() => _BalanceAndButtonsState();
}

class _BalanceAndButtonsState extends State<BalanceAndButtons> {
  @override
  Widget build(BuildContext context) {
    AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);
    return AppCard(
      child: Column(
        children: [
          GradientContainer(
              decorationTween: widget.balanceTween,
              onPressed: () {},
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ///Fist Column with Data.
                    Flexible(
                      child: GestureDetector(
                        onTap: widget.onPressed,
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 8,
                              ),
                              Text("Current Balance", style: TextStyle(fontSize: SizeConfig.labelSize * 0.6)),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                "\$${widget.totalBalance}",
                                style: TextStyle(
                                  fontSize: SizeConfig.labelSize,
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              FutureBuilder(
                                future: difference(app),
                                builder: (BuildContext context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Text("+0% today",
                                        style: TextStyle(
                                          fontSize: SizeConfig.fontSize,
                                        ));
                                  } else {
                                    return Text("${snapshot.data} today",
                                        style: TextStyle(
                                          fontSize: SizeConfig.fontSize,
                                        ));
                                  }
                                },
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppNeonButton(
                  onPressed: widget.onSendPressed,
                  text: "SEND",
                  iconData: Icons.upload_sharp,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: AppNeonButton(
                  onPressed: widget.onReceivePressed,
                  text: "RECEIVE",
                  iconData: Icons.download_sharp,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: AppNeonButton(
                  onPressed: widget.onBuyPressed,
                  text: "BUY",
                  iconData: Icons.shopping_cart,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

Future<String> difference(AvmeWallet app) async {
  int counter = 0;
  double difference = 0, sum = 0, tokenValueToday, tempCalc = 0;
  List<double> tokenValuesYesterday = [], percentages = [];
  List<String> tokenNames = app.activeContracts.tokens;
  bool isThereBalance = false;
  //AVAX
  if (app.currentAccount.balance != '0') {
    isThereBalance = true;
    tokenValueToday = double.tryParse(app.networkToken.value);
    await ValueHistoryTable.instance.readAmount('AVAX', 1).then((value) {
      percentages.add((tokenValueToday / value.first.value.toDouble()) - 1);
      sum += (value.first.value.toDouble());
      tokenValuesYesterday.add(value.first.value.toDouble());
    });
  }
  //Other
  //tokenNames.forEach((element) async { //Doesn't work, since it will work and wait for the .forEach but won't wait for the await inside
  for (String element in tokenNames) {
    if (double.tryParse(app.currentAccount.tokenWei(name: element)) != 0) {
      isThereBalance = true;
      tokenValueToday = double.tryParse(app.activeContracts.token.tokenValue(element));
      await ValueHistoryTable.instance.readAmount(element, 1).then((value) {
        percentages.add((tokenValueToday / value.first.value.toDouble()) - 1);
        sum += (value.first.value.toDouble());
        tokenValuesYesterday.add(value.first.value.toDouble());
      });
    }
  }
  //Processing

  if (!isThereBalance) return '0%';

  for (double value in percentages) {
    tempCalc += value * tokenValuesYesterday.elementAt(counter);
    ++counter;
  }

  difference = (tempCalc / sum) * 100;

  return '${difference.toStringAsFixed(2)}%';
}
