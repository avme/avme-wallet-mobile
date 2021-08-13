import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/drawer_scaffold.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColors.labelDefaultColor
        ),
        title:
          Center(
            child: Image.asset(
              'assets/resized-newlogo02-trans.png',
              width: MediaQuery.of(context).padding.top + kToolbarHeight * 1 / 8,
              fit: BoxFit.fitHeight,)
          ),
        ///Changing Icon in the second drawer
        actions: [
          Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: (){
                  Scaffold.of(context).openEndDrawer();
                },
                child: Icon(Icons.account_circle_outlined,
                  size: 38,)
              );
            },
          )
        ],
      ),
      ///Drawer in the Left Side
      drawer: AppDrawer({"Example 1" : Container()}),
      ///Drawer in the Right Side
      endDrawer: AppDrawer({"Example 1" : Container()}),
      body: AppTabBar(
        tabs: {
          'About' : Center(
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          'Overview' : Center(
            child: Text(
              'Overview',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          'History' : Center(
            child: Text(
              'History',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        }
      ),
    );
  }
}

class AppTabBar extends StatefulWidget {
  final Map<String, Widget> tabs;

  const AppTabBar({@required this.tabs});
  @override
  _AppTabBarState createState() => _AppTabBarState();
}

class _AppTabBarState extends State<AppTabBar>
    with SingleTickerProviderStateMixin {

  TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: widget.tabs.length, vsync: this);
    _tabController.addListener(() {
      ///Empty setstate to update our selected tab
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
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
                controller: _tabController,

                indicator: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.purple,
                      width: 2
                    )
                  )
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.labelDefaultColor,
                tabs: getTabLabels(_tabController)
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: getTabList()
            ),
          ),
        ]
      )
    );
  }

  List<Widget> getTabList()
  {
    List<Widget> _tabs = [];
    widget.tabs.forEach((key, widget) {
      _tabs.add(widget);
    });
    return _tabs;
  }

  List<Widget> getTabLabels(TabController tabController)
  {
    List<Widget> _labels = [];
    int pos = 0;
    widget.tabs.keys.forEach((key) {
      _labels.add(
        Tab(
          child:
            Row(
              // crossAxisAlignment: CrossAxisAlignment,
              mainAxisAlignment: pos == 0 ? MainAxisAlignment.start : pos == 1 ? MainAxisAlignment.center : pos == 2 ? MainAxisAlignment.end : null,
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

