import 'package:avme_wallet/screens/helper.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/controller/globals.dart' as global;
import 'package:avme_wallet/main.dart';
import 'package:avme_wallet/screens/widgets/colored_tab_bar.dart';
class TabsWallet extends StatefulWidget {
  @override
  _TabsWalletState createState() => _TabsWalletState();
}

class _TabsWalletState extends State<TabsWallet> with Helpers {
  BuildContext _this;

  @override
  Widget build(BuildContext context) {
    _this = context;
    // return DefaultTabController(
    //   initialIndex: 1,
    //   length: 4,
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: Text(global.appTitle),
    //       actions: [
    //         PopupMenuButton(
    //           onSelected: _popupMenuButtom,
    //           itemBuilder: (BuildContext context)
    //           {
    //             return {'Logout','Settings'}.map((String choice) {
    //               return PopupMenuItem<String>(
    //                 value: choice,
    //                 child: Text(choice),
    //               );
    //             }).toList();
    //           },
    //         )
    //       ],
    //       bottom: TabBar(
    //         isScrollable: true,
    //         tabs: <Widget>[
    //           Tab(
    //             text: "ACCOUNTS",
    //           ),
    //           Tab(
    //             text: "BALANCE",
    //           ),
    //           Tab(
    //             text: "TRANSACTIONS",
    //           ),
    //           Tab(
    //             text: "DEBUG OPTIONS",
    //           ),
    //         ],
    //       ),
    //     ),
    //     body: TabBarView(
    //       children: <Widget>[
    //         Center(
    //           child: Text('ACCOUNTS WIDGET HERE'),
    //         ),
    //
    //         Center(
    //           child: Text('BALANCE WIDGET HERE'),
    //         ),
    //
    //         Center(
    //           child: Text('TRANSACTIONS WIDGET HERE'),
    //         ),
    //
    //         Options(),
    //       ],
    //     ),
    //   ),
    // );
    return DefaultTabController(
      initialIndex: 1,
      length: 4,
      child: Scaffold(
        // Testing transparency
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(global.appTitle),
          // Testing transparency, removes shadow
          elevation: 0,
          backgroundColor: Color(0x81000000),
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
          bottom: ColoredTabBar(
            Color(0x23FFFFFF),
            TabBar(
              isScrollable: true,
              tabs: [
                Tab(
                  text: "ACCOUNTS",
                ),
                Tab(
                  text: "BALANCE",
                ),
                Tab(
                  text: "TRANSACTIONS",
                ),
                Tab(
                  text: "DEBUG OPTIONS",
                ),
              ],
            ),
          ),
        ),
        body:
          Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg2_alt.jpg"),
              fit: BoxFit.cover
            )
          ),
          child:
            SafeArea(
              child:
                TabBarView(
                children: <Widget>[
                  Center(
                    child: Text('ACCOUNTS WIDGET HERE'),
                  ),
                  // Container(
                  //   child: Text("aaaas"),
                  // ),

                  Center(
                    child: Text('BALANCE WIDGET HERE'),
                  ),

                  Center(
                    child: Text('TRANSACTIONS WIDGET HERE'),
                  ),
                  Options(),
                ],
              )
          ),
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
