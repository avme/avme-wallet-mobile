import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/drawer_scaffold.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {

  final double appBarWidth = 12;
  // final ButtonStyle appBarButtonStyle = TextButton.styleFrom(
  //   padding: EdgeInsets.all(0),
  //   backgroundColor: Colors.red,
  //   textStyle: TextStyle(
  //   ),
  //   minimumSize: Size(0,10)
  // );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: AppColors.labelDefaultColor
        ),
        titleSpacing: appBarWidth,
        /// We're populating this property with a Row widget and a Pad widget to
        ///match the original design, since flutter doesn't allow any widget
        ///besides PreferredSizeWidet and AppState.
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
      drawer: AppDrawer({"Example 1" : Container()}),
      ///Drawer in the Right Side
      endDrawer: AppDrawer({"Example 1" : Container()}),
      body: AppTabBar(
        padding: appBarWidth,
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
  final Map<String, Widget> tabs;
  final double padding;
  const AppTabBar({@required this.tabs, @required this.padding});
  @override
  _AppTabBarState createState() => _AppTabBarState();
}

class _AppTabBarState extends State<AppTabBar>
    with SingleTickerProviderStateMixin {

  TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: 1,
    );
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
    return Column(
      children: [
        Padding(
          // padding: const EdgeInsets.all(8.0),
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: widget.padding),
          child: Container(
            decoration: BoxDecoration(
              // color: Colors.red,
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
              child: Padding(
                padding: const EdgeInsets.only(bottom:16.0),
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
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: getTabWidgets()
          ),
        ),
      ]
    );
  }

  List<Widget> getTabWidgets()
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
              mainAxisAlignment: pos == 0 ? MainAxisAlignment.start : pos != widget.tabs.length - 1 ? MainAxisAlignment.center : MainAxisAlignment.end,
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

