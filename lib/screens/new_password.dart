import 'package:avme_wallet/screens/helper.dart';
import 'package:flutter/material.dart';

class NewPassword extends StatelessWidget with Helpers{
  final senha = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // Prevent user to go back and cause some chaos in the code...
    return new WillPopScope(onWillPop: () async {
      // snack("You cant go back now", context);
      // TODO: implement this dialog as a component
      await showDialog<void>(
        context: context,
        builder: (BuildContext context)
        {
          return AlertDialog(
            title: Text("Warning"),
            //This is a meme...
            content: Text("You can't go back now..."),
            actions: [
              TextButton(
                  onPressed: () {
                    //Pops this alertDialog
                    Navigator.pop(context);
                  },
                  child: Text("OK"))
            ],
          );
        },
      );
      return false;
    },
      child: Scaffold(
        body: Container(
          child: Center(child:
            Column(
              children:
              [
                TextField(
                  controller: senha,
                ),
                ElevatedButton(
                  onPressed: () async
                  {
                    if(senha == null || senha.text.length <= 5)
                    {
                      // TODO: implement this dialog as a component
                      await showDialog<void>(
                        context: context,
                        builder: (BuildContext context)
                        {
                          return AlertDialog(
                            title: Text("Warning"),
                            content: Text("This password is too weak, try something complex!"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    //Pops this alertDialog
                                    Navigator.pop(context);
                                  },
                                  child: Text("OK"))
                            ],
                          );
                        },
                      );
                      // Resets the forms
                      if(senha != null)
                      {
                        senha.text = "";
                      }
                    }
                    else {
                      //Returns the password
                      Navigator.pop<String>(context,senha.text);
                    }
                  },
                  child: Text("Click me"),
                ),
              ]
              ,)
            ,)
        ),
      )
    );
  }
}
