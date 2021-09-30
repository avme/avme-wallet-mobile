import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {

  final Map<dynamic,Widget> routes;
  final String side;
  const AppDrawer(this.routes, {this.side = "RIGHT"});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {

    List<Widget> drawerElements = [];

    widget.routes.forEach((key, value) {
      if(key.runtimeType == int)
      {
        drawerElements.add(value);
      }
      else
      {
        drawerElements.add(
            ListTile(
              title: Text(key),
              onTap: () {
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => value));
                Navigator.push(context, MaterialPageRoute(builder: (context) => value));
            }
          )
        );
      }
    });

    return ClipRRect(
      borderRadius: widget.side.toUpperCase() == "RIGHT"
        ? BorderRadius.only(
          topLeft: labelRadius.topLeft * 2,
          bottomLeft: labelRadius.bottomLeft * 2
        )
        : BorderRadius.only(
          topRight: labelRadius.topRight * 2,
          bottomRight: labelRadius.bottomRight * 2
        )
      ,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 8 * 7,
        child: Drawer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24.0),
            child: ListView(
              padding: EdgeInsets.zero,
              children: drawerElements,
            ),
          ),
        ),
      ),
    );
  }
}