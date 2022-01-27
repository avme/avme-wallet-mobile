import 'dart:io';

import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restart/flutter_restart.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool debugMode = false;
  TextEditingController textInput = TextEditingController(
      text: ""
  );

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    String textSize = getTextSize();
    textInput.text = getTextSize();
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
                    title: Text("Advanced Settings", style: AppTextStyles.label,),
                  ),
                ]..addAll(
                  ListTile.divideTiles(
                      context: context,
                      tiles: [
                        ListTile(
                          title: Text("Debug Mode",style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                          leading: Icon(Icons.bug_report_outlined),
                          onTap: () => setState(() => this.debugMode = !this.debugMode),
                          subtitle: Text(
                              debugMode ? "Enabled" : "Disabled"
                          ),
                          trailing: Switch(
                            value: debugMode,
                            onChanged: (bool value) => setState(() => this.debugMode = !this.debugMode),
                          ),
                        ),
                        ListTile(
                          title: Text("Text input sample",style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                          leading: Icon(Icons.verified_user_sharp),
                          onTap: () async {
                            FocusNode fieldFocus = new FocusNode();
                            fieldFocus.requestFocus();
                            await exampleTextPopup(fieldFocus);
                            setState((){});
                            // setState(() => this.debugMode = !this.debugMode);
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
                          // setState(() => this.debugMode = !this.debugMode);
                        },
                        subtitle: Text(this.textInput.value.text),
                      ),
                       */
                      ]
                  ),
                )..addAll([
                  ///Section/Category
                  ListTile(
                    title: Text("Network", style: AppTextStyles.label),
                  ),
                ])..addAll(
                    ListTile.divideTiles(
                        context: context,
                        tiles: [
                          ListTile(
                            title: Text("Wallet API",style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                            leading: Icon(Icons.web),
                            subtitle: Text("api.avme.io:443/",style: TextStyle(fontSize: SizeConfig.fontSize*1.2)),
                          ),
                          ListTile(
                            title: Text("Websocket Server",style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                            leading: Icon(Icons.alternate_email),
                            subtitle: Text("api.avax.network:443/ext/bc/C/rpc",style: TextStyle(fontSize: SizeConfig.fontSize*1.2)),
                          ),
                          ListTile(
                            title: Text("Websocket Client",style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                            leading: Icon(Icons.tag),
                            subtitle: Text("Port: 4812",style: TextStyle(fontSize: SizeConfig.fontSize*1.2)),
                          ),
                        ]
                    )
                )
            ),
          ),
        ),
      ),
    );
  }

  Future<void> exampleTextPopup(FocusNode focus) async {
    SizeConfig().init(context);
    final _size = GlobalKey<FormState>();
    OutlineInputBorder fieldBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: BorderSide(width: 2));
    await showDialog(context: context, builder: (_) {
      int value = 0;
      if (textInput.text.length>2)
        value = int.tryParse(textInput.text.substring(0,2).replaceAll(' ', ''));
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
                Text("Select text size",
                    style:  AppTextStyles.label.copyWith(fontSize: SizeConfig.fontSizeHuge)
                ),
                Text("Default will check for the device's size and change to the appropriate value",
                    style:  AppTextStyles.span.copyWith(fontSize: SizeConfig.fontSizeLarge)
                ),
                Text("Larger text sizes may cause visual problems",
                    style:  AppTextStyles.span.copyWith(fontSize: SizeConfig.fontSizeLarge)
                ),
                SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: value,
                  icon: new Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.labelDefaultColor,
                    size: SizeConfig.safeBlockVertical*4,
                  ),
                  /*
                  validator: (int selected) {
                    if (selected == "Select a Token") {
                      return "Please select a token";
                    }
                    return null;
                  },
                   */
                  onChanged: (int selectedValue) {
                    textInput.text = selectedValue.toString();
                    if (_size.currentState != null)
                      _size.currentState.validate();
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.darkBlue,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    enabledBorder: fieldBorder.copyWith(
                      borderSide: BorderSide(
                        width: 2,
                        color: AppColors.labelDefaultColor,
                      ),
                    ),
                    errorBorder: fieldBorder.copyWith(
                        borderSide: BorderSide(
                          width: 2,
                          color: AppColors.labelDefaultColor,
                        )),
                  ),
                  items: getSizes(),
                ),
                /*
                AppTextFormField(
                  cursorColor: AppColors.labelDefaultColor,
                  focusNode: focus,
                  controller: this.textInput,
                  hintText: "Type anything to update the controller",
                )
                 */
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
              if (_size.currentState != null &&
                  _size.currentState.validate()) {
                //Salvar valor e pop
                // Phoenix.rebirth(context);
                // Navigator.of(context).pop();
                //displaySendTokens(context);
                saveFontSize(textInput.text);
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
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
                              Text('Restarting app...',style: AppTextStyles.label,),
                            ],
                          ),
                        ),
                      ),
                    );
                  })
              );
              await Future.delayed(Duration(seconds: 2));
              FlutterRestart.restartApp();
            },
            textStyle: AppTextStyles.label,
            text: "SAVE (Requires restart)",
            expanded: false,
          )
        ],
      );
    }
    );
  }

  static String getTextSize() {
    List<String> result = [
      '8 (Small)', '10 (Medium)', '12 (Large)'
    ];
    if (SizeConfig.deviceGroupCustom==0)
    {
      if (SizeConfig.deviceGroup == 'SMALL') return result[0];
      if (SizeConfig.deviceGroup == 'MEDIUM') return result[1];
      if (SizeConfig.deviceGroup == 'LARGE') return result[2];
    } else {
      switch(SizeConfig.deviceGroupCustom){
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
        '0 (Default)',
        style: AppTextStyles.label.copyWith(fontSize: SizeConfig.fontSizeLarge*1.2),
      ),
    ));
    SizeConfig.deviceGroupsSize.forEach((element) {
      if(element!=0)
      {
        text = element.toString();
        switch(element){
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
        items.add(
            DropdownMenuItem<int>(
              value: element,
              child: Text(
                //long stuff just to display text with first letter as uppercase
                text,
                style: AppTextStyles.label.copyWith(fontSize: SizeConfig.fontSizeLarge*1.2),
              ),
            )
        );
      }
    });
    return items;
  }

  capitalize(String input)
  {
    return input[0].toUpperCase()+input.substring(1).toLowerCase();
  }


}

void saveFontSize(String fontSize) async {

  final FileManager fileManager = FileManager();

  Future<File> settingsFile()
  async {
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
    if(!await file.exists())
    {
      //add em SizeConfig tambem
      await file.writeAsString(fileManager.encoder.convert({
        "display" : [
          {
            "deviceGroupCustom": "0"
          }
        ]}
      ));
    }

    return file;
  }

  Future<File> fileContacts = settingsFile();
  fileContacts.then((File file) async {
    file.writeAsString(fileManager.encoder.convert({
      "display" : [
        {
          "deviceGroupCustom": "${int.tryParse(fontSize)}"
        }
      ]}
    ));
  });

}

