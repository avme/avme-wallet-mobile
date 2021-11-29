import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  final Map<String,Widget> routes;
  final String side;
  const AppDrawer(
    this.routes,
    {this.side = "RIGHT"});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 8 * 7,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: ClipRRect(
          borderRadius: widget.side.toUpperCase() == "RIGHT"
              ? BorderRadius.only(
              topLeft: labelRadius.topLeft * 4,
              bottomLeft: labelRadius.bottomLeft * 2
          )
              : BorderRadius.only(
              topRight: labelRadius.topRight * 2,
              bottomRight: labelRadius.bottomRight * 2
          ),
          child: Drawer(
            child: Padding(
              // padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24.0),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              child: Column(
                children: widget.routes.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => entry.value));
                    },
                  );
                }).toList()
              ),
            ),
          ),
        ),
      ),
    );
  }
}