import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class HistorySnippet extends StatefulWidget {
  final TabController appScaffoldTabController;

  const HistorySnippet({Key key, @required this.appScaffoldTabController}) : super(key: key);

  @override
  _HistorySnippetState createState() => _HistorySnippetState();
}

class _HistorySnippetState extends State<HistorySnippet> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text("History"),
          SizedBox(
            height: 12,
          ),
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.darkBlue
              ),
              child: Column(
                children: [
                  HistoryTable(
                    amount: "32,30",
                    sent: true,
                  ),
                  HistoryTable(
                    amount: "12,99",
                    sent: false,
                  ),
                  HistoryTable(
                    amount: "2,12",
                    sent: false,
                  ),
                  HistoryTable(
                    amount: "15,13",
                    sent: true,
                  ),
                  HistoryTable(
                    amount: "0,37",
                    sent: true,
                  ),
                ],
              )
          ),
          SizedBox(
            height: 12,
          ),
          AppNeonButton(onPressed: () => widget.appScaffoldTabController.index = 2, text: "SHOW FULL HISTORY"),
        ],
      ),
    );
  }
}


class HistoryTable extends StatefulWidget {

  final bool sent;
  final String amount;

  const HistoryTable({Key key, @required this.sent, @required this.amount}) : super(key: key);

  @override
  _HistoryTableState createState() => _HistoryTableState();
}

class _HistoryTableState extends State<HistoryTable> {
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
