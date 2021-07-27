import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/transaction_information.dart';
import '../widgets/transactions/display_card.dart';
import 'package:avme_wallet/app/screens/widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Transactions extends StatefulWidget {
  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  AvmeWallet appState;
  List<dynamic> transactions;
  @override
  Widget build(BuildContext context) {
    //Implement FutureBuilder in the list...
    appState = Provider.of<AvmeWallet>(context);
    return Shimmer(
      linearGradient: shimmerGradient,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          child: FutureBuilder(
            future: listTransactions(),
            builder: (BuildContext context, snapshot)
            {
              if(snapshot.data == null)
              {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: 3,
                  itemBuilder: (BuildContext context, int index) {
                    return DisplayCard(loading: true,);
                  },
                );
              }
              else return snapshot.data;
            },
          )
        ),
      ),
    );

  }


  Future<Widget> listTransactions() async
  {
    await Future.delayed(Duration(seconds: 1), (){});
    TransactionInformation _transactionInformation = TransactionInformation();
    Map<String, dynamic> transactionsMap = {};
    Map<String, dynamic> transactionData = {};
    transactionsMap = await _transactionInformation.fileTransactions(appState.currentAccount.address);
    if(transactionsMap == null)
    {
      return Center(child:
        Card(
          elevation: 8.0,
          child:
          SizedBox(
            width: MediaQuery.of(context).size.width / 1.5,
            child:  Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text("😕  ", style: TextStyle(
                  fontSize: 22)),
                Text("No transactions found."),
                ],
              ),
            )
          ),
        )
      );

    }
    transactions = transactionsMap["transactions"];
    RegExp amountValidator = RegExp(r'\((.*?)\)', multiLine: false, caseSensitive: false);
    List<Widget> _widgetsList = [];


    transactions.forEach((card) {
      DateTime date = DateTime.fromMicrosecondsSinceEpoch(card["unixDate"],isUtc: false);
      DateFormat dateFormat = DateFormat('MM-dd-yyyy hh:mm:ss');
      transactionData = card;
      transactionData["formatedAmount"] = weiToFixedPoint(amountValidator.firstMatch(card["value"]).group(1).replaceAll(" wei", "")) + " ETH";
      transactionData["date"] = dateFormat.format(date);
      print(card["to"]);
      _widgetsList.add(
        DisplayCard(data:transactionData)
      );
    });
    return ListView(children: _widgetsList,);
  }
}
