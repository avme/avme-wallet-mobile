import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  const AppCard({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Card(
      margin: EdgeInsets.all(12.0),
      color: AppColors.cardDefaultColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1.5),
        child: this.child,
      ),
    );
  }
}

class AppCardTabs extends StatefulWidget {

  // final List<Widget> tabs;
  final List<Map> tabs;
  final int index;
  const AppCardTabs({Key key, @required this.tabs, @required this.index}) : super(key: key);

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
  // final Widget child;
  final String text;
  final Function onTap;
  final String side;
  const AppCardTab({Key key, this.selected = false, @required this.text, @required this.onTap, this.side = ''}) : super(key: key);
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
                  left: SizeConfig.safeBlockHorizontal * 2.33,
                  top: SizeConfig.safeBlockHorizontal * 3.33,
                  right: SizeConfig.safeBlockHorizontal * 2.33,
                  bottom: SizeConfig.safeBlockHorizontal
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
                      left: SizeConfig.safeBlockHorizontal * 2,
                      right: SizeConfig.safeBlockHorizontal * 2,
                      bottom: SizeConfig.safeBlockHorizontal * 1.50),
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
  const AppCardBody({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Card(
      color: AppColors.cardDefaultColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
          bottomLeft: Radius.circular(12)
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1.5),
        child: this.child,
      ),
    );
  }
}
