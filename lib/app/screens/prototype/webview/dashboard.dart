// @dart=2.12

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/controller/web/web_utils.dart';
import 'package:avme_wallet/app/controller/web/webview.dart';
import 'package:avme_wallet/app/lib/extensions.dart';
import 'package:avme_wallet/app/lib/tld.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/screens/prototype/webview/navigation.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/webview/header.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/widgets.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:avme_wallet/app/screens/prototype/webview/browser.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:characters/characters.dart' as ch;
import '../../../test/webview.dart';
import 'dart:math' as math;

import 'bottom_navigation.dart';

void initDashboard(BuildContext context)
{
  // Navigator.push(context,
  //   MaterialPageRoute(
  //     builder: (context) => Dashboard(),
  //   )
  // );
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionsBuilder: (context, anim1, anim2, widget) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: anim1.drive(tween),
          child: widget,
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      opaque: false, // set to false
      pageBuilder: (_, __, ___) => Dashboard(),
    ),
  );
  // showGeneralDialog(
  //   context: context,
  //   pageBuilder: (context, anim1, anim2) {
  //     return StatefulBuilder(builder: (builder, setState) => Dashboard());
  //   },
  //   barrierDismissible: true,
  //   barrierLabel: '',
  //   barrierColor: Colors.black.withOpacity(0.4),
  //   transitionBuilder: (context, anim1, anim2, widget) {
  //
  //     const begin = Offset(0.0, 1.0);
  //     const end = Offset.zero;
  //     const curve = Curves.ease;
  //     var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  //     return SlideTransition(
  //       position: anim1.drive(tween),
  //       child: widget,
  //     );
  //   },
  //   transitionDuration: Duration(milliseconds: 200)
  // );
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  int dashboardIndex = 0;
  int index = 0;

  late Future init;
  late List bookmarks;
  late AppWebViewController browserController;
  late StreamController<int> browserUtility;

  Future<List> getFavoritesData() async
  {
    List favoritesData = await Favorites().getSites();
    List ret = [];
    await Future.forEach(favoritesData, (map) async{
      Map data = map as Map;
      print(map);
      // String title = data["title"] ?? "NO TITLE";
      Uri uri = Uri.parse(data["url"] ?? "www.avme.io");
      String title = uri.host.split('.')[uri.host.split('.').length - 2].toUpperCase();
      int color = int.tryParse(data["color"]) ?? 0;
      ret.add([data["url"],title, data["ico"], HexColor.fromHex("#${color.toRadixString(16)}")]);
    });
    await Future.delayed(Duration(milliseconds: 250));
    return ret;
  }

  Future<int> initialize() async
  {
    this.browserUtility = StreamController<int>();
    this.browserUtility.add(0);
    this.bookmarks = await getFavoritesData();
    return 1;
  }

  @override
  void initState() {
    super.initState();
    init = initialize();
    browserController = AppWebViewController.getInstance();
    this.browserUtility.stream.listen((value) {
      changeBrowserIndex(value);
    });
  }

  void changeBrowserIndex(int index)
  {
    if(this.index != index)
    {
      if(index == 0)
      {
        ///Disposing the WebViewController
        browserController.dispose();
      }
      setState(() {
        this.index = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    double verticalButtons = SizeConfig.safeBlockVertical * 1;
    double horizontalButtons = SizeConfig.safeBlockVertical * 2;

    TextEditingController dashSearch = TextEditingController();

    BorderRadius _borderR = BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16)
    );

    // return Scaffold(
    //   backgroundColor: Colors.black54,
    //   resizeToAvoidBottomInset: false,
    //   body: Container(
    //     color: Colors.red,
    //   ),
    // );
    return Scaffold(
      backgroundColor: Colors.black54,
      resizeToAvoidBottomInset: false,
      body: FutureBuilder(
          future: init,
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if(snapshot.data == null)
              return Column(
                children: [
                  Colored(flex: 1, color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Expanded(
                    flex: 14,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkBlue,
                        borderRadius: _borderR
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: SizeConfig.screenWidth / 4,
                                  height: SizeConfig.screenWidth / 4,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 8,
                                    color: AppColors.purple,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top:16.0),
                                child: LabelText("Loading"),
                              )
                            ],
                          ),
                        ],
                      )
                    ),
                  )
                ],
              );
            return Column(
              children: [
                Colored(flex: 1, color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: Container(
                    color: AppColors.darkBlue,
                    child: Column(
                      children: [
                        ///WebView Area
                        Expanded(flex: 13,
                          child: FadeIndexedStack(
                            index: index,
                            duration: Duration(milliseconds: 250),
                            children: [
                              ///Dashboard
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.darkBlue,
                                  borderRadius: _borderR
                                ),
                                child: Column(
                                  children: [
                                    Navigation(
                                      enabled: false,
                                      appWebViewController: browserController,
                                    ),
                                    Expanded(
                                      flex: 10,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: _borderR,
                                          color: Colors.black12
                                        ),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Column(
                                              children: [
                                                // Colored(flex: 5, color: Colors.purple),
                                                Header(
                                                  borderRadius: _borderR,
                                                ),
                                                ///Render do selected index
                                                Expanded(
                                                    flex: 12,
                                                    child: Column(/**/
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(
                                                              left: 32.0,
                                                              right: 32.0,
                                                              top: 48
                                                          ),
                                                          child: DashboardTabs(tabs: [
                                                            {
                                                              "label" : "Discover",
                                                              "onTap" : () => swapDashboard(0),
                                                            },
                                                            {
                                                              "label" : "Bookmarks",
                                                              "onTap" : () => swapDashboard(1),
                                                            },
                                                          ],
                                                              index: dashboardIndex),
                                                        ),
                                                        Flexible(
                                                          child: FadeIndexedStack(
                                                            // child: IndexedStack(
                                                            index: dashboardIndex,
                                                            duration: Duration(milliseconds: 250),
                                                            children: [
                                                              Discover(
                                                                horizontalButtons: horizontalButtons,
                                                                verticalButtons: verticalButtons,
                                                                browserUtility: browserUtility,
                                                              ),
                                                              Bookmarks(
                                                                  favoriteData: bookmarks,
                                                                  horizontalButtons: horizontalButtons,
                                                                  verticalButtons: verticalButtons
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                )
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    // color: Colors.blue.withOpacity(0.5),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(
                                                        left: 32.0,
                                                        right: 32.0,
                                                        // bottom: 32.0
                                                      ),
                                                      child: Align(
                                                        alignment: Alignment.bottomCenter.add(Alignment(0,-0.2666)),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(24),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.black26,
                                                                blurRadius: 5,
                                                                offset: const Offset(0, 2),
                                                              ),
                                                            ],
                                                          ),
                                                          child: TextFormField(
                                                            controller: dashSearch,
                                                            onFieldSubmitted: (String formData){
                                                              redirect(formData);
                                                            },
                                                            decoration: InputDecoration(
                                                              filled: true,
                                                              hintText: 'Search or type URL',
                                                              fillColor: AppColors.purpleDark3,
                                                              // fillColor: AppColors.purpleDark2,
                                                              suffixIcon: GestureDetector(
                                                                onTap: () {
                                                                  redirect(dashSearch.text);
                                                                },
                                                                child: Transform(
                                                                    alignment: Alignment.center,
                                                                    transform: Matrix4.rotationY(math.pi),
                                                                    child: Icon(Icons.search, size: 28, color: AppColors.labelDefaultColor,)
                                                                ),
                                                              ),
                                                              contentPadding: const EdgeInsets.symmetric(
                                                                  vertical: 16,
                                                                  horizontal: 16
                                                              ),
                                                              isDense: true,
                                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Container(),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        // ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ///Browser
                              AppBrowser(
                                borderRadius: _borderR,
                                navigation: Navigation(
                                  appWebViewController: browserController,
                                ),
                              )
                            ],
                          ),
                        ),
                        ///Bottom Navigation
                        BottomNavigation(
                          browserUtility: browserUtility,
                          controller: browserController.controller.future,
                          index: index,
                          historyStream: browserController.onHistory,
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          }
      ),
    );
  }

  void swapDashboard(int id)
  {
    if(id != dashboardIndex)
      setState(() {
        dashboardIndex = id;
      });
  }

  @override
  void dispose() {
    ///Disposing the WebViewController
    browserController.dispose();
    browserUtility.close();
    super.dispose();
  }

  // void swapBrowser(int id, {String url = ""})
  // {
  //   if(id != index)
  //     setState(() {
  //       index = id;
  //     });
  // }



  void redirect(String url) {
    NotificationBar().show(context, text: url);
  }
}


class AppDarkIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget text;
  final Widget icon;
  final EdgeInsets? padding;
  final bool centered;
  final double? height;
  final AlignmentGeometry? alignment;
  const AppDarkIconButton({
    Key? key,
    required this.onPressed,
    this.padding,
    this.centered = false,
    required this.text,
    required this.icon,
    this.height,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SizedBox(
      height: this.height ?? SizeConfig.safeBlockVertical * 6.5,
      child: ElevatedButton.icon(
        onPressed: this.onPressed,
        label: this.text,
        style: ButtonStyle(
          alignment: alignment,
          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            return AppColors.purpleDark3;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            )
          ),
          shadowColor: MaterialStateProperty.all<Color>(Colors.black),
          elevation: MaterialStateProperty.all(3),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(this.padding ?? const EdgeInsets.all(8.0)),
        ),
        icon: SizedBox(
          width: SizeConfig.safeBlockHorizontal * 8,
          child: Center(child: this.icon),
        ),
      ),
    );
  }
}

class AppDarkButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsets? padding;
  final bool centered;
  final double? height;
  final AlignmentGeometry? alignment;
  const AppDarkButton({
    Key? key,
    required this.onPressed,
    this.padding,
    this.centered = false,
    required this.child,
    this.height,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SizedBox(
      height: this.height ?? SizeConfig.safeBlockVertical * 6.5,
      child: ElevatedButton(
        onPressed: this.onPressed,
        child: this.child,
        style: ButtonStyle(
          alignment: alignment,
          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            return AppColors.purpleDark3;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            )
          ),
          shadowColor: MaterialStateProperty.all<Color>(Colors.black),
          elevation: MaterialStateProperty.all(3),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(this.padding ?? const EdgeInsets.all(8.0)),
        ),
      ),
    );
  }
}

class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    required this.index,
    required this.children,
    this.duration = const Duration(
      milliseconds: 800,
    ),
  });

  @override
  _FadeIndexedStackState createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    if (widget.index != oldWidget.index) {
      _controller.forward(from: 0.0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: IndexedStack(
        index: widget.index,
        children: widget.children,
      ),
    );
  }
}

class DashboardTabs extends StatefulWidget {

  DashboardTabs({
    required this.tabs,
    required this.index,
  });

  final List<Map> tabs;
  final int index;

  @override
  _DashboardTabsState createState() => _DashboardTabsState();
}

class _DashboardTabsState extends State<DashboardTabs> {

  @override
  Widget build(BuildContext context) {

    Map<int, Map> tabsMap = widget.tabs.asMap();
    int first = tabsMap.entries.first.key;
    int last = tabsMap.entries.last.key;

    return Row(
      children: tabsMap.entries.map((entry) {
        bool selected = (entry.key == widget.index ? true : false);
        if(entry.key == first)
          return DashboardTab(
            text: entry.value['label'],
            onTap: entry.value['onTap'],
            side: 'START',
            selected: selected,
          );
        if(entry.key == last)
          return DashboardTab(
            text: entry.value['label'],
            onTap: entry.value['onTap'],
            side: 'END',
            selected: selected,
          );
          return DashboardTab(
            text: entry.value['label'],
            onTap: entry.value['onTap'],
            selected: selected,
          );
      }).toList(),
    );
  }
}

class DashboardTab extends StatelessWidget {
  final bool selected;
  // final Widget child;
  final String text;
  final VoidCallback onTap;
  final String side;
  const DashboardTab({Key? key, this.selected = false, required this.text, required this.onTap, this.side = ''}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              // color: this.selected ? AppColors.cardDefaultColor:  AppColors.cardBlue,
              color: Colors.transparent,
              width: 2.0,
            )
          ),
        ),
        child: GestureDetector(
          onTap: this.onTap,
          behavior: HitTestBehavior.translucent,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.purple,
                        width: 3.0,
                      )
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom:8.0),
                    child: Text(
                      this.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: this.selected ? AppColors.purple : Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: this.selected ? AppColors.purple : Colors.transparent,
                        width: 3.0,
                      )
                    )
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Discover extends StatefulWidget {

  final double verticalButtons;
  final double horizontalButtons;
  final StreamController<int> browserUtility;
  const Discover({
    required this.verticalButtons,
    required this.horizontalButtons,
    required this.browserUtility
  });

  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      // shrinkWrap: true,
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: 32.0,
              right: 32.0,
              top: widget.horizontalButtons
            // top: 64,
          ),
          child: Container(
            // color: Colors.red,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: AppDarkIconButton(
                    onPressed: () {  },
                    text: Text("BUY \$AVME",style: TextStyle(color: AppColors.labelDefaultColor),),
                    icon: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: Icon(Icons.shopping_cart, color: AppColors.labelDefaultColor)
                    ),
                  ),
                ),
                Row(
                  children: [
                    AppDarkIconButton(
                      onPressed: () {  },
                      alignment: Alignment.centerLeft,
                      text: Text("NFTs",style: TextStyle(color: AppColors.labelDefaultColor),),
                      icon: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: Icon(Icons.insert_photo_rounded, color: AppColors.labelDefaultColor)
                      ),
                    ),
                    AppDarkIconButton(
                      onPressed: () {  },
                      alignment: Alignment.centerLeft,
                      text: FittedBox(child: Text("DECENTRALIZED\nFINANCE",style: TextStyle(color: AppColors.labelDefaultColor),)),
                      icon: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: FaIcon(FontAwesomeIcons.exchangeAlt, color: AppColors.labelDefaultColor, size: 18,)
                      ),
                    ),
                  ].asMap().map((int key, Widget element) {
                    if(key == 0)
                      return MapEntry(
                          key,
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(right: widget.verticalButtons),
                              child: SizedBox(
                                width: double.infinity,
                                child: element,
                              ),
                            ),
                          )
                      );
                    return MapEntry(
                        key,
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: widget.verticalButtons),
                            child: SizedBox(
                              width: double.infinity,
                              child: element,
                            ),
                          ),
                        )
                    );
                  }).values.toList(),
                ),
                Row(
                  children: [
                    AppDarkIconButton(
                      onPressed: () {  },
                      alignment: Alignment.centerLeft,
                      text: Text("CHARTS",style: TextStyle(color: AppColors.labelDefaultColor),),
                      icon: FaIcon(FontAwesomeIcons.chartLine, color: AppColors.labelDefaultColor, size: 18,),
                    ),
                    AppDarkIconButton(
                      onPressed: () {  },
                      alignment: Alignment.centerLeft,
                      text: FittedBox(child: Text("OUR WEBSITE",style: TextStyle(color: AppColors.labelDefaultColor),)),
                      icon: FaIcon(FontAwesomeIcons.globeAmericas,  color: AppColors.labelDefaultColor, size: 18,),
                    ),
                  ].asMap().map((int key, Widget element) {
                    if(key == 0)
                      return MapEntry(
                          key,
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(right: widget.verticalButtons),
                              child: SizedBox(
                                width: double.infinity,
                                child: element,
                              ),
                            ),
                          )
                      );
                    return MapEntry(
                        key,
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: widget.verticalButtons),
                            child: SizedBox(
                              width: double.infinity,
                              child: element,
                            ),
                          ),
                        )
                    );
                  }).values.toList(),
                ),
                SizedBox(
                  width: double.infinity,
                  child: AppDarkIconButton(
                    onPressed: () {
                      NotificationBar().show(context, text: "I Don't know");
                    },
                    text: Text("HOW DOES THIS WORK?",style: TextStyle(color: AppColors.labelDefaultColor),),
                    icon: FaIcon(FontAwesomeIcons.solidQuestionCircle, color: AppColors.labelDefaultColor, size: 18,),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: AppDarkIconButton(
                    onPressed: () {
                      widget.browserUtility.add(1);
                    },
                    text: Text("Swap to Browser",style: TextStyle(color: AppColors.labelDefaultColor),),
                    icon: FaIcon(FontAwesomeIcons.solidQuestionCircle, color: AppColors.labelDefaultColor, size: 18,),
                  ),
                ),
              ].map((Widget element) =>
                  Padding(
                    child: element,
                    padding: EdgeInsets.only(bottom: widget.horizontalButtons),
                  )
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class Bookmarks extends StatefulWidget {
  final double verticalButtons;
  final double horizontalButtons;
  final List favoriteData;

  const Bookmarks({
    required this.verticalButtons,
    required this.horizontalButtons,
    required this.favoriteData
  });

  @override
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 32.0,
          right: 32.0,
          top: widget.horizontalButtons
        // top: 64,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: widget.verticalButtons),
                  child: Text(
                    "Favorites",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Flexible(
                  child: widget.favoriteData.length > 0
                    ? GridView(
                      scrollDirection: Axis.horizontal,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        // crossAxisSpacing: SizeConfig.safeBlockHorizontal * 3.33,
                        mainAxisSpacing: SizeConfig.safeBlockHorizontal * 6,
                        crossAxisCount: 1,
                        childAspectRatio: 1
                      ),
                      children: widget.favoriteData.map((siteData) {
                        return FavoriteBadge(
                          url: siteData[0],
                          title: siteData[1],
                          image: siteData[2],
                          color: siteData[3],
                          onTap: (){
                            NotificationBar().show(context, text: "FavoriteBadge ${siteData[1]}");
                          },
                        );
                      }).toList(),
                    )
                    : Row(
                      children: [
                        Flexible(
                          child: AppCard(
                            child: Center(
                              child: Text(
                                "To add a page to favorites please go to\nthe page and tap \"Favorite Page\"",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                )
              ],
            ),
          ),
          Expanded(
            flex:5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: widget.verticalButtons * 2),
                  child: Text(
                    "Recent",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    // shrinkWrap: true,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: AppDarkButton(
                              onPressed: () {  },
                              child: Text("Medium.AVME.io",style: TextStyle(color: AppColors.labelDefaultColor),),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: AppDarkButton(
                              onPressed: () {  },
                              child: Text("Twitter.com/AVME_IO",style: TextStyle(color: AppColors.labelDefaultColor),),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: AppDarkButton(
                              onPressed: () {  },
                              child: Text("Coinmarketcap.com",style: TextStyle(color: AppColors.labelDefaultColor),),
                            ),
                          ),
                        ].map((Widget element) =>
                          Padding(
                            child: element,
                            padding: EdgeInsets.only(bottom: widget.horizontalButtons),
                          )
                        ).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FavoriteBadge extends StatefulWidget {
  const FavoriteBadge({
    required this.url,
    required this.title,
    required this.color,
    required this.image,
    required this.onTap,
  });
  final String url;
  final String title;
  final Color color;
  final String image;
  final VoidCallback? onTap;
  @override
  _FavoriteBadgeState createState() => _FavoriteBadgeState();
}

class _FavoriteBadgeState extends State<FavoriteBadge> {
  @override
  Widget build(BuildContext context) {

    // printMark(
    // '''
    //   Title:${widget.title}
    //   RED: ${widget.color.red}
    //   BLUE: ${widget.color.blue}
    //   GREEN: ${widget.color.green}
    //   ALPHA: ${ widget.color.alpha}
    // ''');

    ///Changing if the background is too yellowish or any combination, pangolin alike is barely
    ///visible when using the original dominant color
    int alpha = widget.color.alpha;
    int r = widget.color.red;
    int b = widget.color.blue;
    int g = widget.color.green;

    if(r > 150 && g > 150 && b < 80)
      alpha -= 35;
    if(g > 150 && b > 150 && r < 80)
      alpha -= 35;
    if(b > 150 && r > 150 && g < 80)
      alpha -= 35;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.color
                      .withAlpha(alpha),
                    borderRadius: BorderRadius.all(Radius.circular(100))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.memory(
                      base64Decode(widget.image), fit: BoxFit.contain,
                      // width: 80,
                      // height: 80,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 2.0,
                right: 2.0,
                top: 2.0
              ),
              child: SizedBox.expand(
                child: FittedBox(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
