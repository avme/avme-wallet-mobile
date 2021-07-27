import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class Accounts extends StatefulWidget {
  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  int accounts = 2;
  @override
  Widget build(BuildContext context) {
    // return Padding(
    //   padding: const EdgeInsets.symmetric(vertical: 8.0),
    //   child: ListView(
    //       children:[
    //         AccountCard(loading:true),
    //         Center(child: ElevatedButton(
    //           onPressed: () {
    //             snack("new wallet pressed", context);
    //           },
    //           child: Icon(Icons.add),),)
    //       ]
    //   ),
    // );
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
                onPressed: () {
                  setState(() {
                    this.accounts++;
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          // Container(
          //   width: 200,
          //   height: 200,
          //   color: Colors.yellow,
          //   child: CustomPaint(
          //     painter: ListIndicator(),
          //   ),
          // ),
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
              child: ListView(
                  children: accounts
              ),
            ),
          ),
        ],
      ),
          // ListView(
          //     children:[
          //       AccountCard(loading:true),
          //       Center(child: ElevatedButton(
          //         onPressed: () {
          //           snack("new wallet pressed", context);
          //         },
          //         child: Icon(Icons.add),),)
          //     ]
          // ),

    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FutureBuilder(
        future: accountList(),
        builder: (BuildContext context, snapshot){
          if(snapshot.data == null)
            return ListView.builder(
              itemCount: 3,
              itemBuilder: (BuildContext context, index)
              {
                return AccountCard(loading:true);
              },
            );
          else return snapshot.data;
        },
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


class AccountCard extends StatelessWidget {

  /// Widget State
  final bool loading;

  /// Widget Style params
  final double labelHeight = 16;
  final double labelSpacing = 6.5;
  final BorderRadius labelRadius = BorderRadius.circular(16);
  final BorderRadius cardRadius = BorderRadius.all(Radius.circular(4.0));


  AccountCard({this.loading});

  @override
  Widget build(BuildContext context) {
    double textWidth = MediaQuery.of(context).size.width / 2.33;
    if(this.loading)
    {
      return Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
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
                  painter: ListIndicator(),
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
                          Container(
                            width: labelHeight,
                            height: labelHeight,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: labelRadius,
                            ),
                          ),
                          SizedBox(width: 6,),
                          Container(
                            width: textWidth * 1.2,
                            height: labelHeight,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: labelRadius,
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
                          Container(
                            width: textWidth,
                            height: labelHeight,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: labelRadius,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: labelSpacing,),
                      Row(
                        children: [
                          Container(
                            width: textWidth / 1.5,
                            height: labelHeight,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: labelRadius,
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
    return Text("Loading is set to false");
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
