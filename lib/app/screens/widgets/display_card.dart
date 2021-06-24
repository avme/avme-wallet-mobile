import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/screens/widgets/transaction_details.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/screens/widgets/shimmer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DisplayCard extends StatefulWidget {
  DisplayCard({this.loading = false, this.data});
  final bool loading;
  final Map<String, dynamic> data;
  @override
  _DisplayCardState createState() => _DisplayCardState();
}

class _DisplayCardState extends State<DisplayCard> {
  @override
  Widget build(BuildContext context) {
    double textWidth = MediaQuery.of(context).size.width / 3;
    if(widget.loading)
    {
      return Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerLoadingEffect(
                  child: Container(
                    padding: EdgeInsets.only(right: 12.0),
                    decoration: new BoxDecoration(
                        border: new Border(
                            right: new BorderSide(width: 1.0, color: Colors.black))),
                    // child: FaIcon(FontAwesomeIcons.exchangeAlt, color: Colors.white),
                    child: Container(
                      decoration:BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(height: 35, width: 35,),
                    ),
                  ),
                ),
              ],
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoadingEffect(
                  child: Container(
                    width: double.infinity,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                SizedBox(height: 4,)
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
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4,),
                Row(
                  children: [
                    ShimmerLoadingEffect(
                      child: Container(
                        width: textWidth / 1.5,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                      border: new Border(
                          right: new BorderSide(width: 1.0, color: Colors.white24))),
                  child: Container(
                    child: Icon(Icons.check, color: Colors.green, size: 30,),
                  ),
                ),
              ],
            ),
          title:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "${widget.data["to"]}",
                    maxLines: 2,
                    overflow: TextOverflow.fade,

                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                SizedBox(height: 4,)
              ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  Icon(Icons.monetization_on, color: Colors.yellow, size: 18,),
                  Text(" "+widget.data["formatedAmount"], style: TextStyle(color: Colors.white))
                ],
              ),
              SizedBox(height: 4,),
              Row(
                children: <Widget>[
                  FaIcon(FontAwesomeIcons.exchangeAlt, color: Colors.white, size: 18,),
                  Text(" "+widget.data["operation"], style: TextStyle(color: Colors.white))
                ],
              ),
              SizedBox(height: 4,),
              Row(
                children: <Widget>[
                  Icon(Icons.date_range, color: Colors.red, size: 18,),
                  Text(" "+widget.data["date"], style: TextStyle(color: Colors.white))
                ],
              ),
            ],
          ),
          trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
          onTap: (){
            // snack("clicked in ${widget.data["amount"]}", context);
            openTransactionDetails(context, widget.data);
          },
        ),
      ),
    );
  }

  void openTransactionDetails(BuildContext context, Map transactionData)
  {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionDetails(transactionData)));
  }
}