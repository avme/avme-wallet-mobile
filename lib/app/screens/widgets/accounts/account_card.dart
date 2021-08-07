
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:flutter/material.dart';

import '../custom_widgets.dart';
import '../shimmer.dart';
import '../theme.dart';

class AccountCard extends StatefulWidget {

  /// Widget State
  final bool loading;
  final AccountObject data;
  final bool selected;
  AccountCard({this.loading = false, this.data, this.selected = false});

  @override
  _AccountCardState createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {

  @override
  Widget build(BuildContext context) {
    double textWidth = MediaQuery.of(context).size.width / 2.33;
    if(!widget.loading)
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
                  painter: !widget.loading ? ListIndicator(selected:widget.selected) : null,
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
                          LabelText("${widget.data.slot}"),
                          Text(" - "),
                          Text("${widget.data.title}"),
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
                          Text("${widget.data.address}")
                        ],
                      ),
                      SizedBox(height: labelSpacing,),
                      Row(
                        children: [
                          LabelText("AVAX:"),
                          SizedBox(width: labelSpacing,),
                          Text("${shortAmount(widget.data.balance)}"),
                          SizedBox(width: labelSpacing,),
                          LabelText("AVME:"),
                          SizedBox(width: labelSpacing,),
                          Text("${shortAmount(widget.data.tokenBalance)}"),
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
              Container(
                // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /*Erro aqui*/
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
                      /*Erro aqui*/
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
                      /*Erro aqui*/
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
  final bool selected;
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