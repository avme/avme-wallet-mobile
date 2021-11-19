import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class DebugOverlay extends StatefulWidget {

  final bool connected;
  final ConnectivityResult connectionType;
  const DebugOverlay({Key key, this.connected, this.connectionType}) : super(key: key);

  @override
  _DebugOverlayState createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {

  TextStyle bold = TextStyle(
      fontWeight: FontWeight.bold
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          color: Colors.red,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(
                                text: "connected: ",
                                style: bold
                            ),
                            TextSpan(
                                text: "${widget.connected}"
                            )
                          ]
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(
                                text: "type: ",
                                style: bold
                            ),
                            textConnection(widget.connectionType)
                          ]
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  TextSpan textConnection(ConnectivityResult type)
  {
    String text = "none";

    if(type == ConnectivityResult.wifi)
      text = "wifi";
    else if(type == ConnectivityResult.mobile)
      text = "mobile";
    return TextSpan(
        text: text
    );
  }
}