import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class InitialLoading extends StatefulWidget {
  @override
  _InitialLoadingState createState() => _InitialLoadingState();
}

// class _InitialLoadingState extends State<InitialLoading> with AfterLayoutMixin <InitialLoading>{
class _InitialLoadingState extends State<InitialLoading> {
  //LIFE CYCLE
  /*GENERIC LOADING SCREEN*/
  @override
  void initState() {
    super.initState();
    getData();
  }
  void getData() async
  {
    await Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, "/options");
      // Navigator.popAndPushNamed(context, "/");
      // Navigator.pop(context,this);
      // debugPrint("Pushed");
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueAccent,
        body:
        Center(
            child: SpinKitDualRing(
              color: Colors.white,
              size: 50.0,
            ),
        )
    );
  }
}