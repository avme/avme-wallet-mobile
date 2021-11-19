import 'dart:async';

import 'package:avme_wallet/app/controller/services/connection.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/contacts.dart';
import 'package:avme_wallet/app/screens/prototype/history.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/accounts_drawer.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/debug.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:avme_wallet/app/screens/prototype/send.dart';
import 'overview.dart';


class AppScaffold extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<AppScaffold>
    with SingleTickerProviderStateMixin{

  TabController appScaffoldTabController;
  StreamSubscription _connectionChangeStream;
  AppConnection appConnection;
  bool connectionStatus = false;
  ConnectivityResult connectionType = ConnectivityResult.none;
  ///We build two lists, one with labels and another with routes,
  ///sadly theres no other way to bypass a TabController when a
  ///child widget needs a TabController reference, so we use
  ///a list of labels to construct the tab length, and before
  ///the build method kicks in, we make a Map<String,Widget>

  List<String> routeLabels = [
    'About', 'Overview', 'History', 'Send', 'Contacts', 'Exchange'];

  List<Widget> routeWidgets;

  @override
  void initState() {

    appScaffoldTabController = TabController(
      length: this.routeLabels.length,
      vsync: this,
      initialIndex: 1
    );

    routeWidgets = [
      //About
      Center(
        child: Text(
          'About',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      //Overview
      Overview(
        appScaffoldTabController: this.appScaffoldTabController,
      ),

      //History
      History(
        appScaffoldTabController: this.appScaffoldTabController,
      ),

      //Send
      Send(
        appScaffoldTabController: this.appScaffoldTabController,
      ),

      //Contacts
      Contacts(

      ),

      //Exchange
      Center(
        child: Text(
          'Exchange',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ];

    appScaffoldTabController.addListener(() {
      ///Empty setState to update our selected tab
      setState(() {});
    });

    appConnection = AppConnection.getInstance();
    connectionStatus = appConnection.hasConnection;
    connectionType = appConnection.connectivityResult;
    // _connectionChangeStream = appConnection.connectionChange.listen(connectionChanged);
    _connectionChangeStream = appConnection.connectionType.listen(connectionTypeChanged);

    super.initState();
  }

  void connectionChanged(dynamic connectionData)
  {
    setState(() {
      connectionStatus = connectionData[0];
      final color = connectionData[0] ? Colors.green : Colors.red;
      final message = connectionData[0] ? "Internet Connection restored" : "Lost internet connection";
      showSimpleNotification(
        Text(message),
        background: color
      );
    });
  }

  void connectionTypeChanged(dynamic connectionData)
  {
    setState(() {
      connectionType = connectionData[1];
      if(connectionData[1] == ConnectivityResult.wifi)
        showSimpleNotification(
          Text("Using a wifi connection"),
          background: Colors.green
        );
      else if(connectionData[1] == ConnectivityResult.mobile)
        showSimpleNotification(
          Text("Using a Mobile connection"),
          background: Colors.orange
        );
      else if(connectionData[1] == ConnectivityResult.none)
        showSimpleNotification(
            Text("Disconnected from the internet"),
            background: Colors.red
        );
    });
  }

  @override
  void dispose() {
    appScaffoldTabController.dispose();
    appConnection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double appBarWidth = 24;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: AppColors.labelDefaultColor
        ),
        titleSpacing: appBarWidth,

        ///We're populating this property with a Row widget and a Pad widget to
        ///match the original design, since flutter doesn't allow any widget
        ///besides PreferredSizeWidget and AppState.

        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(
              builder: (BuildContext context) {
                return AppBarButton(
                  mainAxisAlignment: MainAxisAlignment.start,
                  onPressed: (){
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icon(Icons.menu, size: 34,),
                );
              },
            ),
            Center(
              child: Image.asset(
                'assets/resized-newlogo02-trans.png',
                width: MediaQuery.of(context).padding.top + kToolbarHeight * 1 / 8,
                fit: BoxFit.fitHeight,)
            ),
            ///Changing Icon in the second drawer
            Builder(
              builder: (BuildContext context) {
                return AppBarButton(
                  mainAxisAlignment: MainAxisAlignment.end,
                  onPressed: (){
                    Scaffold.of(context).openEndDrawer();
                  },
                  icon: Icon(Icons.account_circle_outlined, size: 34,),
                );
              },
            ),
          ],
        ),
        ///We set a empty container to overwrite the "auto" hamburger/menu icon
        actions: [
          Container(),
        ],
      ),
      ///Drawer in the Left Side
      // drawer: AppDrawer({"Example 1" : Container()}),
      ///Drawer in the Right Side
      // endDrawer: AppDrawer({"Example 1" : Container()}),
      endDrawer: Consumer<AvmeWallet>(
        builder: (context, app, _){
          return AccountsDrawer(app: app,);
        },
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppTabBar(
            padding: appBarWidth,
            routeLabels: this.routeLabels,
            routeWidgets: this.routeWidgets,
            appScaffoldTabController: this.appScaffoldTabController,
          ),
            DebugOverlay(
              connected: connectionStatus,
              connectionType: connectionType,
            )
        ],
      ),
    );
  }
}

class AppBarButton extends StatelessWidget {
  final Function onPressed;
  final MainAxisAlignment mainAxisAlignment;
  final Icon icon;
  const AppBarButton({@required this.onPressed, @required this.mainAxisAlignment, @required this.icon});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: this.onPressed,
      child: SizedBox(
        width: MediaQuery.of(context).padding.top + kToolbarHeight * 1 / 1.5,
        height: MediaQuery.of(context).padding.top + kToolbarHeight * 1 / 2,
        child: Container(
          child: Row(
            mainAxisAlignment: this.mainAxisAlignment,
            children: [
              this.icon
            ],
          )
        ),
      ),
    );
  }
}


class AppTabBar extends StatefulWidget {
  // final Map<String, Widget> tabs;
  final List<String> routeLabels;
  final List<Widget> routeWidgets;
  
  final double padding;
  final TabController appScaffoldTabController;
  const AppTabBar({
    @required this.padding,
    @required this.appScaffoldTabController,
    @required this.routeLabels,
    @required this.routeWidgets
  });
  @override
  _AppTabBarState createState() => _AppTabBarState();
}

class _AppTabBarState extends State<AppTabBar> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: widget.padding),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: AppColors.purple,
                    width: 2
                )
              )
            ),
            child: Theme(
              data: avmeTheme.copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: TabBar(
                labelPadding: EdgeInsets.only(top:8),
                controller: widget.appScaffoldTabController,
                isScrollable: true,
                indicator: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.purple,
                      width: 2
                    )
                  )
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.labelDisabledColor,
                tabs: getTabLabels(context, widget.appScaffoldTabController)
              ),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: widget.appScaffoldTabController,
            children: widget.routeWidgets
          ),
        ),
      ]
    );
  }
  List<Widget> getTabLabels(BuildContext context, TabController tabController)
  {
    List<Widget> _labels = [];
    int pos = 0;
    widget.routeLabels.forEach((key) {
      ///Alignment validation
      MainAxisAlignment alignment = MainAxisAlignment.center;
      ///Current disabled due to bad usage when rendering, causing misalignment
      // if (tabController.index > 0 && tabController.index != widget.routeLabels.length - 1)
      // {
      //   if(pos == (tabController.index - 1))
      //   {
      //     alignment = MainAxisAlignment.start;
      //   }
      //   else if(pos == (tabController.index + 1))
      //   {
      //     alignment = MainAxisAlignment.end;
      //   }
      //   else
      //   print("im in the between");
      // }
      // else if(tabController.index == 0)
      // {
      //   if(pos == (tabController.index + 2))
      //     alignment = MainAxisAlignment.end;
      //   else if (pos == tabController.index)
      //     alignment = MainAxisAlignment.start;
      // }
      // else
      // {
      //   if(pos == (tabController.index - 2))
      //     alignment = MainAxisAlignment.start;
      //   else if (pos == tabController.index)
      //     alignment = MainAxisAlignment.end;
      // }

      _labels.add(
        Tab(
          child:
            Container(
              width: (MediaQuery.of(context).size.width / 10 * 8.633) / 3,
              child: Row(
                // mainAxisAlignment: pos == 0 ? MainAxisAlignment.start : pos != widget.routeLabels.length - 1 ? MainAxisAlignment.center : MainAxisAlignment.end,
                mainAxisAlignment: alignment,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        6.0,
                      ),
                      color: pos == tabController.index ? AppColors.cardDefaultColor : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4
                      ),
                      child: Text(
                        "$key",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      pos++;
    });
    return _labels;
  }
}


