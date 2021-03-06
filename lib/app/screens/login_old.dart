import 'package:avme_wallet/app/model/app.dart';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:provider/provider.dart';

class LoginOld extends StatefulWidget
{
  //Criando estado do nosso widget
  //retorna o State do nosso Login State
  @override
  State<StatefulWidget> createState() => LoginOldState();

  void onLoad(BuildContext context)
  {
    print('loaded');
  }
}
class LoginOldState extends State<LoginOld> with AfterLayoutMixin <LoginOld>
{
  @override
  Widget build(BuildContext context) {
    AvmeWallet appState = Provider.of<AvmeWallet>(context);
    return Scaffold(
        appBar: AppBar(title: Text(appState.appTitle)),
        body: Row(children: [
          // Row(children: [
          //
          //     Column(
          //       children: [
          //         Image.network(
          //           'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
          //           height: 150,
          //           width: 150,
          //         ),
          //         Image.asset('assets/images/supreme_f.png'
          //         ),
          //       ],
          //     ),
          // ],),
          Row(children:[
            Column(
              children: [
                // ElevatedButton(
                //   onPressed: () {
                //     btn1(context);
                //   },
                //   child: Text("btn1"),
                // ),
                //
                // ElevatedButton(
                //   onPressed: () {
                //
                //   },
                //   child: Text("btn2"),
                // ),
                // ElevatedButton(
                //   onPressed: () {
                //     hasPermission(context);
                //   },
                //   child: Text("hasPermission"),
                // ),

              ],
            ),
          ])
        ])
    );

  }
  onLoad(BuildContext context)
  {

  }
  btn1(context)
  {
    snack("botao apertado", context);
  }
  @override
  void afterFirstLayout(BuildContext context) {
    onLoad(context);
  }
}