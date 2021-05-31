import 'package:avme_wallet/controller/globals.dart';
import 'package:avme_wallet/screens/helper.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/screens/widgets/custom_widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:hex/hex.dart';
import 'dart:math';

// stores ExpansionPanel state information
class AccountItemObjects {
  AccountItemObjects({
    this.expandedValue,
    this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<AccountItemObjects> _accounts = [];
// List<AccountItem> getAccountList(int qtdExample)
// {
//   List accounts = List<AccountItem>.generate(qtdExample, (index) {
//       var rnd = new Random();
//       String r = (999999 + rnd.nextInt(10000000 - 999999) * 999999).toString();
//       return AccountItem(
//           headerValue: "Account $index",
//           expandedValue: r,
//       );
//     }
//   );
//   return accounts;
// }

//

class Accounts extends StatefulWidget{
  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> with Helpers {

  BuildContext dialogContext;

  @override
  Widget build(BuildContext context) {
    Navigator.pop(dialogContext);
    return SingleChildScrollView(
      child: Container(
        child: _panelBuilder(),
      ),
    );
  }

  @override
  void initState()
  {
    if(_accounts.length == 0)
    {
      debugPrint("_accounts is empty, populating");
      for(int i = 0; i <= 10; i++)
      {
        // testeData.add(i.toString());
      }
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        showDialog(
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return SimpleWarning(
              text:
              "Loading Accounts");
        });

        debugPrint("anal");

      });
    }
    else
    {
      debugPrint(_accounts.length.toString());
    }
  }

  @override
  void createState()
  {
    debugPrint("createState called!");
  }


  // Our expansionPanel being built dynamically

  List<ExpansionPanel> _expansionPanelBuilder()
  {
    List<ExpansionPanel> _lista = [];

    _accounts.asMap().forEach((int index, AccountItemObjects account){
      ExpansionPanel _e = new ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(account.headerValue),
              // dense: true,
              // leading: Icon(Icons.vpn_key),
              onTap: () {
                setState(() {
                  closePanels();
                  account.isExpanded = !isExpanded;
                });
              },
              // trailing: Icon(Icons.security),
            );
          },
          body: ListTile(
            title: textCenter(account.expandedValue),
            // subtitle: Text(),
            leading: Icon(Icons.vpn_key),
            minLeadingWidth: 10,
            onTap: () {
              // insert set state if necessary
              snack("Account $index selected",context);
              setState(() {
                closePanels();
              });
            },
          ),
          isExpanded: account.isExpanded
      );
      _lista.add(_e);
    });
    return _lista;
  }

  void closePanels()
  {
    _accounts.asMap().forEach((int index, AccountItemObjects account) {
      _accounts[index].isExpanded = false;
    });
  }

  Widget _panelBuilder()
  {
    ExpansionPanelList listing = new ExpansionPanelList(
      expandedHeaderPadding: EdgeInsets.all(0),
      elevation: 0,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          closePanels();
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
