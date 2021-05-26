import 'package:avme_wallet/screens/helper.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/screens/widgets/custom_widgets.dart';

// stores ExpansionPanel state information
class AccountItem {
  AccountItem({
    this.expandedValue,
    this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<AccountItem> getAccountList(int qtdExample)
{
  List accounts = List<AccountItem>.generate(qtdExample, (index) =>
      AccountItem(
          headerValue: "Account $index",
          expandedValue: "Account data, exemple some short key here"
      )
  );
  return accounts;
}

//

class Accounts extends StatefulWidget{
  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> with Helpers {
  List<AccountItem> _accounts = getAccountList(10);
  @override
  Widget build(BuildContext context) {
    // ListView _accountList = forms(
    //     [
    //       Text("ACCOUNT 1"),
    //       Text("ACCOUNT 2"),
    //       Text("ACCOUNT 3")
    //     ], horizontal: 10, vertical: 0
    // );
    return SingleChildScrollView(
      child: Container(
        child: _panelBuilder(),
      ),
    );
  }

  // Our expansionPanel being built dynamically

  List<ExpansionPanel> _expansionPanelBuilder()
  {
    List<ExpansionPanel> _lista = [];

    _accounts.asMap().forEach((int index, AccountItem accounts){
      ExpansionPanel _e = new ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(accounts.headerValue),
            );
          },
          body: ListTile(
            title: Text(accounts.expandedValue),
            // subtitle: Text(),
            onTap: () {
              // insert set state if necessary
              snack("Tapped $index",context);
              setState(() {

              });
            },
          ),
          isExpanded: accounts.isExpanded
      );
      _lista.add(_e);
    });
    return _lista;
  }

  Widget _panelBuilder()
  {
    ExpansionPanelList listing = new ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          //Captures the click action and swap between expanded or not
          _accounts[index].isExpanded = !isExpanded;
        });
      },
      //Build the ExpansionPanel (item) for each element in our _accounts
      children: _expansionPanelBuilder().toList(),

      // children:
      //
      //
      //   _accounts.map((AccountItem account){
      //   ExpansionPanel _expansionPanel = new ExpansionPanel(
      //     headerBuilder: (BuildContext context, bool isExpanded){
      //       return new ListTile(
      //         title: Text(account.headerValue),
      //       );
      //     },
      //     body: new ListTile(
      //       title: Text(account.expandedValue),
      //       subtitle: Text("This is a subtitle..."),
      //       onTap: (){
      //         snack("Element ",context);
      //       },
      //     ));
      //   return _expansionPanel;
      // }),
    );
    return listing;
  }
}
