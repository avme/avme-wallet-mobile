import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/transaction_information.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:avme_wallet/app/screens/widgets/transaction_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistorySnippet extends StatefulWidget {
  final TabController appScaffoldTabController;
  final AvmeWallet app;
  const HistorySnippet({Key key, @required this.appScaffoldTabController, @required this.app}) : super(key: key);

  @override
  _HistorySnippetState createState() => _HistorySnippetState();
}

class _HistorySnippetState extends State<HistorySnippet> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text("History",style: TextStyle(fontSize: SizeConfig.labelSize*0.8),),
          SizedBox(
            height: 12,
          ),
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.darkBlue
              ),
               child: FutureBuilder(
                 future: listTransactions(widget.app.currentAccount.address),
                 builder: (BuildContext context, snapshot)
                 {
                   if(snapshot.data == null)
                   {
                     return Text("loading");
                   }
                   else return snapshot.data;
                 },
               ),
          ),
          SizedBox(
            height: 12,
          ),
          AppNeonButton(onPressed: () => widget.appScaffoldTabController.index = 2, text: "SHOW FULL HISTORY"),
        ],
      ),
    );
  }

  Future<Widget> listTransactions(String address) async
  {
    List transactionsMap = await TransactionInformation().fileTransactions(address, amount: 5);
    if(transactionsMap == null)
    {
      return Center(child:
      SizedBox(
          width: MediaQuery.of(context).size.width * 1 / 2,
          child:  Padding(
            padding: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical*2.5,horizontal: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text("😕",
                        style: TextStyle(
                            fontSize: SizeConfig.labelSize,)
                    ),
                    SizedBox(height: 6,),
                    Text("No recent activity to show.",
                        style: TextStyle(
                          fontSize: SizeConfig.labelSize*0.6,)),
                  ],
                ),
              ],
            ),
          )
      )
      );
    }

    RegExp amountValidator = RegExp(r'\((.*?)\)', multiLine: false, caseSensitive: false);
    List<Widget> _widgetsList = [];

    transactionsMap.asMap().forEach((key,card) {
      DateTime date = DateTime.fromMicrosecondsSinceEpoch(card["unixDate"],isUtc: false);
      DateFormat dateFormat = DateFormat('MM/dd/yyyy');
      card["formatedAmount"] = shortAmount(weiToFixedPoint(amountValidator.firstMatch(card["value"]).group(1).replaceAll(" wei", ""),),length: 4, comma: true);
      card["date"] = dateFormat.format(date);
      _widgetsList.add(
          HistoryTable(
            amount: "${shortAmount(card["formatedAmount"])} AVME",
            sent: true,
            date: card["date"],
          ),
      );
      if(key != transactionsMap.length - 1)
        _widgetsList.add(
            Divider()
        );
    });
    return Column(
      children: _widgetsList,
    );
  }

}


class HistoryTable extends StatefulWidget {

  final bool sent;
  final String amount;
  final String date;
  const HistoryTable(
  {
    Key key,
    @required this.sent,
    @required this.amount,
    @required this.date
  }) : super(key: key);

  @override
  _HistoryTableState createState() => _HistoryTableState();
}

class _HistoryTableState extends State<HistoryTable> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: widget.sent == true ? Icon(Icons.arrow_upward) : Icon(Icons.arrow_downward),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left:12.0),
              child: widget.sent == true ? Text("SENT") : Text("RECEIVED"),
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(child: Text(widget.date)),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.sent == true ?
                Text("-${widget.amount}", style: TextStyle(color: AppColors.lightBlue),) :
                Text("+${widget.amount}", style: TextStyle(color: AppColors.purple)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
