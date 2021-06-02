import 'package:flutter/material.dart';

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar(this.color, this.tabBar);

  final Color color;
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context){
    return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFF7238AD),
              width: 2
            )
          )
        ),
        child: Container(
          color: color,
          child: tabBar,
      )
    );
  }
}