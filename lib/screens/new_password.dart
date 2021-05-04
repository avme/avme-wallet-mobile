import 'package:flutter/material.dart';

class NewPassword extends StatelessWidget {
  final senha = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child:
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
      ),
    );
  }
}
