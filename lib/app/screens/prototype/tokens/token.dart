import 'dart:typed_data';

import 'package:avme_wallet/app/controller/services/contract.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/active_contracts.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/labeltext.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:avme_wallet/external/contracts/erc20_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/widget_painter.dart';

class TokenManagement extends StatefulWidget {
  final List<String> protectedTokenManagement = [
    "AVME testnet",
    "AVME",
  ];
  @override
  _TokenManagementState createState() => _TokenManagementState();
}

class _TokenManagementState extends State<TokenManagement> {

  String selectedToken = "AVME testnet";
  AvmeWallet app;
  GlobalKey imageKey;
  @override
  void initState() {
    app = Provider.of<AvmeWallet>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    print("BALANCE");
    print(app.currentAccount.tokensBalanceList);
    return Consumer<ActiveContracts>(builder: (context, activeContracts, _){
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(onPressed: () => details(activeContracts, selectedToken), text: "DETAILS", expanded: false,),
            ],
          ),
          SizedBox(height: SizeConfig.safeBlockVertical * 1.5,),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(SizeConfig.safeBlockVertical),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.darkBlue
              ),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: tokenGrid(activeContracts),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AppButton(onPressed: () => showTokenPopup(app), text: "NEW TOKEN",),
                      SizedBox(height: SizeConfig.safeBlockVertical,),
                      AppButton(onPressed: () => showTokenFromAddress(app), text: "NEW TOKEN FROM ADDRESS",),
                      SizedBox(height: SizeConfig.safeBlockVertical,),
                      !widget.protectedTokenManagement.contains(this.selectedToken)
                          ? AppButton(onPressed: () => removeToken(selectedToken), text: "REMOVE TOKEN",)
                          : AppNeonButton(onPressed: null, text: "CAN'T REMOVE")
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });    // return Container(
  }

  void removeToken(String tokenName)
  {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AppPopupWidget(
          title: "Warning!",
          showIndicator: false,
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 8),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical),
              child: Row(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right:SizeConfig.safeBlockVertical * 1.5),
                        child: Icon(Icons.warning_rounded, color: Colors.yellow, size: SizeConfig.safeBlockVertical * 6,),
                      )
                    ],
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        Text("Are you sure you want to remove this token?",),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          actions: [
            AppButton(
              expanded:false,
              onPressed: () async{
                await app.walletManager.removeToken(app,tokenName);
                Navigator.of(context).pop();
                setState(() {
                  this.selectedToken = widget.protectedTokenManagement.first;
                });
              },
              text: "Remove"
            )
          ],
        );
      },
    );
  }

  Future<void> addedTokenDetails({
    String tokenName,
    int contractDecimals,
    String symbol,
    String address,
    Contracts contractManager,
    String image = "",
    bool updateTokenManagement = true
  })
  async {
    print("DEVERIA ADICIONA? $updateTokenManagement");
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AppPopupWidget(
          title: "Token Details",
          // showIndicator: false,
          cancelable: false,
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 12),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: SizeConfig.screenWidth / 4
              ),
              child: image.length == 0
                  ? WidgetToImage(
                  builder: (key) {
                    this.imageKey = key;
                    return SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomPaint(
                            painter: Circle(),
                          ),
                          Align(
                            child: Text(tokenName[0], style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                            ),),
                            alignment: Alignment.center,
                          ),
                        ],
                      ),
                    );
                  }
              )
                  : resolveImage(image),
            ),
            SizedBox(
              height: SizeConfig.safeBlockVertical * 2,
            ),
            Text(symbol, style: AppTextStyles.label.copyWith(fontSize: 22),),
            SizedBox(height: SizeConfig.safeBlockVertical),
            RichText(text: TextSpan(
                children: <TextSpan> [
                  TextSpan(text: "Name: ", style: AppTextStyles.label),
                  TextSpan(text: "$tokenName",),
                ]
            )),
            SizedBox(height: SizeConfig.safeBlockVertical),
            RichText(text: TextSpan(
                children: <TextSpan> [
                  TextSpan(text: "Decimals: ", style: AppTextStyles.label),
                  // TextSpan(text: "18",),
                  TextSpan(text: contractDecimals.toString(),),
                ]
            )),
            SizedBox(height: SizeConfig.safeBlockVertical),
            RichText(text: TextSpan(
                text: "Address: ", style: AppTextStyles.label
            )),
            SizedBox(height: SizeConfig.safeBlockVertical),
            GestureDetector(
              onTap: () async {
                await Clipboard.setData(
                    ClipboardData(text: address));
                NotificationBar().show(context,text: "Contract address copied to clipboard");
              },
              child: Container(
                color: Colors.transparent,
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        children: [
                          TextSpan(
                            text: address.substring(0,30) + "\n",
                          ),
                          TextSpan(
                            text: address.substring(30),
                          ),
                        ],
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.double,
                            color: Colors.blue
                        )
                    )
                ),
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 2),
            AppButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                text: "CLOSE"
            )
          ],
        );
      },
    ).then((val) async {
      if(updateTokenManagement)
      {
        Uint8List bytes = await captureWidget(this.imageKey);
        bool imageSaved = await contractManager.saveTokenLogo(bytes, address);
        print("IMAGE SAVED? $imageSaved");
        await addTokenPopup(tokenName);
      }

    });
  }

  Future<void> details(ActiveContracts activeContracts, String tokenName)
  async {
    AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);

    ERC20 contractSigner = app.walletManager.signer(
        activeContracts.sContracts.contracts[tokenName][1],
        int.tryParse(activeContracts.sContracts.contracts[tokenName][2]),
        activeContracts.sContracts.contracts[tokenName][0]
    );

    try{
      await contractSigner.decimals();
    } catch(e) {
      NotificationBar().show(
          context,
          text: 'An error occurred',
          onPressed: ()  {
          }
      );
      throw FormatException('An error occurred');
    }

    int contractDecimals = (await contractSigner.decimals()).toInt();

    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AppPopupWidget(
          title: "Token Details",
          // showIndicator: false,
          cancelable: false,
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 12),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: SizeConfig.screenWidth / 4
              ),
              child: resolveImage(
                  activeContracts.sContracts.contractsRaw[tokenName]["logo"]
              ),
            ),
            SizedBox(
              height: SizeConfig.safeBlockVertical * 2,
            ),
            Text(activeContracts.sContracts.contractsRaw[tokenName]["symbol"], style: AppTextStyles.label.copyWith(fontSize: 22),),
            SizedBox(height: SizeConfig.safeBlockVertical),
            RichText(text: TextSpan(
                children: <TextSpan> [
                  TextSpan(text: "Name: ", style: AppTextStyles.label),
                  TextSpan(text: "$tokenName",),
                ]
            )),
            SizedBox(height: SizeConfig.safeBlockVertical),
            RichText(text: TextSpan(
                children: <TextSpan> [
                  TextSpan(text: "Decimals: ", style: AppTextStyles.label),
                  // TextSpan(text: "18",),
                  TextSpan(text: contractDecimals.toString(),),
                ]
            )),
            SizedBox(height: SizeConfig.safeBlockVertical),
            RichText(text: TextSpan(
                text: "Address: ", style: AppTextStyles.label
            )),
            SizedBox(height: SizeConfig.safeBlockVertical),
            GestureDetector(
              onTap: () async {
                await Clipboard.setData(
                    ClipboardData(text: activeContracts.sContracts.contractsRaw[tokenName]["address"]));
                NotificationBar().show(context,text: "Contract address copied to clipboard");
              },
              child: Container(
                color: Colors.transparent,
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                            activeContracts.sContracts.contractsRaw[tokenName]["address"].toString().substring(0,30) + "\n",
                          ),
                          TextSpan(
                            text:
                            activeContracts.sContracts.contractsRaw[tokenName]["address"].toString().substring(30),
                          ),
                        ],
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.double,
                            color: Colors.blue
                        )
                    )
                ),
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical),
          ],
          actions: [
            AppButton(
                expanded:false,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                text: "CLOSE"
            )
          ],
        );
      },
    );
  }

  GridView tokenGrid(ActiveContracts activeContracts)
  {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      // padding: EdgeInsets.all(8),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      // childAspectRatio : (itemWidth / itemHeight),
      children: activeContracts.tokens.map(
              (tokenName) => GestureDetector(
            onTap: (){
              setState((){
                this.selectedToken = tokenName;
              });
            },
            child: TokenItem(
              tokenName: tokenName,
              contractObj: activeContracts.sContracts,
              selected: this.selectedToken,
            ),
          )
      ).toList(),
    );
  }

  void showTokenFromAddress(AvmeWallet app)
  {
    bool validAddress = false;
    TextEditingController contractAddress = TextEditingController(
        text: ""
    );
    showDialog(context: context, builder: (_) =>
        StatefulBuilder(builder: (context,setState) {
          return AppPopupWidget(
              title: "Add new Token",
              cancelable: false,
              canClose: true,
              padding: EdgeInsets.zero,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    [
                      AppLabelText("Token Address", fontSize: 18,),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 2,
                      ),
                      AppTextFormField(
                        maxLength: 42,
                        controller: contractAddress,
                        hintText: 'e.g. 0x123456789ABCDEF...',
                        onChanged: (String value) {
                          if(value.length == 42)
                            setState((){
                              validAddress = true;
                            });
                          else if(validAddress)
                            setState((){
                              validAddress = !validAddress;
                            });
                        },
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 2,
                      ),
                      AppButton(
                          enabled: validAddress,
                          onPressed: () async {
                            Contracts contractManager = app.activeContracts.sContracts;
                            ValueNotifier<int> percentage = ValueNotifier(0);
                            ValueNotifier<String> label = ValueNotifier("Loading...");
                            List<ValueNotifier> loadingNotifier = [
                              percentage,
                              label
                            ];
                            ///Checking if was already added
                            Map<String,Map> discoveredToken = {};
                            contractManager.contractsRaw.forEach((key, Map value) {
                              if(value["address"] == contractAddress.text)
                              {
                                discoveredToken[key] = value;
                                bool shouldUpdate = !app.activeContracts.tokens.contains(discoveredToken.entries.first.key);
                                if(shouldUpdate)
                                  app.activeContracts.addToken(discoveredToken.entries.first.key);
                                addedTokenDetails(
                                    tokenName: discoveredToken.entries.first.key,
                                    symbol: discoveredToken.entries.first.value["symbol"],
                                    address: discoveredToken.entries.first.value["address"],
                                    contractDecimals: int.parse(discoveredToken.entries.first.value["decimals"]),
                                    contractManager: contractManager,
                                    image: discoveredToken.entries.first.value["logo"],
                                    updateTokenManagement: shouldUpdate
                                );
                              }
                            });
                            if(discoveredToken.length > 0)
                              return null;
                            await showDialog(context: context, builder: (_) =>
                                StatefulBuilder(
                                  builder: (builder, setState){
                                    return ProgressPopup(
                                      showIndicator: false,
                                      listNotifier: loadingNotifier,
                                      future: contractManager
                                          .addTokenFromAddress(
                                        accountAddress: app.currentAccount.address,
                                        contractAddress: contractAddress.text,
                                      )
                                          .then((List result) async {
                                        if(result.length == 0)
                                          return [
                                            Text("Sorry, but no Contracts was found.")
                                          ];
                                        else
                                        {
                                          Navigator.of(context).pop();
                                          await Future.delayed(Duration(milliseconds: 250));
                                          Navigator.of(context).pop();
                                          addedTokenDetails(
                                              tokenName: result[0],
                                              symbol: result[1],
                                              address: result[2],
                                              contractDecimals: result[3],
                                              contractManager: contractManager
                                          );
                                        }
                                      }
                                      ),
                                      title: "Warning",
                                    );
                                  },
                                )
                            );
                          },
                          text: "ADD TOKEN"),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 2,
                      ),
                      AppButton(onPressed: () {
                        Navigator.of(context).pop();
                      }, text: "CANCEL"),
                    ]
                )
              ]
          );
        })
    );
  }

  void showTokenPopup(AvmeWallet app)
  {
    ScrollController controller = ScrollController();
    TextEditingController filterController = TextEditingController();
    List<Widget> rows = [];
    Map contractsRaw = app.activeContracts.sContracts.contractsRaw;
    List activeContracts = app.activeContracts.tokens;
    String selected = "";
    showDialog(context: context, builder: (_) =>
        StatefulBuilder(builder: (context, setState) {
          rows = [];
          ///Filtering
          Map filtered = {};
          if(filterController.text.length > 0)
            contractsRaw.forEach((key, param) {
              if(key.toString().toUpperCase().contains(filterController.text.toUpperCase())
                  || param['symbol'].toUpperCase().contains(filterController.text.toUpperCase()))
                filtered[key] = param;
            });
          if (filtered.length == 0)
            filtered = contractsRaw;
          filtered.forEach((key, param) {
            if(!activeContracts.contains(key))
              rows.add(
                  GestureDetector(
                    onTap: (){
                      setState((){
                        selected = key;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: SizeConfig.safeBlockVertical / 2),
                      child: Card(
                        color: key == selected ? AppColors.purple : AppColors.cardDefaultColor,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal, vertical: SizeConfig.safeBlockVertical),
                          subtitle: Text(key),
                          leading: resolveImage(param['logo'], width: SizeConfig.safeBlockVertical * 8),
                          title: Text(param['symbol']),
                          // trailing: Text(key),
                        ),
                      ),
                    ),
                  )
              );
          });
          return AppPopupWidget(
            title: 'Add new Token',
            canClose: true,
            cancelable: false,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLabelText("Filter", fontSize: 18,),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 2,
                  ),
                  AppTextFormField(
                    controller: filterController,
                    hintText: 'Filter by Symbol or Name',
                    onChanged: (String value) {
                      if(value.length > 0)
                        setState((){});
                    },
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 2,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.darkBlue
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.safeBlockVertical,
                          top: SizeConfig.safeBlockVertical,
                          bottom: SizeConfig.safeBlockVertical,
                          right: SizeConfig.safeBlockVertical / 2
                      ),
                      child: Column(
                        children: [
                          selected.length != 0
                              ? SizedBox(height: SizeConfig.safeBlockVertical * 2,)
                              : Container(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              selected.length != 0
                                  ? Padding(
                                padding: EdgeInsets.only(right: SizeConfig.safeBlockVertical),
                                child: RichText(text: TextSpan(
                                    children: [
                                      TextSpan(text: "Selected: "),
                                      TextSpan(text: selected, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ]),
                                ),
                              )
                                  : Container(),
                            ],
                          ),
                          selected.length != 0
                              ? SizedBox(height: SizeConfig.safeBlockVertical * 2,)
                              : Container(),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: SizeConfig.safeBlockVertical * 30,
                            ),
                            child: Scrollbar(
                                controller: controller,
                                child: ListView.builder(
                                  controller: controller,
                                  shrinkWrap: true,
                                  itemCount: rows.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return rows[index];
                                  },
                                )
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: SizeConfig.safeBlockVertical * 2,
              ),
              AppButton(
                enabled: selected.length > 0 ? true : false,
                onPressed: () async {
                  await addTokenPopup(selected);
                  await Future.delayed(Duration(milliseconds: 50));
                  Navigator.of(context).pop();
                },
                text: "ADD TOKEN"
              ),
              SizedBox(
                height: SizeConfig.safeBlockVertical * 2,
              ),
              AppButton(onPressed: () {
                Navigator.of(context).pop();
                selected = "";
              }, text: "CANCEL"),
            ],
          );
        }
      )
    );
  }

  Future addTokenPopup(String token) async {
    ValueNotifier<int> percentage = ValueNotifier(0);
    ValueNotifier<String> label = ValueNotifier("Loading...");
    List<ValueNotifier> loadingNotifier = [
      percentage,
      label
    ];
    await showDialog(context: context, builder: (_) =>
        StatefulBuilder(
          builder: (builder, setState){
            return ProgressPopup(
              listNotifier: loadingNotifier,
              future: app.walletManager.addNewToken(context, token, notifier: loadingNotifier)
                  .then((result) {
                Navigator.of(context).pop();
              }
              ),
              title: "Processing...",
            );
          },
        )
    );
  }
}
class TokenItem extends StatefulWidget
{
  final String tokenName;
  final Contracts contractObj;
  final String selected;
  const TokenItem({
    Key key,
    @required this.tokenName,
    @required this.contractObj,
    @required this.selected
  }) : super(key: key);

  @override
  _TokenItemState createState() => _TokenItemState();
}
class _TokenItemState extends State<TokenItem> {
  @override
  Widget build(BuildContext context) {
    // print(widget.contractObj.contractsRaw);
    return Container(
      // color: AppColors().randomPrimaries(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: widget.selected == widget.tokenName ? Color(0XFF569fa8) : null,
        // border: Border.all(
        //     color: AppColors.purple,
        //     width: 2
        // ),
      ),
      padding: EdgeInsets.all(SizeConfig.safeBlockVertical),
      child: Column(
        children: [
          Expanded(child: resolveImage(widget.contractObj.contractsRaw[widget.tokenName]["logo"])),
          Padding(
            padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical),
            child: Text("${widget.tokenName}",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          Text("(${widget.contractObj.contractsRaw[widget.tokenName]["symbol"]})",
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}