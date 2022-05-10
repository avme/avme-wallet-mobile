import 'dart:convert';
import 'dart:io';

import 'package:avme_wallet/app/controller/authapi.dart';
import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/authentication.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restart/flutter_restart.dart';
import 'package:provider/provider.dart';

import '../widgets/notification_bar.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController textInput = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    String textSize = getTextSize();
    textInput.text = getTextSize();
    //always starts false
    bool debugMode = Provider.of<AvmeWallet>(context, listen: false).debugMode;
    //bool fingerprintAuth = Provider.of<AvmeWallet>(context, listen: false).fingerprintAuth;
    // final String walletApi = 'api.avme.io:443/';
    // final String websocketServer = 'api.avax.network:443/ext/bc/C/rpc';
    //final String walletApi = Provider.of<AvmeWallet>(context, listen: false).networkUrl;
    final String websocketServer = Provider.of<AvmeWallet>(context, listen: false).networkUrl;
    final int websocketClient = Provider.of<AvmeWallet>(context, listen: false).networkPort;
    return Theme(
      data: screenTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
                children: [
              ///Section/Category

              ListTile(
                title: Text(
                  "Security Settings",
                  style: AppTextStyles.label,
                ),
              ),
            ]
                  ..addAll(
                    ListTile.divideTiles(context: context, tiles: [
                      ListTile(
                        title: Text("Fingerprint Authentication", style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                        leading: Icon(Icons.fingerprint),
                        onTap: () {
                          fingerprintPopup(context);
                        },
                      ),
                    ]),
                  )
                  ..addAll([
                    ///Section/Category
                    ListTile(
                      title: Text("Advanced Settings", style: AppTextStyles.label),
                    ),
                  ])
                  ..addAll(
                    ListTile.divideTiles(context: context, tiles: [
                      ListTile(
                        title: Text("Debug Mode", style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                        leading: Icon(Icons.bug_report_outlined),
                        onTap: () => setState(() => debugMode = !debugMode),
                        subtitle: Text(debugMode ? "Enabled" : "Disabled"),
                        trailing: Switch(
                          value: debugMode,
                          onChanged: (bool value) {
                            Provider.of<AvmeWallet>(context, listen: false).debugMode = !(Provider.of<AvmeWallet>(context, listen: false).debugMode);
                            setState(() => debugMode = !debugMode);
                          },
                        ),
                      ),
                      ListTile(
                        title: Text("Text input sample", style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                        leading: Icon(Icons.verified_user_sharp),
                        onTap: () async {
                          await exampleTextPopup();
                          setState(() {});
                          // setState(() => debugMode = !debugMode);
                        },
                        subtitle: Text(textSize),
                      ),

                      /*
                      ListTile(
                        title: Text("Text input sample"),
                        leading: Icon(Icons.verified_user_sharp),
                        onTap: () async {
                          FocusNode fieldFocus = new FocusNode();
                          fieldFocus.requestFocus();
                          await exampleTextPopup(fieldFocus);
                          setState((){});
                          // setState(() => debugMode = !debugMode);
                        },
                        subtitle: Text(this.textInput.value.text),
                      ),
                       */
                    ]),
                  )
                  ..addAll([
                    ///Section/Category
                    ListTile(
                      title: Text("Network", style: AppTextStyles.label),
                    ),
                  ])
                  ..addAll(ListTile.divideTiles(context: context, tiles: [
                    ListTile(
                      title: Text("Wallet API", style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                      leading: Icon(Icons.web),
                      subtitle: Text(websocketServer, style: TextStyle(fontSize: SizeConfig.fontSize * 1.2)),
                    ),
                    ListTile(
                      title: Text("Websocket Server", style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                      leading: Icon(Icons.alternate_email),
                      subtitle: Text(websocketServer, style: TextStyle(fontSize: SizeConfig.fontSize * 1.2)),
                    ),
                    ListTile(
                      title: Text("Websocket Client", style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                      leading: Icon(Icons.tag),
                      subtitle: Text("Port: $websocketClient", style: TextStyle(fontSize: SizeConfig.fontSize * 1.2)),
                    ),
                  ]))),
          ),
        ),
      ),
    );
  }

  Future<void> exampleTextPopup() async {
    SizeConfig().init(context);
    final _size = GlobalKey<FormState>();
    OutlineInputBorder fieldBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(6.0), borderSide: BorderSide(width: 2));
    await showDialog(
        context: context,
        builder: (_) {
          int value = 0;
          if (textInput.text.length > 2)
            value = int.tryParse(textInput.text.substring(0, 2).replaceAll(' ', ''));
          else
            value = int.tryParse(textInput.text);
          return AppPopupWidget(
            title: "Text Size",
            cancelable: false,
            showIndicator: false,
            padding: EdgeInsets.all(20),
            children: [
              Form(
                key: _size,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScreenIndicator(
                      height: SizeConfig.safeBlockVertical * 2,
                      width: MediaQuery.of(context).size.width,
                    ),
                    SizedBox(
                      height: SizeConfig.safeBlockVertical * 3,
                    ),
                    Text("Select text size", style: AppTextStyles.label.copyWith(fontSize: SizeConfig.fontSizeHuge)),
                    Text("Default will check for the device's size and change to the appropriate value",
                        style: AppTextStyles.span.copyWith(fontSize: SizeConfig.fontSizeLarge)),
                    Text("Larger text sizes may cause visual problems", style: AppTextStyles.span.copyWith(fontSize: SizeConfig.fontSizeLarge)),
                    SizedBox(
                      height: 16,
                    ),
                    DropdownButtonFormField<int>(
                      // menuMaxHeight: 300,
                      isExpanded: true,
                      value: value,
                      icon: new Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.purple,
                        size: SizeConfig.safeBlockVertical * 4,
                      ),
                      onChanged: (int selectedValue) {
                        textInput.text = selectedValue.toString();
                        if (_size.currentState != null) _size.currentState.validate();
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBlue,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        border: fieldBorder.copyWith(
                          borderSide: BorderSide(
                            width: 4,
                            color: AppColors.purple,
                          ),
                        ),
                      ),
                      items: getSizes(),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
            ],
            actions: [
              AppButton(
                onPressed: () async {
                  if (_size.currentState != null && _size.currentState.validate()) {
                    //Salvar valor e pop
                    // Phoenix.rebirth(context);
                    // Navigator.of(context).pop();
                    //displaySendTokens(context);
                    file(1, textInput.text);
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AppCard(
                      child: Container(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.purple,
                                strokeWidth: 6,
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                'Restarting app...',
                                style: AppTextStyles.label,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }));
                  await Future.delayed(Duration(seconds: 2));
                  FlutterRestart.restartApp();
                },
                textStyle: AppTextStyles.label,
                text: "SAVE (Requires restart)",
                expanded: false,
              )
            ],
          );
        });
  }

  void fingerprintPopup(context) async {
    SizeConfig().init(context);
    await showDialog(
        context: context,
        builder: (_) {
          SizeConfig().init(context);
          double fieldSpacing = SizeConfig.safeBlockVertical * 2;
          TextEditingController _controller = TextEditingController();

          void setup() async {
            Navigator.pop(context);
            // Authentication _authApi = Authentication();
            AuthApi _authApi = await AuthApi.init();
            AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);
            bool canAuthenticate = app.fingerprintAuth;
            await showDialog(
                context: context,
                builder: (_) {
                  return Theme(
                    data: screenTheme,
                    child: AppPopupWidget(
                        title: "Fingerprint Authentication",
                        cancelable: false,
                        //showIndicator: false,
                        padding: EdgeInsets.all(20),
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    StatefulBuilder(
                                      builder: (BuildContext context, setState) {
                                        return Expanded(
                                          child: ListTile(
                                            title: Text("Fingerprint Authentication", style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                                            leading: Icon(Icons.fingerprint),
                                            onTap: () => setState(() => canAuthenticate = !canAuthenticate),
                                            subtitle: Text(canAuthenticate ? "Enabled" : "Disabled"),
                                            trailing: Switch(
                                              value: canAuthenticate,
                                              onChanged: (bool value) async {
                                                dynamic _temp;
                                                if (_authApi.isHardwareAllowed()) {
                                                  if (canAuthenticate) {
                                                    _temp = await _authApi.deleteSecret();
                                                    if (_temp is String) {
                                                      NotificationBar().show(context, text: 'Fingerprint disabled', onPressed: () {});
                                                      app.fingerprintAuth = !(app.fingerprintAuth);
                                                      file(2, false);
                                                      setState(() => canAuthenticate = !canAuthenticate);
                                                    } else {
                                                      NotificationBar().show(context, text: 'Fingerprint scanning cancelled', onPressed: () {});
                                                    }
                                                  } else {
                                                    _temp = await _authApi.saveSecret(_controller.text);
                                                    if (_temp is String) {
                                                      NotificationBar().show(context, text: 'Fingerprint enabled', onPressed: () {});
                                                      app.fingerprintAuth = !(app.fingerprintAuth);
                                                      file(2, true);
                                                      setState(() => canAuthenticate = !canAuthenticate);
                                                    } else {
                                                      NotificationBar().show(context, text: 'Fingerprint scanning cancelled', onPressed: () {});
                                                    }
                                                  }
                                                } else {
                                                  NotificationBar().show(context,
                                                      text: 'Fingerprint not enabled in device settings.  Please setup fingerprint before enabling.',
                                                      onPressed: () {});
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ]),
                  );
                });
          }

          // void authenticate(String text) async {
          //   //get wallet password somehow
          //   AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);
          //   bool valid = await app.login(text, context, display: true);
          //   if (valid) {
          //     FocusScope.of(context).unfocus();
          //     setup();
          //   }
          // }

          void authenticate(String password) async {
            bool empty = (password == null || password.length == 0) ? true : false;
            if (empty)
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AppPopupWidget(
                        title: 'Warning',
                        cancelable: false,
                        showIndicator: false,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical / 2, bottom: SizeConfig.safeBlockVertical * 3),
                            child: Text('The password field cannot be empty'),
                          ),
                          AppButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            expanded: false,
                            text: "OK",
                          )
                        ],
                      ));
            else {
              AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);
              bool valid = (await app.walletManager.authenticate(password, app, restart: false))["status"] == 200 ? true : false;
              if (valid) {
                FocusScope.of(context).unfocus();
                setup();
              }
            }
          }

          Widget start() {
            return AppPopupWidget(
              title: "Verify Password",
              cancelable: false,
              showIndicator: false,
              padding: EdgeInsets.all(20),
              children: [
                Column(
                  children: [
                    ScreenIndicator(
                      height: SizeConfig.safeBlockVertical * 2,
                      width: MediaQuery.of(context).size.width,
                    ),
                    SizedBox(
                      height: SizeConfig.safeBlockVertical * 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Please type your passphrase.',
                          style: AppTextStyles.span.copyWith(fontSize: SizeConfig.fontSize * 1.5),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: SizeConfig.safeBlockVertical * 2,
                    ),
                    AppTextFormField(
                      controller: _controller,
                      obscureText: true,
                      hintText: "**********",
                      onFieldSubmitted: (_) {
                        authenticate(_controller.text);
                      },
                    ),
                    SizedBox(
                      height: fieldSpacing * 2,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        authenticate(_controller.text);
                      },
                      child: Text("VERIFY PASSWORD"),
                      // style: ElevatedButton.styleFrom(
                      //   padding: EdgeInsets.symmetric(vertical: 21, horizontal: 0),
                      // style: _btnStyleLogin,
                    ),
                  ],
                ),
              ],
            );
          }

          return start();
        });
  }

  static String getTextSize() {
    List<String> result = ['8 (Small)', '10 (Medium)', '12 (Large)'];
    if (SizeConfig.deviceGroupCustom == 0) {
      if (SizeConfig.deviceGroup == 'SMALL') return result[0];
      if (SizeConfig.deviceGroup == 'MEDIUM') return result[1];
      if (SizeConfig.deviceGroup == 'LARGE') return result[2];
    } else {
      switch (SizeConfig.deviceGroupCustom) {
        //breaks aren't needed since it returns a value, breaking out of the case
        case 8:
          return result[0];
        case 10:
          return result[1];
        case 12:
          return result[2];
        default:
          return SizeConfig.deviceGroupCustom.toString();
      }
    }
  }

  List<DropdownMenuItem> getSizes() {
    List<DropdownMenuItem<int>> items = [];
    String text = '';

    items.add(DropdownMenuItem<int>(
      value: 0,
      child: Text(
        //long stuff just to display text with first letter as uppercase
        '0 (System Default)',
        style: AppTextStyles.label.copyWith(fontSize: SizeConfig.fontSizeLarge * 1.2),
      ),
    ));
    SizeConfig.deviceGroupsSize.forEach((element) {
      if (element != 0) {
        text = element.toString();
        switch (element) {
          case 8:
            text += ' (Small)';
            break;
          case 10:
            text += ' (Medium)';
            break;
          case 12:
            text += ' (Large)';
            break;
        }
        items.add(DropdownMenuItem<int>(
          value: element,
          child: Text(
            //long stuff just to display text with first letter as uppercase
            text,
            style: AppTextStyles.label.copyWith(fontSize: SizeConfig.fontSizeLarge * 1.2),
          ),
        ));
      }
    });
    return items;
  }

  capitalize(String input) {
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}

///1 = save size, 2 = fingerprint auth enable
Future<int> file(int option, dynamic input) async {
  //Code has maybe too many checks for different occurrences, would be easier
  //on the phone to leave it more straightforward if we don't add more options

  final FileManager fileManager = FileManager();

  Future<File> settingsFile() async {
    //Implementar praticamente tudo de filemanager para salvar isso...
    await fileManager.getDocumentsFolder();

    //check se o arquivo em com.avme.avme_wallet/app_flutter/
    String fileFolder = "${fileManager.documentsFolder}";

    //getDocumentsFolder deve retornar com.avme.avme_wallet/app_flutter/
    //print(fileFolder);

    //Checar se o arquivo existe.  Se não, criar, se sim, recuperar arquivo
    await fileManager.checkPath(fileFolder);

    //Recupera o arquivo em si, deve ser com.avme.avme_wallet/app_flutter/settings.json
    File file = File("${fileFolder}settings${fileManager.ext}");

    //Checa para ver se file existe, nunca deveria cair aqui
    if (!await file.exists()) {
      //add em SizeConfig tambem
      await file.writeAsString(fileManager.encoder.convert({
        "display": {"deviceGroupCustom": "0"},
        "options": {"fingerprintAuth": false}
      }));
    }

    return file;
  }

  Future<File> file = settingsFile();
  Map<String, dynamic> fileRead = {};

  await file.then((value) async {
    fileRead = json.decode(await value.readAsString());
  });

  print('input $input');
  switch (option) {
    case 1:
      fileRead["display"]["deviceGroupCustom"] = "${int.tryParse(input)}";
      break;
    case 2:
      fileRead["options"]["fingerprintAuth"] = input;
      break;
    default:
      print('Something went wrong');
  }

  file.then((File file) async {
    file.writeAsString(fileManager.encoder.convert(fileRead));
  });

  return 0;
}
