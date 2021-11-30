import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool debugMode = false;
  TextEditingController textInput = TextEditingController(
    text: "0.2"
  );
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: screenTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: SafeArea(
          child: Column(
            // physics: BouncingScrollPhysics(),
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
                      title: Text("Debug Mode"),
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
                  ]
                ),
            )..addAll([
              ///Section/Category
              ListTile(
                title: Text("Network", style: AppTextStyles.label,),
              ),
            ])..addAll(
              ListTile.divideTiles(
                context: context,
                tiles: [
                  ListTile(
                    title: Text("Wallet API"),
                    leading: Icon(Icons.web),
                    subtitle: Text("api.avme.io:443/"),
                  ),
                  ListTile(
                    title: Text("Websocket Server"),
                    leading: Icon(Icons.alternate_email),
                    subtitle: Text("api.avax.network:443/ext/bc/C/rpc"),
                  ),
                  ListTile(
                    title: Text("Websocket Client"),
                    leading: Icon(Icons.tag),
                    subtitle: Text("Port: 4812"),
                  ),
                ]
              )
            )
          ),
        ),
      ),
    );
  }

  Future<void> exampleTextPopup(FocusNode focus) async =>
    await showDialog(context: context, builder: (_) =>
      AppPopupWidget(
        title: "A Popup",
        cancelable: false,
        showIndicator: false,
        padding: EdgeInsets.all(20),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Text input sample",
                  style:  AppTextStyles.label
              ),
              SizedBox(
                height: 16,
              ),
              AppTextFormField(
                cursorColor: AppColors.labelDefaultColor,
                focusNode: focus,
                controller: this.textInput,
                hintText: "Type anything to update the controller",
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
        ],
        actions: [
          AppButton(
            onPressed: () => Navigator.of(context).pop(),
            textStyle: AppTextStyles.label,
            text: "SAVE",
            expanded: false,
          )
        ],
      )
  );


}



