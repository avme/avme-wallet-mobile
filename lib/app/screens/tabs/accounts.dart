import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:provider/provider.dart';

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

class Accounts extends StatefulWidget{
  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts>
{
  @override
  Widget build(BuildContext context) {
    // Navigator.pop(dialogContext);
    return
      Consumer<AvmeWallet>
        (builder: (context, wallet, child) {
          List<Widget> accountListWidget = [];

          accountListWidget.add(Text("${wallet.accountList.length.toString()} Amount."));

          // for(int i = 0; i < wallet.accountList.length; i++) {
          // wallet.accountList.forEach((element) {
          wallet.accountList.forEach((key, element) {
            // accountListWidget.add(Text("Address: ${wallet.accountList[key].address} \r\n Path :${wallet.accountList[key].accountPath}"));
            // accountListWidget.add(SizedBox(width: 10,height: 10,));
            if(_accounts.length < wallet.accountList.length)
            {
              _accounts.add(
                  AccountItemObjects(
                      expandedValue: wallet.accountList[key].address,
                      isExpanded: false,
                      headerValue: key.toString()));
            }
            // print(_accounts.length.toString());
            print("${wallet.accountList[0].address}");
          });

          return SingleChildScrollView(
            child: Container(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: accountListWidget,
              ),
            ),
          );
      });
  }

  @override
  void initState()
  {
    super.initState();
    // loadWalletView();
  }

  void loadWalletView()
  {
    // if(_accounts.length == 0)
    // {
    //   print("_accounts is empty, populating");
    //   // for(int i = 0; i <= 10; i++)
    //   int i = 0;
    //   globals.accountList.forEach((element) {
    //     print(element.accountPath);
    //     _accounts.add(
    //         AccountItemObjects(
    //             expandedValue: element.address,
    //             isExpanded: false,
    //             headerValue: i.toString()));
    //     i++;
    //   });
    // }
  }

  // Our expansionPanel being built dynamically

  // List<ExpansionPanel> _expansionPanelBuilder()
  // {
  //   List<ExpansionPanel> _lista = [];
  //
  //   _accounts.asMap().forEach((int index, AccountItemObjects account){
  //     ExpansionPanel _e = new ExpansionPanel(
  //         headerBuilder: (BuildContext context, bool isExpanded) {
  //           return ListTile(
  //             title: Text(account.headerValue),
  //             // dense: true,
  //             // leading: Icon(Icons.vpn_key),
  //             onTap: () {
  //               setState(() {
  //                 closePanels();
  //                 account.isExpanded = !isExpanded;
  //               });
  //             },
  //             // trailing: Icon(Icons.security),
  //           );
  //         },
  //         body: ListTile(
  //           title: textCenter(account.expandedValue),
  //           // subtitle: Text(),
  //           leading: Icon(Icons.vpn_key),
  //           minLeadingWidth: 10,
  //           onTap: () {
  //             // insert set state if necessary
  //             snack("Account #$index selected",context);
  //             globals.walletManager.selectedAccount = index;
  //             setState(() {
  //               closePanels();
  //             });
  //           },
  //         ),
  //         isExpanded: account.isExpanded
  //     );
  //     _lista.add(_e);
  //   });
  //   return _lista;
  // }

  void closePanels()
  {
    _accounts.asMap().forEach((int index, AccountItemObjects account) {
      _accounts[index].isExpanded = false;
    });
  }

  // Widget _panelBuilder()
  // {
  //   ExpansionPanelList listing = new ExpansionPanelList(
  //     expandedHeaderPadding: EdgeInsets.all(0),
  //     elevation: 0,
  //     expansionCallback: (int index, bool isExpanded) {
  //       setState(() {
  //         closePanels();
  //         //Captures the click action and swap between expanded or not
  //         _accounts[index].isExpanded = !isExpanded;
  //       });
  //     },
  //     //Build the ExpansionPanel (item) for each element in our _accounts
  //     children: _expansionPanelBuilder().toList(),
  //   );
  //   return listing;
  // }
}
