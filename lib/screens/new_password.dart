import 'package:flutter/material.dart';
import 'package:avme_wallet/screens/helper.dart';
import 'package:avme_wallet/app/controller/globals.dart' as globals;
import 'package:avme_wallet/screens/widgets/custom_widgets.dart';
class NewPassword extends StatelessWidget with Helpers
{

  final field1 = TextEditingController();
  final field2 = TextEditingController();
  String description1 = "Please use a dificult passphrase, it will be used to enter the Wallet";
  @override
  Widget build(BuildContext context) {
    ListView _view = forms([
      commonText("Please type a passphrase in both fields!"),
      //Field1
      passwordField(field1, "Passphrase"),
      //Field2
      passwordField(field2, "Repeat passphrase"),
      ElevatedButton(
        onPressed: () => validateAndReturnToNavigation(context),
        child: Text("Create Wallet"),
      )
    ]);
    // Prevent user to go back and cause some chaos in the code...
    return new WillPopScope(onWillPop: () async
      {
        // snack("You cant go back now", context);
        // TODO: implement this dialog as a component
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) =>
            SimpleWarning(
                title: "Warning", text: "You can't go back now...")
        );
        return false;
      },
      child: Scaffold(
        body: Container(
          child:
          _view
        )
      ),
    );
  }

  void validateAndReturnToNavigation (BuildContext context) async
  {
    bool empty = (field1 == null || field2 == null) ? true : false;
    bool notEqual = (field1.text != field2.text) ? true : false;
    bool short = (field1.text.length <= 5 || field2.text.length <= 5) ? true : false;

    if(short)
    {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) =>
          SimpleWarning(
            title: "Warning",
            text:
            "Your passphrase is too short!")
      );
      return;
    }
    if(empty)
    {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) =>
          SimpleWarning(
            title: "Warning",
            text:
            "Please, fill in all fields!")
      );
      return;
    }
    if(notEqual)
    {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) =>
          SimpleWarning(
            title: "Warning",
            text:
            "Passphrases don't match."
            +"\n"+
            "Please check your inputs.")
      );
      return;
    }
    BuildContext _loadingPopupContext;

    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          _loadingPopupContext = context;
          return LoadingPopUp(
              text:
              "Loading, please wait."
          );
        }
    );


    // Creates the user account
    await globals.walletManager.makeAccount(field1.text);
    if(globals.walletManager.logged())
    {
      // Navigator.of(context).pop();
      Navigator.pop(_loadingPopupContext);
      Navigator.pushReplacementNamed(context, "/home");
      globals.walletManager.selectedAccount = 0;
      snack("Account #0 selected", context);
      return;
    }
  }
}
