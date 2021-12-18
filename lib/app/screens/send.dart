import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/transaction_information.dart';
import 'package:avme_wallet/app/screens/qrcode_reader.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class Send extends StatefulWidget {

  final String sendersAddress;
  Send({this.sendersAddress});

  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {

  BuildContext loadingDialog;
  AvmeWallet appState;
  TextEditingController sendersAddress = TextEditingController();
  TextEditingController amount = TextEditingController();
  BigInt bigIntValue;

  void initState()
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AvmeWallet>(context);
    sendersAddress.text = widget.sendersAddress;
    final _formKey = GlobalKey<FormState>();
    // previewBalance = appState.currentAccount.balance;
    // checkTransactionPending();
    return Scaffold(
        appBar:AppBar(title: Text("Send")),
        body: Container(
            child:
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                      Column(
                        children: [
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                flex: 10,
                                child:
                                TextFormField(
                                  controller: sendersAddress,
                                  decoration: InputDecoration(
                                      labelText: "Scan or type the address here.",
                                      icon: FaIcon(FontAwesomeIcons.key, size: 20,)
                                  ),
                                  validator: (value)
                                  {
                                      if(value == null || value.isEmpty || value.length != 42) return "Invalid Address";
                                      return null;
                                  }
                                ),
                              ),
                              Expanded(child: SizedBox()),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    String response = await Navigator.push(context, MaterialPageRoute(builder: (context) => QRScanner()));
                                    snack(response, context);
                                    setState(() {
                                      sendersAddress.text = response;
                                    });
                                  },
                                  child:Icon(Icons.qr_code, size: 25,)
                                ),
                              ),

                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 10,
                                child:
                                TextFormField(
                                  validator: (_value) {
                                    _value = _value.replaceAll(r",", ".");
                                    bigIntValue = bigIntFixedPointToWei(_value);
                                    if(_value.isEmpty && _value != "")
                                    {
                                      return "Invalid Amount";
                                    }
                                    else if (bigIntValue > appState.currentAccount.tokensBalanceList["AVME testnet"]["wei"])
                                    {
                                      return "Balance too low.";
                                    }
                                    return null;
                                  },
                                  controller: amount,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText: "Type the amount",
                                      icon: FaIcon(FontAwesomeIcons.moneyBillAlt, size: 16,)
                                  ),
                                ),
                              ),
                              Expanded(child: SizedBox()),
                              Expanded(
                                flex:2,
                                // width: 55,
                                child:
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                                      ),
                                      onPressed: (){
                                        setState(() {
                                          amount.text = appState.currentAccount.balance;
                                        });
                                      },
                                      child:Text("Max")
                                  ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24,),
                          Center(
                            child: Column(
                              children: [
                                Text("AVME Balance: ${appState.currentAccount.tokenBalance}"),
                                SizedBox(height: 2,),
                                Text("AVAX Balance: ${appState.currentAccount.balance}"),
                                // Text("New Balance: $previewBalance"),
                              ],
                            ),
                          ),
                          SizedBox(height: 24,),
                          Center(child:
                            ElevatedButton(onPressed: () {
                              if (_formKey.currentState != null && _formKey.currentState.validate()) {
                                startTransaction(context);
                              }
                            },
                              child: Text("Enviar"),
                            ),
                          )
                        ],
                      ),
                  ],
                ),
              ),
            )
        )
    );
  }

  double getQrSize(BuildContext context)
  {
    double qrSize = MediaQuery.of(context).size.width <= 200 ?
    MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.6;
    return qrSize;
  }

  void startTransaction(BuildContext context) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        loadingDialog = context;
        return CircularLoading(text: "Requesting Transaction, please wait.");
      },
    );
    // Map<String, dynamic> response = await appState.walletManager.sendTransaction(appState, sendersAddress.text,bigIntValue);
    // Navigator.pop(loadingDialog);
    // if(response["status"] != 200)
    // {
    //   showDialog(
    //     context: context,
    //     barrierDismissible: true,
    //     builder: (BuildContext context) {
    //       return SimpleWarning(title: response["title"],text: response["message"],);
    //     },
    //   );
    // }
  }

  void validateBeforeSending() async
  {
    bool badAmount = ((amount.text).trim() == null ||
        int.parse((amount.text).trim()) == 0) ? true : false;
    bool badAddress = (amount.text == null || sendersAddress.text == null)
        ? true
        : false;

    if (badAmount) {
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) =>
              SimpleWarning(
                  title: "Warning",
                  text:
                  "Invalid amount.")
      );
      return;
    }
    if (badAddress) {
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) =>
              SimpleWarning(
                  title: "Warning",
                  text:
                  "Invalid Address.")
      );
      return;
    }
  }
}
