import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/screens/prototype/app_drawer.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

import 'colored_tabbar.dart';

class DrawerScaffold extends StatefulWidget {
  final List<String> options;
  final Text title;
  final Map<String, Widget> pages;
  const DrawerScaffold({
    Key key,
    @required this.options,
    @required this.title,
    @required this.pages,
  }) : super(key: key);

  @override
  _DrawerScaffoldState createState() => _DrawerScaffoldState();
}

class _DrawerScaffoldState extends State<DrawerScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: backgroundImage,
        child:
        SafeArea(
          child: TabBarView(
            children: buildTabBarView(2, widget.pages),
          ),
        ),
      ),
      appBar: AppBar(
        title: widget.title,
        elevation: 0,
        backgroundColor: Color(0x81000000),
        actions: [
          PopupMenuButton(
            onSelected: (String text) => _popupMenuButtom(text,context),
            itemBuilder: (BuildContext context)
            {
              return widget.options.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              } ).toList();
            },
          )
        ],
        bottom: ColoredTabBar(
          Color(0x23FFFFFF),
          TabBar(
            isScrollable: true,
            tabs: buildTabBarView(1, widget.pages),
          ),
        ),
      ),
      drawer: AppDrawer(widget.pages,side: "LEFT",),
    );
  }
}

void _popupMenuButtom(String val, BuildContext context)
{
  //Switch
  snack(val, context);
  switch(val)
  {
    case "Reload":
      Navigator.pushReplacementNamed(context, "/home");
      break;
  }
}

// final EdgeInsets padding = EdgeInsets.all(12.0);
// Return a list of types...
// 1 - Key names as TAB to populate the TabBar
// 2 or more - Widget List to the TabBarView
List<Widget> buildTabBarView(int type, Map pages)
{
  List<Widget> _list = [];
  if(type == 1) pages.forEach((key, value) {
    _list.add(Tab(text:key));
  });

  else pages.forEach((key, value) {
    _list.add(Padding(padding: EdgeInsets.zero, child: value));
  });
  return _list;
}
