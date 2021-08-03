import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/shimmer.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Accounts extends StatefulWidget {
  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  AvmeWallet appState;
  int accounts = 2;
  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AvmeWallet>(context);
    print(appState.accountList.keys);

    List<Widget> accounts = repeatWidgetList(AccountCard(loading: true,), this.accounts)
    ..add(
      Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 16),
        child: Center(child:
          Container(
            // color: Colors.red,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avmeTheme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  spreadRadius: 0,
                  offset: Offset(0,5),
                  blurRadius: 10,
                )
              ]
            ),
            child: SizedBox(
              width: 60,
              height: 60,
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.white
                ),
                onPressed: () async{
                  // await appState.walletManager.makeAccount(field1.text, appState, loadingState);
                  setState(() {
                    // Creates the user account


                    // this.accounts++;
                  });
                },
                child: Icon(Icons.add),
              ),
            ),
          ),
        ),
      )
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                child: LabelText("Accounts:"),
                padding: EdgeInsets.only(bottom: 8)
              )
            ],
          ),
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
              child: ListView(
                  children: accounts
              ),
              // child: FutureProvider(
              //   future: null,
              //   builder: (context, snapshot) {
              //     return ListView(
              //         children: accounts
              //     );
              //   }
              // ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> repeatWidgetList(Widget widget, int amount)
  {
    List<Widget> ret = [];
    for(int i = 0; i < amount; i++) ret.add(widget);
    return ret;
  }

  Future<Widget> accountList() async
  {
    await Future.delayed(Duration(seconds: 3));
    return ListView(
      children: [
        Text("data"),
        Text("data"),
        Text("data"),
        Text("data"),
      ],
    );
  }
}

class AccountCard extends StatefulWidget {

  /// Widget State
  final bool loading;
  final Map<String, dynamic> data;
  AccountCard({this.loading = false, this.data});

  @override
  _AccountCardState createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {

  @override
  Widget build(BuildContext context) {
    double textWidth = MediaQuery.of(context).size.width / 2.33;
    if(widget.loading)
    {
      return Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
        ),
        child: ClipRRect(
          borderRadius: cardRadius,
          child: Stack(
            children: [
              ///Container to indicate what is the selected account
              Container(
                height: 20,
                width: 20,
                child: CustomPaint(
                  painter: !widget.loading ? ListIndicator() : null,
                ),
              ),
              Container(
                // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          LabelText("#0"),
                          Text(" - "),
                          Text("[Account Label Here]"),
                        ],
                      ),
                      SizedBox(height: labelSpacing,)
                    ],
                  ),
                  // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("0xFFFFF0F0FFFF0F0FA0CCCFCAFFF")
                        ],
                      ),
                      SizedBox(height: labelSpacing,),
                      Row(
                        children: [
                          LabelText("Meta Coin:"),
                          SizedBox(width: labelSpacing,),
                          Text("36615.0"),
                          SizedBox(width: labelSpacing,),
                          LabelText("Token:"),
                          SizedBox(width: labelSpacing,),
                          Text("12345.6789"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      );
    }
    else
    {
      return Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
        ),
        child: ClipRRect(
          borderRadius: cardRadius,
          child: Stack(
            children: [
              ///Container to indicate what is the selected account
              Container(
                height: 20,
                width: 20,
                child: CustomPaint(
                  painter: !widget.loading ? ListIndicator() : null,
                ),
              ),
              Container(
                // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShimmerLoadingEffect(
                            child: Container(
                              width: labelHeight,
                              height: labelHeight,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: labelRadius,
                              ),
                            ),
                          ),
                          SizedBox(width: labelSpacing,),
                          ShimmerLoadingEffect(
                            child: Container(
                              width: textWidth * 1.2,
                              height: labelHeight,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: labelRadius,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: labelSpacing,)
                    ],
                  ),
                  // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShimmerLoadingEffect(
                            child: Container(
                              width: textWidth,
                              height: labelHeight,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: labelRadius,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: labelSpacing,),
                      Row(
                        children: [
                          ShimmerLoadingEffect(
                            child: Container(
                              width: textWidth / 1.5,
                              height: labelHeight,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: labelRadius,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      );
    }
    // return Text("Loading is set to false");
  }
}

class ListIndicator extends CustomPainter {
  bool selected;
  final Color red = Color(0xFF890000);
  final Color green = Color(0xFF458900);

  ListIndicator({this.selected = false});

  @override
  void paint(Canvas canvas, Size size) {

    canvas.drawPath(
        Path()
          ..moveTo(0,0)
          ..lineTo(0, size.height)
          ..lineTo(size.width, 0)
          ..close(),
        Paint()
          ..color = this.selected ? green : red
          ..strokeWidth = 15
          ..style = PaintingStyle.fill);

    canvas.drawPath(
        Path()
          ..moveTo(0,0)
          ..lineTo(0, size.height)
          ..lineTo(size.width, 0)
          ..close(),
        Paint()
          ..color = Color.fromRGBO(255, 255, 255, 0.3)
          ..strokeWidth = 15
          ..style = PaintingStyle.fill);

    canvas.drawPath(
        Path()
          ..moveTo(0,0)
          ..lineTo(0, size.height * 11 / 12)
          ..lineTo(size.width * 11 / 12, 0)
          ..close(),
        Paint()
          ..color = this.selected ? green : red
          ..strokeWidth = 15
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
  
}
