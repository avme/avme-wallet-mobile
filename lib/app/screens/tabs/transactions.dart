import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/transaction_information.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Transactions extends StatefulWidget {
  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  AvmeWallet appState;
  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AvmeWallet>(context);
    // int qtd = hasTransactions();
    return Center(
      child: 1 > 0 ? Text("Implementar listagem de transações") : Text('No transactions found.'),
    );
  }
  // Future<int> hasTransactions() async
  // {
  //   // String address = appState.currentAccount.address;
  //   TransactionInformation _transactionInformation = TransactionInformation();
  //   _transactionInformation.fileTransactions(appState.currentAccount.address);
  //   return _transactionInformation.qtdTransactions;
  // }
}
