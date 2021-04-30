import 'package:avme_wallet/screens/helper.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/controller/globals.dart' as global;
class TabsWallet extends StatelessWidget with Helpers{
  BuildContext _this;
  @override
  Widget build(BuildContext context) {
    _this = context;
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(global.appTitle),
          actions: [
            PopupMenuButton(
              onSelected: _popupMenuButtom,
              itemBuilder: (BuildContext context)
              {
                return {'Logout','Settings'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(
                text: "ACCOUNTS",
              ),
              Tab(
                text: "BALANCE",
              ),
              Tab(
                text: "TRANSACTIONS",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Center(
              child: Text('ACCOUNTS WIDGET HERE'),
            ),
            Center(
              child: Text('BALANCE WIDGET HERE'),
            ),
            Center(
              child: Text('TRANSACTIONS WIDGET HERE'),
            ),
          ],
        ),
      ),
    );
  }

  void _popupMenuButtom(String val)
  {
    //Switch
    snack(val, _this);
  }
}
