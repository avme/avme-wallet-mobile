import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/metacoin.dart';
import 'package:avme_wallet/app/model/token.dart';
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
                  Text("Account Address:",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                                  widget.appState.watchBalanceUpdates();

                                  String avmeValue = "";
                                  if (widget.appState.currentAccount.rawTokenBalance ==
                                      null) {
                                    avmeValue = "0.00000";
                                  } else {
                                    avmeValue = shortAmount(
                                        widget.appState.currentAccount.tokenBalance);
                                  }
                                  return Text("$avmeValue AVME",
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
                            Selector<AvmeWallet, Token>(
                              selector: (context, token) => token.token,
                              builder: (context, token, child) {
                                widget.appState.watchTokenValueChanges();
                                String _text;
                                _text = token.value != null ? shortAmount(token.value,length: 4, comma: true) : "0,00";
                                return Text("$_text USD",style: TextStyle(fontSize: 12));
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
                                  widget.appState.watchBalanceUpdates();

                                  String avmeValue = "";
                                  if (widget.appState.currentAccount.waiBalance ==
                                      null) {
                                    avmeValue = "0.00000";
                                  } else {
                                    avmeValue = shortAmount(
                                        widget.appState.currentAccount.balance);
                                  }
                                  return Text("$avmeValue AVAX",
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
                            Selector<AvmeWallet, MetaCoin>(
                                selector: (context, model) => model.metaCoin,
                                builder:(context, metaCoin, child) {
                                  String _text;
                                  _text = metaCoin.value != null ? shortAmount(metaCoin.value, length: 3, comma: true) : "0,00";
                                  return Text("$_text USD", style: TextStyle(fontSize: 12),);
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