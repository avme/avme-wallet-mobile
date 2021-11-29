import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  final Map<String,dynamic> routes;
  final String side;
  const AppDrawer(
    this.routes,
    {this.side = "RIGHT"});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {

  TextStyle tileStyle = avmeTheme.textTheme.headline1.copyWith(
    fontWeight: FontWeight.bold
  );

  Widget itemDivider = Padding(
    padding: EdgeInsets.only(right: 20),
    child: Divider(
      height: 1,
    ),
  );

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
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: widget.routes.entries.map((entry) {
                if(entry.value is Function)
                {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(entry.key, style: tileStyle,),
                        onTap: entry.value,
                      ),
                      entry.key != widget.routes.entries.last.key ? itemDivider : Container()
                    ],
                  );
                }
                return Column(
                  children: [
                    ListTile(
                      title: Text(entry.key),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => entry.value));
                      },
                    ),
                    entry.key != widget.routes.entries.last.key ? itemDivider : Container()
                  ],
                );
              }).toList()
            ),
          ),
        ),
      ),
    );
  }
}