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
    this.balance = "0",
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
  String balance;
}

List<AccountItemObjects> _accounts = [];

class Accounts extends StatefulWidget{
  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts>
{
  List<int> rendered = [];
  AvmeWallet wallet;
  AppLoadingState loadState;
  @override
  void initState()
  {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    wallet = Provider.of<AvmeWallet>(context);
    loadState = Provider.of<AppLoadingState>(context);
    return SingleChildScrollView(
      child: Container(
        child:
        Selector<AvmeWallet,Map>
          (
          selector: (context, model) => model.accountList,
          builder: (context, accountList, child)
          {
            accountList.forEach((key, element) {
              if(loadState.accountsWasLoaded && _accounts.length < accountList.length)
              {
                _accounts.add(
                  AccountItemObjects(
                    expandedValue: accountList[key].address,
                    isExpanded: false,
                    headerValue: "Account #${key.toString()}"
                  )
                );
              }
            }
          );
          //Build the list
          return Container(

            child: _panelBuilder(),
            );
          }
        ),
      )
    );
  // Widget build(BuildContext context) {
  //   return SingleChildScrollView(
  //     child: Container(
  //       child:
  //       Consumer<AvmeWallet>
  //         (builder: (context, wallet, child) {
  //         List<Widget> accountListWidget = [];
  //
  //         accountListWidget.add(Text("${wallet.accountList.length.toString()} Amount."));
  //
  //         // for(int i = 0; i < wallet.accountList.length; i++) {
  //         // wallet.accountList.forEach((element) {
  //         wallet.accountList.forEach((key, element) {
  //           // accountListWidget.add(Text("Address: ${wallet.accountList[key].address} \r\n Path :${wallet.accountList[key].accountPath}"));
  //           // accountListWidget.add(SizedBox(width: 10,height: 10,));
  //           if((_accounts.length < wallet.accountList.length) && rendered.contains(key) == false)
  //           // if(_accounts.length < wallet.accountList.length && !rendered.contains(key))
  //           {
  //             _accounts.add(
  //                 AccountItemObjects(
  //                     expandedValue: wallet.accountList[key].address,
  //                     isExpanded: false,
  //                     headerValue: key.toString()));
  //             rendered.add(key);
  //             print("Contains:" + rendered.contains(key).toString());
  //             print(rendered.toString());
  //           }
  //           print(_accounts.length.toString());
  //           print("${wallet.accountList[0].address}");
  //         });
  //         //Build the list
  //         accountListWidget.add(_panelBuilder(wallet));
  //         return Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: accountListWidget,
  //         );
  //         }
  //       ),
  //     )
  //   );

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
              snack("Account #$index selected",context);
              wallet.walletManager.selectedAccount = index;
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
    );
    return listing;
  }
}
