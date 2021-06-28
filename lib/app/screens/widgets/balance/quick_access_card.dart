import 'package:avme_wallet/app/screens/widgets/balance/quick_action_button.dart';
import 'package:flutter/material.dart';

import '../../qrcode_reader.dart';
import '../../receive.dart';
import '../../send.dart';

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
                Divider(),
                Padding(
                  // padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
                  padding: const EdgeInsets.only(top: 8, bottom: 14.0),
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