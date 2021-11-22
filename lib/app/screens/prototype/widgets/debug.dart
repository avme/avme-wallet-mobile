import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DebugOverlay extends StatefulWidget {

  final bool connected;
  final ConnectivityResult connectionType;
  const DebugOverlay({Key key, this.connected, this.connectionType}) : super(key: key);

  @override
  _DebugOverlayState createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {

  bool shouldDisplay = false;

  @override
  Widget build(BuildContext context) {
    bool inDebugMode = Provider.of<AvmeWallet>(context).debugMode;
    if(inDebugMode)
      return Consumer<AvmeWallet>(builder: (context, app, _){
        shouldDisplay = app.debugPanel;
        return GestureDetector(
          onTap: (){
            app.toggleDebugPanel();
          },
          child: _debugPanel(shouldDisplay, app)
        );
      });
    else
      return Container();
  }

  Column _debugPanel(bool shouldDisplay, AvmeWallet app)
  {
    TextStyle textBase = TextStyle(
        fontWeight: FontWeight.normal,
        color: Colors.white
    );
    TextStyle bold = textBase.copyWith(
        fontWeight: FontWeight.bold
    );
    // AvmeWallet app = Provider.of<AvmeWallet>(context);
    MainAxisAlignment mStart = MainAxisAlignment.start;
    CrossAxisAlignment cStart = CrossAxisAlignment.start;

    if(shouldDisplay)
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 12),
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Column(
                      children: [
                        debugTitle("Internet"),
                        Row(
                          crossAxisAlignment: cStart,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: cStart,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                              children: [
                                                TextSpan(
                                                    text: "connected:",
                                                    style: bold
                                                ),
                                                TextSpan(
                                                    text: " ${widget.connected}"
                                                )
                                              ]
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: cStart,
                                children: [
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
                          ],
                        ),
                        debugTitle("Processes"),
                        Row(
                          crossAxisAlignment: cStart,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: cStart,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                              text: "Services: \n",
                                              style: bold,
                                              children: [
                                                TextSpan(
                                                    style: textBase,
                                                    children: app.services.entries.map((serviceName) => TextSpan(text: "\"${serviceName.key}\" ")).toList()
                                                )
                                              ]
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: cStart,
                                children: [
                                  Row(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: "size: ",
                                                  style: bold
                                              ),
                                              TextSpan(
                                                  text: app.services.length.toString()
                                              )
                                            ]
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: cStart,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: cStart,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                              text: "Tokens: \n",
                                              style: bold,
                                              children: [
                                                TextSpan(
                                                    style: textBase,
                                                    children: [
                                                      TextSpan(text: "AVME, "),
                                                      TextSpan(text: "AVAX"),
                                                    ]
                                                )
                                              ]
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      );
    else
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              // color: Colors.blue,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                // shape: BoxShape.rectangle,
                color: Colors.red,
                borderRadius: BorderRadius.all(
                  Radius.circular(8)
                )
              ),
            child: Icon(
              Icons.bug_report_outlined
            ),),
          ),
        ],
      );
  }

  Row debugTitle(String text) {
    TextStyle title = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.double,
        color: Colors.yellow
    );
    return Row(
      children: [
        Text(text, style: title,),
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