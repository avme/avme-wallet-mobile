import 'package:flutter/material.dart';


class InitialLoading extends StatefulWidget {
  @override
  _InitialLoadingState createState() => _InitialLoadingState();
}

class _InitialLoadingState extends State<InitialLoading> {
  /*GENERIC LOADING SCREEN*/
  @override
  void initState() {
    super.initState();
  }
  void getData(BuildContext context) async
  {
    await Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, "/login");
    });
  }
  @override
  Widget build(BuildContext context) {
    getData(context);
    return Scaffold(
        body:
        Center(
            child:
            Text("Loading App...",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),)
        )
    );
  }
}