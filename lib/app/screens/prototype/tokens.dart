import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/screens/prototype/tokens/nfts.dart';
import 'package:avme_wallet/app/screens/prototype/tokens/token.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/external/fade_indexed_stack.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class TokenTabs extends StatefulWidget {
  @override
  _TokenTabsState createState() => _TokenTabsState();
}

class _TokenTabsState extends State<TokenTabs> {
  int index = 0;
  GlobalKey uniqueId = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        children: [
          AppCardTabs(
            index: this.index,
            tabs: [
              {
                "label" : "Tokens",
                "onTap" : () => changeStack(0),
              },
              {
                "label" : "NFTs",
                "onTap" : () => changeStack(1),
              },
            ],
          ),
          Flexible(
            // flex: 20,
            child: AppCardBody(
              // color: Colors.red,
              child: FadeIndexedStack(
                duration: Duration(milliseconds: 250),
                index: this.index,
                children: [
                  TokenManagement(),
                  NFTManagement(
                    key: uniqueId,
                    // key: UniqueKey(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changeStack(int id)
  {
    if(id != this.index)
      setState(() {
        this.index = id;
      });
  }
}