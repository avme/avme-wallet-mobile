import 'package:flutter/material.dart';
import 'package:avme_wallet/app/src/screen/widgets/theme.dart';

class AppDrawer extends StatefulWidget {
  final Map<String, dynamic> routes;
  final String side;
  final double width;
  final Widget header;
  const AppDrawer(
    this.routes,
    {this.side = "RIGHT", required this.width, required this.header});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {

  TextStyle tileStyle = AppTheme.theme.textTheme.headline1!.copyWith(
    fontWeight: FontWeight.bold,
    fontSize: 16
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
      width: widget.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: ClipRRect(
          borderRadius:
            widget.side.toUpperCase() == "RIGHT"
            ? BorderRadius.only(
              topLeft: labelRadius.topLeft * 4,
              bottomLeft: labelRadius.bottomLeft * 2)
            : BorderRadius.only(
              topRight: labelRadius.topRight * 2,
              bottomRight: labelRadius.bottomRight * 2),
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.all(0),
              physics: BouncingScrollPhysics(),
              children: [ widget.header ]
                ..addAll(widget.routes.entries.map((entry) {
                  dynamic value = entry.value;
                  Icon icon = Icon(Icons.code);

                  if(value is List)
                  {
                    value = entry.value[1];
                    icon = Icon(entry.value[0]);
                  }

                  if(value is VoidCallback)
                  {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(entry.key, style: tileStyle,),
                          onTap: value,
                          minLeadingWidth: 26,
                          contentPadding: EdgeInsets.only(left: 16),
                          leading: icon,
                        ),
                        entry.key != widget.routes.entries.last.key ? itemDivider : Container()
                      ],
                    );
                  }
                  return Column(
                    children: [
                      ListTile(
                        title: Text(entry.key, style: tileStyle,),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => value));
                        },
                        minLeadingWidth: 26,
                        contentPadding: EdgeInsets.only(left: 16),
                        leading: icon,
                      ),
                      entry.key != widget.routes.entries.last.key ? itemDivider : Container()
                    ],
                  );
              }).toList())
            ),
          ),
        ),
      ),
    );
  }
}