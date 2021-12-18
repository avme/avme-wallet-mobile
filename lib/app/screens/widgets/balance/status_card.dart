import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/active_contracts.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/network_token.dart';
import 'package:avme_wallet/app/model/token.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/qr_display.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusCard extends StatefulWidget {
  const StatusCard({
    Key key,
    @required this.appState,
  }) : super(key: key);

  final AvmeWallet appState;

  @override
  _StatusCardState createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  double qrSize;

  ActiveContracts contracts;

  @override
  void initState() {
    contracts = Provider.of<ActiveContracts>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    qrSize = MediaQuery.of(context).size.width / 3.6;
    return Card(
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelText("Account Address:"),
                  SizedBox(
                    height: 8,
                  ),
                  Text(widget.appState.currentAccount.address),
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 2),
                    child: Divider(),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Image.asset(
                            'assets/avme_logo.png',
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("AVME TOKEN",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                            Selector<AvmeWallet, AccountObject>
                              (
                                selector: (context, model) => model.currentAccount,
                                builder:(context, data, child)
                                {
                                  return Text("${shortAmount(widget.appState.currentAccount.tokenBalance())} AVME",
                                      style: TextStyle(fontSize: 12));
                                }
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(" ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                            Selector<Token, String>(
                              selector: (context, activeContracts) => activeContracts.tokenValue("AVME"),
                              builder: (context, tokenValues, child) {
                                // widget.appState.watchTokenValueChanges();
                                contracts.watchTokenValueChanges();
                                return Text("${shortAmount(tokenValues,length: 4, comma: true)} USD",style: TextStyle(fontSize: 12));
                              },),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Image.asset(
                            'assets/avax_logo.png',
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("AVAX",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                            Selector<AvmeWallet, AccountObject>
                              (
                                selector: (context, model) => model.currentAccount,
                                builder:(context, data, child)
                                {
                                  return Text("${shortAmount(widget.appState.currentAccount.balance)} AVAX",
                                      style: TextStyle(fontSize: 12));
                                }
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(" ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                            Selector<AvmeWallet, NetworkToken>(
                                selector: (context, model) => model.networkToken,
                                builder:(context, networkToken, child) {
                                  return Text("${shortAmount(networkToken.value, length: 3, comma: true)} USD", style: TextStyle(fontSize: 12),);
                              }
                            )
                            // Text("1.85 USD", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: qrSize,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            "Account Selected #${widget.appState.currentWalletId}"),
                        SizedBox(height: 8),
                        SizedBox(
                            width: qrSize,
                            height: qrSize,
                            child: QrDisplay(
                              stringToRender:
                              widget.appState.currentAccount.address,
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}