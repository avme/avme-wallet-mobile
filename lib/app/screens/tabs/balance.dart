import 'package:flutter/material.dart';
import 'package:avme_wallet/app/controller/globals.dart' as global;
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/services.dart';
import 'package:avme_wallet/app/screens/widgets/qr_reader.dart';

class Balance extends StatefulWidget {
  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance>
{
  double _balance = 0.50;
  double _usdBalance = 21668.80;
  List<double> _btnDimensions = [
    70,
    70
  ];
  TextStyle _tsTab = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500
  );
  ButtonStyle _roundedButton = new ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100)
        )
    ),
  );
  // TODO: implement objects like accounts, balance and transactions
  @override
  Widget build(BuildContext context) {
    return
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap:()
            {
              _copyToClipboard(context);
            },
            child: Container(
              // color: Colors.blueGrey,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(Icons.vpn_key, size: 16,),
                          Text(' Account ' + global.walletManager.selectedAccount.toString(), style: _tsTab,),
                        ],
                      ),
                      SizedBox(height: 4,),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(copyPrivateKey(), style: TextStyle(
                              color: Color.fromRGBO(255,255, 255, 0.75)
                          ),),
                          Text(" "),
                          Icon(Icons.copy, size: 18,),
                        ],
                      ),
                      SizedBox(height: 4,),
                      Text("This data is just a placeholder", style: TextStyle(
                          color: Color.fromRGBO(5, 255, 10, 1)
                      ),),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            // color: Color.fromRGBO(255, 255, 255, 0.095),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical:14.0),
                child: Column(
                    children:
                    [
                      Text(_balance.toString()+" BTC", style: _tsTab.copyWith(fontSize: 22),),
                      SizedBox(height: 2,),
                      Text(_usdBalance.toString()+" USD", style: _tsTab.copyWith(fontSize: 14, color: Color.fromRGBO(255, 255, 255, 0.5)),)
                    ]
                ),
              )
          ),
          Container(
            // color: Colors.pinkAccent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal:20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      children: [
                        SizedBox(
                          height:_btnDimensions[0],
                          width: _btnDimensions[1],
                          child: ElevatedButton(onPressed: (){},
                            child: Icon(Icons.upload_sharp),
                            style: _roundedButton.copyWith(backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),),
                          ),
                        ),
                        Text(" "),
                        Text("SEND")
                      ]
                  ),
                  Column(
                      children: [
                        SizedBox(
                          height:_btnDimensions[0],
                          width: _btnDimensions[1],
                          child: ElevatedButton(onPressed: () async{
                            // String response = await Navigator.push(context, MaterialPageRoute(builder: (context) => QRViewExample()));

                            String response = await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return QrReader();
                              }
                            );
                            //TODO: Use the returned data into transferer screen
                            snack(response, context);
                          },
                            child: Icon(Icons.qr_code_scanner),
                            style: _roundedButton.copyWith(backgroundColor: MaterialStateProperty.all<Color>(Color(
                                0xFF4B4B4B)),),
                          ),
                        ),
                        Text(" "),
                        Text("SCAN")
                      ]
                  ),
                  Column(
                      children: [
                        SizedBox(
                          height:_btnDimensions[0],
                          width: _btnDimensions[1],
                          child: ElevatedButton(onPressed: (){},
                            child: Icon(Icons.download_sharp),
                            style: _roundedButton.copyWith(backgroundColor: MaterialStateProperty.all<Color>(Colors.green),),
                          ),
                        ),
                        Text(" "),
                        Text("RECEIVE")
                      ]
                  )
                ],
              ),
            ),
          ),
          Container(
            // color: Color.fromRGBO(255, 255, 255, 0.095),
              child: SizedBox(
                height: 70,
                width: MediaQuery.of(context).size.width,
              )
          ),
        ],
      );
  }
  String copyPrivateKey()
  {
    String _hex = global.accountList[global.walletManager.selectedAccount].address;
    return _hex.substring(0,12)+"..."+_hex.substring(_hex.length - 12);
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: global.accountList[global.walletManager.selectedAccount].address));
    snack("Address copied to clipboard",context);
  }
}
