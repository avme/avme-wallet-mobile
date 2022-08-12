import 'dart:convert';
import 'dart:math';

import 'package:avme_wallet/app/src/controller/network/network.dart';
import 'package:avme_wallet/app/src/controller/wallet/account.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';
import 'package:avme_wallet/app/src/controller/wallet/wallet.dart' as appWallet;
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/helper/size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';

import 'package:avme_wallet/app/src/helper/utils.dart';
import 'package:avme_wallet/app/src/screen/qr_reader.dart';
import 'package:avme_wallet/app/src/screen/widgets/card.dart';
import 'package:avme_wallet/app/src/screen/widgets/generic.dart';
import 'package:avme_wallet/app/src/screen/widgets/hint.dart';
import 'package:avme_wallet/app/src/screen/widgets/textform.dart';
import 'package:avme_wallet/app/src/screen/widgets/theme.dart';

import '../../controller/wallet/balance.dart';
import '../../controller/wallet/contacts.dart';
import '../widgets/buttons.dart';
import '../widgets/popup.dart';


class Send extends StatefulWidget {
  final TabController appScaffoldTabController;

  const Send({Key? key, required this.appScaffoldTabController}) : super(key: key);

  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {
  final _preTokenForm = GlobalKey<FormState>();
  final _sendTokenForm = GlobalKey<FormState>();

  String tokenDropdownValue = "Select a Token";
  late BigInt gasPriceVal;
  List<String> availableTokens = ["Select a Token", "PLATFORM"];

  TextEditingController addressController = new TextEditingController(
    // text: "0xf98c7b41ca66169e3f32193d39365d3c88fe72ba"
  );
  FocusNode phraseFocusNode = new FocusNode();
/*
  AvmeWallet app;
  */
  // AuthApi _authApi;

  @override
  void initState() {
    // app = Provider.of<AvmeWallet>(context, listen: false);
    availableTokens.addAll(Coins.list.map((e) => e.name));
    print(availableTokens);
    init();
    super.initState();
  }

  Future init() async {
    gasPriceVal = await Network.calculateGasPrice();
  }



  @override
  Widget build(BuildContext context) {
    Color cLabelStyle = AppColors.labelDefaultColor;
    OutlineInputBorder fieldBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(6.0), borderSide: BorderSide(width: 2));
    return Form(
      key: _preTokenForm,
      child: ListView(children: [
        AppCard(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: DeviceSize.safeBlockVertical, horizontal: DeviceSize.safeBlockHorizontal * 2), //all 18
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: DeviceSize.safeBlockVertical),
                  child: AppLabelText(
                    "Address",
                    textStyle: TextStyle(color: AppColors.labelDefaultColor),
                    fontSize: DeviceSize.fontSizeLarge,
                  ),
                ),
                AppTextFormField(
                  controller: addressController,
                  hintText: 'e.g. 0x123456789ABCDEF...',
                  validator: (value) {
                    if(value != null) {
                      if (value.length != 42 || !Utils.isHex(value)) {
                        return 'This is not a valid address';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // String value = addressController.text;
                    if (_preTokenForm.currentState != null) {
                      _preTokenForm.currentState!.validate();
                    }
                  },
                  icon: new Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.labelDefaultColor,
                    size: 32,
                  ),
                  // iconOnTap: () => NotificationBar().show(context, text:"Opening the camera"),
                  iconOnTap: () async {
                    String response = await Navigator.push(context, MaterialPageRoute(builder: (context) => QRScanner()));
                    AppHint.show("Scanned: \"$response\"");
                    setState(() {
                      addressController.text = response;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        AppCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: DeviceSize.safeBlockVertical, horizontal: DeviceSize.safeBlockHorizontal * 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: DeviceSize.safeBlockVertical),
                    child: AppLabelText(
                      "Available Tokens",
                      textStyle: TextStyle(color: AppColors.labelDefaultColor),
                      fontSize: DeviceSize.fontSizeLarge,
                    ),
                  ),
                  DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: tokenDropdownValue,
                      icon: new Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.labelDefaultColor,
                        size: 28,
                      ),
                      elevation: 16,
                      validator: (selected) {
                        if (selected == "Select a Token") {
                          return "Please select a token";
                        }
                        return null;
                      },
                      onChanged: (selectedValue) {
                        tokenDropdownValue = selectedValue ?? "";
                        if (_preTokenForm.currentState != null) {
                          _preTokenForm.currentState!.validate();
                        }
                      },
                      style: TextStyle(color: Colors.white, fontSize: DeviceSize.fontSize),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBlue,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        enabledBorder: fieldBorder.copyWith(
                          borderSide: BorderSide(
                            width: 2,
                            color: cLabelStyle,
                          ),
                        ),
                        errorBorder: fieldBorder.copyWith(
                            borderSide: BorderSide(
                              width: 2,
                              color: AppColors.labelDefaultColor,
                            )
                        ),
                      ),
                      items: availableTokens.map<DropdownMenuItem<String>>((value) {
                        if (value == "PLATFORM") {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: DeviceSize.safeBlockVertical * 1.5),
                                  child: Utils.resolveImage(dotenv.env["PLATFORM_IMAGE"] ?? "assets/avax_logo.png", width: DeviceSize.safeBlockVertical * 3.5),
                                ),
                                Text(
                                  dotenv.env["PLATFORM_SYMBOL"] ?? "NOT FOUND",
                                  style: AppTextStyles.label,
                                ),
                              ],
                            ),
                          );
                        }
                        if (value != availableTokens.first) {
                          CoinData coin = Coins.list.firstWhere((_coin) => _coin.name == value);
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: DeviceSize.safeBlockVertical * 1.5),
                                  // child: Utils.resolveImage(app.activeContracts.sContracts.contractsRaw[value]["logo"], width: DeviceSize.safeBlockVertical * 3.5),
                                  child: Utils.resolveImage(coin.image, width: DeviceSize.safeBlockVertical * 3.5),
                                ),
                                Text(
                                  // "$value (${app.activeContracts.sContracts.contractsRaw[value]["symbol"]})",
                                  "$value (${coin.symbol})",
                                  style: AppTextStyles.label,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }
                      }).toList()
                  )
                ],
              ),
            )
        ),
        /*FutureBuilder<Widget>(
            future: contactList(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Container(
                    height: DeviceSize.safeBlockVertical * 32,
                    child: const Padding(padding: EdgeInsets.all(8.0), child: Text('Something went wrong')),
                  );
                }
                return snapshot.data;
              } else {
                return Container(
                  margin: EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    color: AppColors.purple,
                    strokeWidth: 6,
                  ),
                );
              }
            }),*/
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(),
              ),
              Expanded(
                flex: 2,
                child: AppButton(
                  text: 'CONTINUE',
                  onPressed: () {
                    if (_preTokenForm.currentState != null && _preTokenForm.currentState!.validate()) {
                      displaySendTokens(context);
                      // popupSend();
                    }
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(),
              ),
            ],
          ),
        )
      ]),
    );
  }

  Future<Widget> contactList() async {
    return Container();
    // List<Widget> list = [];
    // List<RecentlySent> recentlySent = [];
    // await RecentlySentTable.instance.readAll().then((value) => recentlySent = value);
    //
    // if (recentlySent.length != 0) {
    //   for (int i = 0; i < recentlySent.length; i++) {
    //     list.add(contactWidget(Contact(recentlySent.elementAt(i).name, recentlySent.elementAt(i).address)));
    //     if (i >= 0 && i < recentlySent.length - 1) list.add(Divider());
    //   }
    // }
    //
    // if (list.isNotEmpty) {
    //   return AppCard(
    //     child: Column(
    //       children: [
    //         Theme(
    //           data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    //           child: Container(
    //             decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), color: AppColors.darkBlue),
    //             child: ExpansionTile(
    //               title: AppLabelText(
    //                 "Frequent contacts",
    //                 textStyle: TextStyle(color: AppColors.labelDefaultColor),
    //                 fontSize: DeviceSize.fontSizeLarge,
    //               ),
    //               subtitle: Text('Tap to expand', style: AppTextStyles.span.copyWith(fontSize: DeviceSize.fontSize * 1.2)),
    //               collapsedIconColor: AppColors.labelDefaultColor,
    //               iconColor: AppColors.purpleVariant2,
    //               children: [
    //                 Container(
    //                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.darkBlue),
    //                   child: Padding(
    //                       padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
    //                       child: Row(
    //                         children: [
    //                           Expanded(
    //                               flex: 2,
    //                               child: Column(
    //                                 children: list,
    //                               )),
    //                         ],
    //                       )),
    //                 )
    //               ],
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // } else {
    //   return Center(child: AppCard(child: Text("No contacts found")));
    // }
  }

  Widget contactWidget(Contact contact) {
    return GestureDetector(
      onTap: () {
        /*
          Share.share(
              "${contact.name} : ${contact.address}",
              subject: "Sharing \"${contact.address}\" address."
          );
        */
        addressController.text = contact.address;
        AppHint.show("Contact ${contact.name} filled in Address Field");
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(),
                    Icon(
                      Icons.account_circle_outlined,
                      size: DeviceSize.titleSize * 1.3,
                      color: AppColors.purple,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.name,
                              style: TextStyle(fontSize: DeviceSize.fontSizeLarge, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              contact.address,
                              style: TextStyle(fontSize: DeviceSize.fontSize, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.labelDefaultColor,
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
  //
  // void popupSend() async {
  //   // Image logo = Utils.resolveImage(dotenv.env['PLATFORM_IMAGE'] ?? "assets/avax_logo.png", width: DeviceSize.safeBlockVertical * 3.5);
  //   showDialog(
  //     context: context,
  //     builder: (_) => StatefulBuilder(builder: (__, setState) {
  //       return AppPopupWidget(
  //         title: "SEND TOKENS",
  //         scrollable: true,
  //         canClose: true,
  //         margin: EdgeInsets.all(32),
  //         cancelable: false,
  //         padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
  //         children: [
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.end,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   Padding(
  //                     padding: EdgeInsets.only(right: 8.0),
  //                     child: logo
  //                   ),
  //                   Text(
  //                     tokenDisplayName,
  //                     style: TextStyle(fontSize: DeviceSize.labelSize * 0.7 + 6),
  //                   ),
  //                 ],
  //               ),
  //             ]
  //           )
  //         ],
  //       );
  //     })
  //   );
  // }

  void displaySendTokens(BuildContext context) async {
    // AppHint.show("Continuing to details screen");
    AccountData current = Account.current();
    double tokenValue = current.platform.inCurrency;
    double tokenQuantity = current.platform.qtd;
    Image logo = Utils.resolveImage(dotenv.env['PLATFORM_IMAGE'] ?? "assets/avax_logo.png", width: DeviceSize.safeBlockVertical * 3.5);
    String gasLimit = dotenv.env["MAX_GAS"] ?? "21000";
    String assetPrice = "1 ${dotenv.env["PLATFORM_SYMBOL"]} = ${Coins.platform.value}";
    String tokenDisplayName = dotenv.env["PLATFORM_SYMBOL"] ?? "AVAX";
    BigInt ether = current.platform.raw;
    if(tokenDropdownValue != "PLATFORM")
    {
      tokenDisplayName = availableTokens.firstWhere((element) => element == tokenDropdownValue);
      Balance balance = current.balance.firstWhere((element) => element.symbol == tokenDropdownValue);
      CoinData coinData = balance.token();
      tokenValue = balance.inCurrency;
      ether = balance.raw;
      tokenQuantity = balance.inCurrency;
      logo = Utils.resolveImage(coinData.image, width: DeviceSize.safeBlockVertical * 3.5);
      assetPrice = "1 ${coinData.symbol} = ${coinData.value}";
    }
    bool disableGasLimit = true;
    bool disableGasPrice = true;
    double convertedValue = 0;
    BigInt weiValue = BigInt.zero;
    // double tokenValue = getTokenValue(app, tokenDropdownValue);
    String msgNoBalance = "Not enough balance.";
    String msgGasPriceLow = "Gas Price too low for network at the moment.";
    /*
    String url = dotenv.get("NETWORK_URL");
    Client httpClient = Client();
    Web3Client ethClient = Web3Client(url, httpClient);
    EtherAmount _gasPriceTemp = EtherAmount.inWei((await ethClient.getGasPrice()).getInWei);
    BigInt addToFee = BigInt.from((5 * pow(10, 9)));
    double gasPriceVal = ((_gasPriceTemp.getInWei + addToFee).toDouble()) / toFromGwei.toInt();*/

    // TextEditingController gasPrice = TextEditingController(text: gasPriceVal.toStringAsFixed(2));
    TextEditingController gasPrice = TextEditingController(text: gasPriceVal.toString());
    TextEditingController amount = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => StatefulBuilder(builder: (builder, setState) {
          return Consumer<Coins>(
            builder: (context, Coins coins, _) => Form(
              key: _sendTokenForm,
              child: AppPopupWidget(
                scrollable: true,
                title: "SEND TOKENS",
                canClose: true,
                margin: EdgeInsets.all(32),
                cancelable: false,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: logo
                          ),
                          Text(
                            tokenDisplayName,
                            style: TextStyle(fontSize: DeviceSize.labelSize * 0.7 + 6),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: DeviceSize.safeBlockVertical,
                      ),
                      Text(assetPrice, style: AppTextStyles.span.copyWith(fontSize: DeviceSize.labelSizeSmall)),
                      SizedBox(
                        height: DeviceSize.safeBlockVertical,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "0.50",
                        ),
                        cursorColor: AppColors.labelDefaultColor,
                        controller: amount,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.end,
                        onChanged: (String string) {
                          double value = double.tryParse(string) ?? 0;
                          double newValue = 0;
                          if (value == 0) { return; }
                          if (tokenDropdownValue == "PLATFORM")
                          {
                            newValue = value * Coins.platform.value;
                          }
                          else
                          {
                            newValue = value * Coins.list.firstWhere((element) => element.symbol == tokenDropdownValue).value;
                          }
                          convertedValue = newValue;
                          if (_sendTokenForm.currentState != null) {
                            _sendTokenForm.currentState!.validate();
                          }

                          setState(() {});
                        },
                        // //TODO: FIX THIS TO USE A SELECTION OF TOKEN
                        validator: (String? _quantity) {
                          if(_quantity == null || _quantity.isEmpty)
                          {
                            Print.mark("meme");
                            return "Not a valid quantity";
                          }
                          double value = double.tryParse(_quantity) ?? 0;
                          double remnant = tokenQuantity - value;
                          Print.warning("remnant $remnant");
                          if (remnant <= 0)
                          {
                            return msgNoBalance;
                          }
                          weiValue = Utils.bigIntFixedPointToWei(value.toStringAsPrecision(6)..replaceAll(r",", "."));
                          Print.mark("weiValue :'$weiValue' ether : '$ether'");
                          if(weiValue > ether) { return msgNoBalance; }
                          // double gasprice = double.tryParse(gasPrice.text)!;
                          // double idk = double.parse(((_gasPriceTemp.getInWei) / toFromGwei).toString());
                          // Print.mark("gasprice: $gasprice");
                          // Print.mark("idk: $idk");
                          if(gasPriceVal > BigInt.parse(gasPrice.text))
                          {
                            return msgGasPriceLow;
                          }
                          // if (double.tryParse(gasPrice.text)! < double.parse(((_gasPriceTemp.getInWei) / toFromGwei).toString())) {
                          //   return msgGasPriceLow;
                          // }
                          return null;
                        },
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: DeviceSize.titleSize * 2.2),
                      ),
                      SizedBox(
                        height: DeviceSize.safeBlockVertical,
                      ),
                      Text(
                        "Balance Preview",
                        style: AppTextStyles.span.copyWith(fontSize: DeviceSize.labelSizeSmall),
                      ),
                      SizedBox(
                        height: DeviceSize.safeBlockVertical,
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(
                            // "\$${Utils.shortReadable(tokenValue.toString(), comma: true, length: 3)} - ",
                            "\$${tokenValue.toStringAsFixed(2)} - ",
                            style: TextStyle(fontSize: DeviceSize.titleSize * 0.7),
                          ),
                          Text(
                            // "\$${Utils.shortReadable(convertedValue.toString(), comma: true, length: 3)} = ",
                            "\$${convertedValue.toStringAsFixed(2)} = ",
                            style: TextStyle(fontSize: DeviceSize.titleSize * 0.7),
                          ),
                          Text(
                            // "\$${Utils.shortReadable((tokenValue - convertedValue).toString(), comma: true, length: 3)}",
                            "\$${(tokenValue - convertedValue).toStringAsFixed(2)}",
                            style: TextStyle(fontSize: DeviceSize.titleSize * 0.7),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: DeviceSize.safeBlockVertical,
                      ),
                    ],
                  ),
                  /*Gas Limit*/
                  Divider(),
                  Padding(
                    padding: EdgeInsets.only(top: DeviceSize.safeBlockVertical * 2, bottom: DeviceSize.safeBlockVertical),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              setState(() {
                                disableGasLimit = !disableGasLimit;
                                if (disableGasLimit) {
                                  if (tokenDropdownValue == 'PLATFORM') {
                                    gasLimit = dotenv.get("MAX_GAS");
                                  } else {
                                    gasLimit = '70000';
                                  }
                                }
                              });
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: Checkbox(
                                      value: disableGasLimit,
                                      fillColor: MaterialStateProperty.resolveWith(getColor),
                                      onChanged: (bool? value) {

                                        if(value != null)
                                        {
                                          disableGasLimit = value;
                                          if (value) {
                                            if (tokenDropdownValue == 'AVAX') {
                                              gasLimit = dotenv.env["MAX_GAS"] ?? "21000";
                                            } else {
                                              gasLimit = '70000';
                                            }
                                          }
                                        }
                                        setState(() {});
                                      }
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "Automatic gas limit",
                                    // style: TextStyle(fontSize: 12.0),
                                    style: TextStyle(fontSize: DeviceSize.fontSize),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                "Gas limit in (WEI)",
                                style: TextStyle(fontSize: DeviceSize.fontSize),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(),
                      ),
                      Expanded(
                        flex: 2,
                        child: AppTextFormField(
                          enabled: !disableGasLimit,
                          controller: TextEditingController(text: gasLimit),
                          textAlign: TextAlign.end,
                          keyboardType: TextInputType.number,
                          contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: DeviceSize.safeBlockVertical * 2,
                  ),
                  /*Recommended fees*/
                  Divider(),
                  Padding(
                    padding: EdgeInsets.only(top: DeviceSize.safeBlockVertical * 2, bottom: DeviceSize.safeBlockVertical),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                disableGasPrice = !disableGasPrice;
                                if (disableGasPrice) {
                                  // gasPrice.text = gasPriceVal.toStringAsFixed(2);
                                  gasPrice.text = "$gasPriceVal";
                                }
                              });
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: Checkbox(
                                        value: disableGasPrice,
                                        fillColor: MaterialStateProperty.resolveWith(getColor),
                                        onChanged: (bool? value) => setState(() {
                                          if(value != null)
                                          {
                                            disableGasPrice = value;
                                            if (value) {
                                              // gasPrice.text = gasPriceVal.toStringAsFixed(2);
                                              gasPrice.text = "$gasPriceVal";
                                            }
                                          }
                                        })
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      "Recommended fees",
                                      style: TextStyle(fontSize: DeviceSize.fontSize),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                "Gas price (In GWEI)",
                                style: TextStyle(fontSize: DeviceSize.fontSize),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(),
                      ),
                      Expanded(
                        flex: 2,
                        child: AppTextFormField(
                          enabled: !disableGasPrice,
                          controller: gasPrice,
                          textAlign: TextAlign.end,
                          keyboardType: TextInputType.number,
                          contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: DeviceSize.safeBlockVertical * 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppButton(
                          expanded: false,
                          onPressed: () => startTransaction(weiValue, gasLimit, gasPrice.text),
                          text: "CONFIRM",
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        })
    );
  }

  Future startTransaction(BigInt weiValue, String gasLimit, String gasPrice) async
  {
    if (_sendTokenForm.currentState != null &&
        _sendTokenForm.currentState!.validate()) {
      ///String receiver, String token, BigInt amount, int maxGas, BigInt gasPrice
      // Print.warning("${addressController.text} $tokenDropdownValue, $weiValue, ${int.parse(gasLimit)} ${BigInt.one}");
      Print.warning("${addressController.text} $tokenDropdownValue, $weiValue, ${int.parse(gasLimit)} ${int.parse(gasPrice)}");
      // String ret = await appWallet.Wallet.makeTransaction(addressController.text, tokenDropdownValue, weiValue, int.parse(gasLimit), BigInt.one);
      // Print.mark("Hash: $ret");
      Print.mark("Hash: hashishi not found");
      // startTransaction(
      //   app,
      //   weiValue,
      //   // int.tryParse(gasLimit.text),
      //   // int.tryParse(gasPrice.text),
      //   int.tryParse(gasLimit.text),
      //   BigInt.from(double.tryParse(gasPrice.text) * toFromGwei.toInt()),
      //   tokenDropdownValue,
      // );
    }
  }

  // void startTransaction(AvmeWallet app, BigInt value, int maxGas, BigInt gasPrice, String token) async {
  //   ValueNotifier<int> percentage = ValueNotifier(10);
  //   ValueNotifier<String> label = ValueNotifier("Starting Transaction");
  //   List<ValueNotifier> loadingNotifier = [percentage, label];
  //   await showDialog(
  //       context: context,
  //       builder: (_) => StatefulBuilder(builder: (builder, setState) {
  //         return Consumer<ContactsController>(builder: (BuildContext context, controller, _) {
  //           return ProgressPopup(
  //               title: "Warning",
  //               listNotifier: loadingNotifier,
  //               future: app.walletManager
  //                   .sendTransaction(app, addressController.text, value, maxGas, gasPrice, token, listNotifier: loadingNotifier)
  //                   .then((response) async {
  //                 if (response["status"] == 200) {
  //                   int position = -1;
  //                   controller.contacts.forEach((key, value) {
  //                     if (value.address == addressController.text) position = key;
  //                   });
  //
  //                   if (position != -1) {
  //                     //Existe em contatos, apenas inserir, a interface da database dá conta
  //                     //de verificar se já existe na database ou se precisa inserir
  //
  //                     //Se não existir na lista de contatos, não deve ser colocado na database, pois não é um contato
  //
  //                     await RecentlySentTable.instance
  //                         .insert(RecentlySent(name: controller.contacts[position].name, address: controller.contacts[position].address));
  //                   }
  //
  //                   Navigator.of(context).pop();
  //                   await Future.delayed(Duration(milliseconds: 250));
  //                   displayTransactionHash(response["message"]);
  //                 } else if (response["status"] == 500) {
  //                   Navigator.of(context).pop();
  //                   await Future.delayed(Duration(seconds: 1));
  //                   showDialog(
  //                       context: context,
  //                       builder: (_) => AppPopupWidget(
  //                           title: "Transaction failed",
  //                           cancelable: true,
  //                           canClose: true,
  //                           showIndicator: false,
  //                           children: [Text("[Error 1] ${response['message']}")]));
  //                 } else {
  //                   Navigator.of(context).pop();
  //                   showDialog(
  //                       context: context,
  //                       builder: (_) => AppPopupWidget(
  //                           title: "Transaction failed",
  //                           cancelable: true,
  //                           canClose: true,
  //                           showIndicator: false,
  //                           children: [Text("[Error 2] Transaction failed")]));
  //                 }
  //               }));
  //         });
  //       }));
  // }
  //
  void displayTransactionHash(String url) {
    Uri uri = Uri.parse(url);
    showDialog(
        context: context,
        builder: (_) =>
            AppPopupWidget(
                title: "Transaction done",
                cancelable: false,
                canClose: true,
                showIndicator: false,
                children: [
                  AppButton(
                      onPressed: () async {
                        AppHint.show("Opening in browser $url");
                        Navigator.of(context).pop();
                        await Future.delayed(Duration(seconds: 2));
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                        else {
                          AppHint.show("Can't open URL $url");
                          print("cant launch url $url");
                        }
                      },
                      text: "Open on Browser")
                ]
            )
    );
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return AppColors.purple;
    }
    return AppColors.purple;
  }
}

// double getTokenValue(AvmeWallet app, String tokenDropdownValue) {
//   double amount = 0;
//   if (tokenDropdownValue == "AVAX")
//     amount = app.currentAccount.networkBalance;
//   else
//     amount = app.currentAccount.tokensBalanceList[tokenDropdownValue]["balance"];
//
//   return amount;
// }
