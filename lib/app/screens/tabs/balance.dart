import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/qrcode_reader.dart';
import 'package:avme_wallet/app/screens/send.dart';
import 'package:avme_wallet/app/screens/widgets/qr_display.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/services.dart';
import 'package:avme_wallet/app/screens/widgets/qr_reader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

import '../receive.dart';

class Balance extends StatefulWidget {
  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  AvmeWallet appState;
  double qrSize;

  Widget build(BuildContext context) {

    appState = Provider.of<AvmeWallet>(context);
    balanceServiceIsRunning(appState);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ///Main info card
            StatusCard(appState: appState),
            SizedBox(
              height: 8,
            ),
            ///Quick-access card
            QuickAccessCard()
          ],
      )),
    );
  }

  String copyPrivateKey() {
    String _hex = appState.currentAccount.address;
    return _hex.substring(0, 12) + "..." + _hex.substring(_hex.length - 12);
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(
        ClipboardData(text: appState.currentAccount.address));
    snack("Address copied to clipboard", context);
  }

  void balanceServiceIsRunning(AvmeWallet appState) {
    if (!appState.services.containsKey("watchBalanceChanges")) {
      appState.walletManager.getBalance(appState);
    }
  }
}

class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 8.0,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Actions:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Padding(
                  padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      QuickActionButton(
                        buttonColor: Colors.green,
                        buttonIcon: Icons.upload_sharp,
                        buttonLabel: "Send",
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (builder) => Send()));
                        },),
                      QuickActionButton(
                        buttonColor: Colors.grey,
                        buttonIcon: Icons.qr_code,
                        buttonLabel: "Scan QR",
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (builder) => QRScanner()));
                        },),
                      QuickActionButton(
                        buttonColor: Colors.blue,
                        buttonIcon: Icons.download,
                        buttonLabel: "Receive",
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (builder) => Receive()));
                        },),
                    ],
                  ),
                ),
              ],
            )
        )
    );
  }
}

class QuickActionButton extends StatelessWidget {
  QuickActionButton({
    @required this.buttonColor,
    @required this.buttonLabel,
    @required this.buttonIcon,
    @required this.onPressed
  });

  final Color buttonColor;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onPressed;

  final ButtonStyle _roundedButton = new ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
  );
  final List<double> _btnDimensions = [70, 70];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _btnDimensions[0],
          width: _btnDimensions[1],
          child: ElevatedButton(
            onPressed: onPressed,
            child: Icon(buttonIcon),
            style: _roundedButton.copyWith(
              backgroundColor:
                  MaterialStateProperty.all<Color>(this.buttonColor),
            ),
          ),
        ),
        SizedBox(
          height: 14,
        ),
        Text(this.buttonLabel,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

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
                            Text("2.00 USD", style: TextStyle(fontSize: 12)),
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
                            Text("1.85 USD", style: TextStyle(fontSize: 12)),
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
