import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/accounts_state.dart';
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

class AccountsOld extends StatefulWidget{
  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<AccountsOld>
{
  AvmeWallet wallet;
  BuildContext loadingDialog;

  @override
  void initState()
  {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    wallet = Provider.of<AvmeWallet>(context);

    if(!wallet.accountsState.accountsWasLoaded && loadingDialog == null)
    {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            loadingDialog = context;
            return CircularLoading(text: "Loading accounts.");
          },
        );
      });
    }
    return SingleChildScrollView(
      child: Container(
        child:
        Selector<AvmeWallet, AccountsState>
          (
          selector: (context, model) => model.accountsState,
          builder: (context, accountsState, child)
          {
            if(accountsState.accountsWasLoaded && _accounts.length < wallet.accountList.length)
            {
              wallet.accountList.forEach((key, element) {
                _accounts.add(
                    AccountItemObjects(
                        expandedValue: wallet.accountList[key].address,
                        isExpanded: false,
                        headerValue: "Account #${key.toString()}"
                    )
                );
              });
              if(loadingDialog != null)
              {
                Navigator.pop(loadingDialog);
              }
            }
            return Container(
              child: _panelBuilder(),
            );
          }
        ),
      )
    );
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
            // title: textCenter(account.expandedValue),
            title: Text(account.expandedValue, textAlign: TextAlign.center),
            // subtitle: Text(),
            leading: Icon(Icons.vpn_key),
            minLeadingWidth: 10,
            onTap: () {
              // insert set state if necessary
              snack("Account #$index selected",context);
              wallet.changeCurrentWalletId = index;
              wallet.killService("watchBalanceChanges");
              wallet.killService("watchTokenChanges");
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
