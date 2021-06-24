import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionDetailsCard extends StatelessWidget {

  TransactionDetailsCard({this.title, this.subtitle, this.icon});

  final String title;
  final dynamic subtitle;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: ListTile(
        leading: icon != null ? Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon
          ],
        ) : null,
        title: Text("${this.title}"),
        subtitle: Text("${this.subtitle}"),
        onTap: () => copyToClipboard(context,["${this.title}","${this.subtitle}"]),
      ),
    );
  }

  void copyToClipboard(BuildContext context, List<String> data) async
  {
    await Clipboard.setData(ClipboardData(text: "${data[0]}: ${data[1]}"));
    snack("Copied \"${data[0]}\" to clipboard.",context);
  }
}

class TransactionDetails extends StatelessWidget {

  TransactionDetails(this.transactionData);
  final Map <String, dynamic> transactionData;
  
  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    items.add(SizedBox(height: 8,));
    items.add(TransactionDetailsCard(title: "Operation", subtitle: this.transactionData["operation"],));
    items.add(TransactionDetailsCard(title: "From", subtitle: this.transactionData["from"],));
    items.add(TransactionDetailsCard(title: "To", subtitle: this.transactionData["to"],));
    items.add(TransactionDetailsCard(title: "Value", subtitle: this.transactionData["formatedAmount"],));
    items.add(TransactionDetailsCard(title: "Gas", subtitle: this.transactionData["gas"],));
    items.add(TransactionDetailsCard(title: "Price", subtitle: this.transactionData["gasPrice"],));
    items.add(TransactionDetailsCard(title: "Timestamp", subtitle: this.transactionData["date"],));
    items.add(TransactionDetailsCard(title: "Confirmed", subtitle: this.transactionData["confirmed"],));
    items.add(TransactionDetailsCard(title: "Invalid", subtitle: this.transactionData["invalid"],));
    items.add(SizedBox(height: 8,));
    return Scaffold(
        appBar: AppBar(title:Text("Transaction Details")),
        body: ListView(
          children: items,
        )
    );
  }
}

