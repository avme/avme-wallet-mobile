import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class HistorySnippet extends StatefulWidget {

  final bool sent;
  final String amount;

  const HistorySnippet({Key key, @required this.sent, @required this.amount}) : super(key: key);

  @override
  _HistorySnipetState createState() => _HistorySnipetState();
}

class _HistorySnipetState extends State<HistorySnippet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: widget.sent == true ? Icon(Icons.arrow_upward) : Icon(Icons.arrow_downward),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left:12.0),
              child: widget.sent == true ? Text("SENT") : Text("RECEIVED"),
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(child: Text("15/02/22")),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.sent == true ?
                Text("-\$${widget.amount} (AVAX)", style: TextStyle(color: AppColors.lightBlue),) :
                Text("+\$${widget.amount} (AVAX)", style: TextStyle(color: AppColors.purple)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
