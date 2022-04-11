import 'dart:convert';

import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/widgets/accounts/account_card.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/shimmer.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Accounts extends StatefulWidget {
  @override
  _AccountsState createState() => _AccountsState();
}
//TODO: Refactor this code
class _AccountsState extends State<Accounts> {
  AvmeWallet appState;

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AvmeWallet>(context);
    print(appState.accountList.keys);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                child: LabelText("Accounts:"),
                padding: EdgeInsets.only(bottom: 8)
              )
            ],
          ),
          Shimmer(
            linearGradient: shimmerGradientDefault,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
                child: FutureBuilder<List>(
                  future: accountsList(),
                  builder: (context, snapshot) {
                    if(snapshot.data == null)
                    {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: 3,
                        itemBuilder: (BuildContext context, int index) {
                          return AccountCard(loading: true,);
                        },
                      );
                    }
                    else
                    {
                      snapshot.data
                        ..add(Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                          child: Center(
                            child:
                            Container(
                              // color: Colors.red,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: avmeTheme.cardColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black45,
                                      spreadRadius: 0,
                                      offset: Offset(0,5),
                                      blurRadius: 10,
                                    )
                                  ]
                              ),
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      primary: Colors.white
                                  ),
                                  onPressed: () async => await newAccountDialog(context),
                                  child: Icon(Icons.add),
                                ),
                              ),
                            ),
                          ),
                        )
                      );
                      //   ..add(
                      //   Center(
                      //     child: ElevatedButton(child: Text("Spawn Isolates"),
                      //       onPressed: (){
                      //         appState.walletManager.getBalanceToAllAccounts(appState);
                      //       },
                      //     ),
                      //   )
                      // );

                      return ListView(
                        children: snapshot.data,
                      );
                    }
                  }
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List> accountsList() async
  {
    List<Widget> ret = [];
    await Future.delayed(Duration(seconds: 1));
    appState.accountList.forEach((key,account) {
      bool selected = key == appState.currentWalletId ? true : false;
      ret.add(
          GestureDetector(
            child: AccountCard(data: account, selected: selected,),
            onTap: (){
              setState(() {
                snack("Account #$key selected",context);
                appState.selectedId = key;
              });
            },
          )
      );
    });
    return ret;
  }

  List<Widget> repeatWidgetList(Widget widget, int amount)
  {
    List<Widget> ret = [];
    for(int i = 0; i < amount; i++) ret.add(widget);
    return ret;
  }

  Future<void> newAccountDialog(BuildContext context) async
  {
    return await showDialog(context: context,
      builder: (context)
      {
        final TextEditingController _title = TextEditingController();
        final TextEditingController _password = TextEditingController();
        bool isChecked = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _title,
                      validator: (value)
                      {
                        return value.isEmpty ? "Invalid Label" : null;
                      },
                      decoration: InputDecoration(hintText: "Account Label"),
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: _password,
                      validator: (value)
                      {
                        return value.isEmpty ? "Please enter your password." : null;
                      },
                      decoration: InputDecoration(hintText: "Password",),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Make this my default account"),
                        Checkbox(
                          value: isChecked,
                          onChanged: (value) {
                            setState((){
                              isChecked = value;
                            });
                        })
                      ],
                    )
                  ],
                ),),
              actions: <Widget>[
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel")
                ),
                TextButton(
                  onPressed: () async {
                    if(_formKey.currentState.validate())
                    {
                      Map ret = await appState.walletManager.authenticate(_password.text, appState);
                      print(jsonEncode(ret));
                      if(ret["status"] != 200)
                      {
                        await showDialog<void>(
                          context: context,
                          builder: (BuildContext context) =>
                            SimpleWarning(
                              title: "Warning",
                              text:
                              // "Wrong password, try again."
                              ret["message"]
                            )
                        );
                      }
                      else
                      {
                        await appState.walletManager.makeAccount(_password.text, appState, title: _title.text);
                        Navigator.of(context).pop();
                        await showDialog<void>(
                          context: context,
                          builder: (BuildContext context) =>
                            SimpleWarning(title: "Attention!", text: "A new account was added!",)
                        );
                      }
                    }
                  },
                  child: Text("OK")
                ),
              ],
            );
          }
        );
    });
  }
}

