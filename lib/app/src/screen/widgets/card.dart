import 'package:avme_wallet/app/src/screen/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/src/helper/size.dart';

import 'generic.dart';

class AppCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsets padding;
  final EdgeInsets? innerPadding;
  const AppCard({
    Key? key,
    this.child,
    this.padding = const EdgeInsets.all(12.0),
    this.innerPadding
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: this.padding,
      color: AppColors.cardDefaultColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        // padding: EdgeInsets.all(DeviceSize.safeBlockVertical * 1.5),
        padding: this.innerPadding ?? EdgeInsets.all(DeviceSize.safeBlockVertical * 1.5),
        child: this.child,
      ),
    );
  }
}

class AppCardTabs extends StatefulWidget {

  // final List<Widget> tabs;
  final List<Map> tabs;
  final int index;
  const AppCardTabs({Key? key, required this.tabs, required this.index}) : super(key: key);

  @override
  State<AppCardTabs> createState() => _AppCardTabsState();
}

class _AppCardTabsState extends State<AppCardTabs> {

  @override
  Widget build(BuildContext context) {
    Map<int, Map> tabsMap = widget.tabs.asMap();
    int first = tabsMap.entries.first.key;
    int last = tabsMap.entries.last.key;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: tabsMap.entries.map((entry) {
        bool selected = (entry.key == widget.index ? true : false);
        if(entry.key == first)
          return AppCardTab(
            text: entry.value['label'],
            onTap: entry.value['onTap'],
            side: 'START',
            selected: selected,
          );
        if(entry.key == last)
          return AppCardTab(
            text: entry.value['label'],
            onTap: entry.value['onTap'],
            side: 'END',
            selected: selected,
          );
        else
          return AppCardTab(
            text: entry.value['label'],
            onTap: entry.value['onTap'],
            selected: selected,
          );
      }
      ).toList(),);
  }
}

class AppCardTab extends StatelessWidget {
  final bool selected;
  final String text;
  final VoidCallback onTap;
  final String side;
  const AppCardTab({Key? key, this.selected = false, required this.text, required this.onTap, this.side = ''}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    BorderRadius radius = BorderRadius.all(Radius.zero);
    if(this.side.toUpperCase() == "START")
      radius =  BorderRadius.only(
        topLeft: Radius.circular(12),
      );
    if(this.side.toUpperCase() == "END")
      radius =  BorderRadius.only(
        topRight: Radius.circular(12),
      );
    return Padding(
      padding: EdgeInsets.only(right: 2),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                color: this.selected ? AppColors.cardDefaultColor:  AppColors.cardBlue,
                width: 2.0,
              )
          ),
        ),
        child: Container(
          child: GestureDetector(
            onTap: this.onTap,
            child: Container(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.only(
                  left: DeviceSize.safeBlockHorizontal * 2.33,
                  top: DeviceSize.safeBlockHorizontal * 3.33,
                  right: DeviceSize.safeBlockHorizontal * 2.33,
                  bottom: DeviceSize.safeBlockHorizontal
                ),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                            color: this.selected ? AppColors.purple : AppColors.cardDefaultColor,
                            width: 4.0,
                          )
                      )
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: DeviceSize.safeBlockHorizontal * 2,
                      right: DeviceSize.safeBlockHorizontal * 2,
                      bottom: DeviceSize.safeBlockHorizontal * 1.50),
                    child: LabelText(this.text),
                  )
                ),
              ),
            ),
          ),
          decoration: BoxDecoration(
              color: AppColors.cardDefaultColor,
              borderRadius: radius
          ),
        ),
      ),
    );
  }
}


class AppCardBody extends StatelessWidget {
  final Widget child;
  const AppCardBody({Key? key, required this.child}) : super(key: key);
  final double radius = 12;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardDefaultColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
          bottomLeft: Radius.circular(radius)
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(DeviceSize.safeBlockVertical * 1.5),
        child: this.child,
      ),
    );
  }
}
