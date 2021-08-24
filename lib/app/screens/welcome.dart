import 'package:avme_wallet/app/controller/wallet_manager.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.purpleVariant1,
              AppColors.purpleBlue
            ]
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(
                  (MediaQuery.of(context).size.width * 0.1).toDouble()
              ),
              child: Card(
                color: AppColors.cardBlue,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                          "Welcome to AVME",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 28)
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      ScreenIndicator(
                        height: 20,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 32,
                            ),
                            AppButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (builder) => NewAccount()));
                              },
                              text: "CREATE NEW WALLET",
                            ),
                            SizedBox(
                              height: 32,
                            ),
                            AppNeonButton(
                              onPressed: () {},
                              text: "IMPORT WALLET",
                              textStyle: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                            SizedBox(
                              height: 32,
                            ),
                            AppNeonButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/login");
                              },
                              text: "LOAD WALLET",
                              textStyle: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewAccount extends StatefulWidget {
  @override
  _NewAccountState createState() => _NewAccountState();
}

class _NewAccountState extends State<NewAccount> {
  // FocusNode seedFocusNode = new FocusNode();
  FocusNode phraseFocusNode = new FocusNode();
  FocusNode rePhraseFocusNode = new FocusNode();
  // TextEditingController _passphrase = new TextEditingController(
  //   text: "i wanna love you"
  // );

  String walletSeed;
  WalletManager appWalletManager;
  @override
  initState() {

    appWalletManager = Provider.of<AvmeWallet>(context, listen: false).walletManager;
    this.walletSeed = this.walletSeed ?? appWalletManager.newMnemonic();
    // seedFocusNode.addListener(() {
    //   setState(() => null);
    // });

    phraseFocusNode.addListener(() {
      setState(() => null);
    });

    rePhraseFocusNode.addListener(() {
      setState(() => null);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.purpleVariant1,
                  AppColors.purpleBlue
                ]
            )
        ),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(
                        (MediaQuery.of(context).size.width * 0.1).toDouble()
                    ),
                    child: Card(
                      color: AppColors.cardBlue,
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 32,
                            horizontal: 32,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ///Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ///Close button
                                        GestureDetector(
                                          child: Container(
                                            color: Colors.transparent,
                                            // color: Colors.red,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16,
                                                  bottom: 10,
                                                  // left: 16,
                                                  right: 16
                                              ),
                                              child: Icon(
                                                Icons.arrow_back,
                                                size: 32,
                                                color: AppColors.labelDefaultColor,
                                              ),
                                            ),
                                          ),
                                          onTap: (){
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Create New",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 28)
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(),
                                  )
                                ],
                              ),
                              ScreenIndicator(
                                height: 20,
                                width: MediaQuery.of(context).size.width,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Column(
                                  children: [
                                    ///Seed Phrase
                                    Padding(
                                      padding: const EdgeInsets.only(top:16),
                                      child: Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              NotificationBar().show(context, text: "Display the full Seed");
                                              AppPopup().show(
                                                context:context,
                                                title: Text("Warning",
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w500
                                                    ),
                                                  ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 32,
                                                  vertical: 24
                                                ),
                                                children: [
                                                  Text(" This is your seed, keep it in a safe place where other people cannot find it."),
                                                  //TODO: Implement seed in table/row
                                                ]
                                              );
                                            },
                                            child: TextField(
                                              controller: new TextEditingController(
                                                text:
                                                  this.walletSeed.substring(0, maxCharacteresInsideTextField(context)).trim() + "..."
                                              ),
                                              enabled: false,
                                              cursorColor: AppColors.labelDefaultColor,
                                              // maxLines: 1,
                                              // focusNode: seedFocusNode,
                                              decoration: InputDecoration(
                                                disabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(width: 2,
                                                    color: Colors.grey[600]
                                                  )
                                                ),
                                                labelText: "Seed",
                                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(width: 2,
                                                    color: AppColors.labelDefaultColor
                                                  )
                                                ),
                                                labelStyle: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 20
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(width: 2,
                                                      color: Colors.white
                                                  ),
                                                ),
                                              )
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: SizedBox(
                                                height: double.infinity,
                                                width: 48,
                                                child: IconButton(
                                                  onPressed: () {
                                                    NotificationBar().show(context, text: "A new seed was generated");
                                                    setState(() {
                                                      this.walletSeed = appWalletManager.newMnemonic();
                                                    });
                                                  },
                                                  icon: Icon(Icons.refresh),
                                                  splashColor: Colors.transparent,
                                                  highlightColor: Colors.transparent,
                                                ),
                                              )
                                            )
                                          ),
                                        ],
                                      ),
                                    ),
                                    ///Passphrase
                                    Padding(
                                      padding: const EdgeInsets.only(top:32),
                                      child: TextField(
                                        cursorColor: AppColors.labelDefaultColor,
                                        obscureText: true,
                                        focusNode: phraseFocusNode,
                                        decoration: InputDecoration(
                                          labelText: "Passphrase",
                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(width: 2,
                                              color: AppColors.labelDefaultColor,
                                            ),
                                          ),
                                          labelStyle: TextStyle(
                                            color: phraseFocusNode.hasFocus ? Colors.white : AppColors.labelDefaultColor,
                                            fontWeight: phraseFocusNode.hasFocus ? FontWeight.w900 : FontWeight.w500,
                                            fontSize: 20
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(width: 2,
                                              color: Colors.white
                                            ),
                                          ),
                                        )
                                      ),
                                    ),
                                    ///Confirm Passphrase
                                    Padding(
                                      padding: const EdgeInsets.only(top:32),
                                      child: TextField(
                                        cursorColor: AppColors.labelDefaultColor,
                                        obscureText: true,
                                        focusNode: rePhraseFocusNode,
                                        decoration: InputDecoration(
                                          labelText: "Confirm passphrase",
                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(width: 2,
                                              color: AppColors.labelDefaultColor
                                            )
                                          ),
                                          labelStyle: TextStyle(
                                            color: rePhraseFocusNode.hasFocus ? Colors.white : AppColors.labelDefaultColor,
                                            fontWeight: rePhraseFocusNode.hasFocus ? FontWeight.w900 : FontWeight.w500,
                                            fontSize: 20
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(width: 2,
                                              color: Colors.white
                                            ),
                                          ),
                                        )
                                      ),
                                    ),
                                    SizedBox(
                                      height: 32,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: Text("CREATE NEW WALLET"),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int maxCharacteresInsideTextField(BuildContext context)
  {
    int size = (MediaQuery.of(context).size.width / 17).round();
    return size;
  }
}

class PopupSeed extends StatelessWidget {

  final String seed;

  const PopupSeed({Key key, this.seed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: AppColors.cardDefaultColor,
        contentPadding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)
        ),
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ///Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///Close button
                        GestureDetector(
                          child: Container(
                            color: Colors.transparent,
                            // color: Colors.red,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 10,
                                  left: 16,
                                  right: 16
                              ),
                              child: Icon(Icons.close),
                            ),
                          ),
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        LabelText("widget.title"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  )
                ],
              ),
              ScreenIndicator(
                height: 20,
                width: MediaQuery.of(context).size.width * 1 / 1.8,
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(
                        top: 32.0,
                        left: 8,
                        right: 8,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right:12.0),
                                child: Icon(Icons.copy),
                              ),
                              Flexible(
                                child: Column(
                                  children: [
                                    Text("widget.address"),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 24,),
                          AppButton(
                            mainAxisAlignment: MainAxisAlignment.start,
                            paddingBetweenIcons: 16,
                            text: "ACCOUNT 1",
                            onPressed: () {},
                            iconData: Icons.account_circle_outlined,
                          ),
                          SizedBox(height: 18,),
                          AppNeonButton(
                            mainAxisAlignment: MainAxisAlignment.start,
                            paddingBetweenIcons: 16,
                            text: "SHARE",
                            iconData: Icons.share,
                            onPressed: () {},
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}
