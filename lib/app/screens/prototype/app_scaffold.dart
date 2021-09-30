import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/accounts_drawer.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'overview.dart';


class AppScaffold extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<AppScaffold>
    with SingleTickerProviderStateMixin{

  TabController appScaffoldTabController;

  ///We build two lists, one with labels and another with routes,
  ///sadly theres no other way to bypass a TabController when a
  ///child widget needs a TabController reference, so we use
  ///a list of labels to construct the tab length, and before
  ///the build method kicks in, we make a Map<String,Widget>

  List<String> routeLabels = [
    'About', 'Overview', 'History'
  ];

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
      Center(
        child: Text(
          'History',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ];

    appScaffoldTabController.addListener(() {
      ///Empty setstate to update our selected tab
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    appScaffoldTabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("AppScaffold was builded");
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
      endDrawer: AccountsDrawer(appState: getAppState(context),),
      body: AppTabBar(
        padding: appBarWidth,
        routeLabels: this.routeLabels,
        routeWidgets: this.routeWidgets,
        appScaffoldTabController: this.appScaffoldTabController,
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
                tabs: getTabLabels(widget.appScaffoldTabController)
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

  // List<Widget> getTabWidgets()
  // {
  //   List<Widget> _tabs = [];
  //   widget.tabs.forEach((key, widget) {
  //     _tabs.add(widget);
  //   });
  //   return _tabs;
  // }

  List<Widget> getTabLabels(TabController tabController)
  {
    List<Widget> _labels = [];
    int pos = 0;
    widget.routeLabels.forEach((key) {
      _labels.add(
        Tab(
          child:
            Row(
              // crossAxisAlignment: CrossAxisAlignment,
              mainAxisAlignment: pos == 0 ? MainAxisAlignment.start : pos != widget.routeLabels.length - 1 ? MainAxisAlignment.center : MainAxisAlignment.end,
              // mainAxisSize: MainAxisSize.min,
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
        );
      pos++;
    });
    return _labels;
  }
}


