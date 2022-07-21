import 'dart:async';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

import '../../helper/size.dart';
import '../../screen/widgets/popup.dart';
import '../routes.dart';

class Connection
{
  static final Connection _self = Connection._internal();
  factory Connection() => _self;
  final String lookUpAddress = "google.com";
  Connection._internal() {
    _connectionChecker.setLookUpAddress(lookUpAddress);
    _connectivity.onConnectivityChanged.listen(_typeConnectionChange);
    _connectionChecker.onConnectionChange.listen(_connectionChange);
  }

  bool hasConnection = false;
  ConnectivityResult connectivityResult = ConnectivityResult.none;

  StreamController appConnectionChangeController = StreamController.broadcast();
  StreamController appConnectionTypeChangeController = StreamController.broadcast();

  final SimpleConnectionChecker _connectionChecker = SimpleConnectionChecker();
  final Connectivity _connectivity = Connectivity();

  Stream get connectionChange => appConnectionChangeController.stream;
  Stream get connectionType => appConnectionTypeChangeController.stream;

  void dispose()
  {
    appConnectionChangeController.close();
    appConnectionTypeChangeController.close();
  }

  void _connectionChange(bool result)
  {
    checkConnection(result);
  }

  void _typeConnectionChange(ConnectivityResult result)
  {
    typeOfConnection(result);
  }

  ConnectivityResult typeOfConnection(ConnectivityResult result)
  {
    ConnectivityResult previousType = connectivityResult;
    connectivityResult = result;
    Print.approve("[Internet] Internet service: ${result.name.toUpperCase()}");

    if(previousType != connectivityResult)
    {
      appConnectionTypeChangeController.add([hasConnection,connectivityResult]);
      appConnectionChangeController.add([hasConnection,connectivityResult]);
    }

    return connectivityResult;
  }

  Future<bool> checkConnection(bool result) async
  {
    bool previousConnection = hasConnection;
    hasConnection = result;
    Print.approve("[Internet] Status: ${hasConnection ? "Connected" : "Disconnected"}");

    if(previousConnection != hasConnection)
    {
      appConnectionChangeController.add([hasConnection,connectivityResult]);
    }

    return hasConnection;
  }

  void trackerOfConnectionWidget()
  {
    BuildContext? context;
    bool prevConnection = hasConnection;
    print("INIT TEM CONEXAO? $prevConnection");

    ///Validating if the device started the app
    ///without any internet connection

    if(!prevConnection)
    {
      context = connectionWidget();
    }

    appConnectionChangeController.stream.listen((connectionEvent) {
      // Print.mark("ConnectionEvent: $connectionEvent");
      // Print.mark("prevConnection: $prevConnection");
      if(connectionEvent is List)
      {
        if(!prevConnection && connectionEvent[0] && context != null) {
          Navigator.pop(context!);
        }
        // Print.mark("prevConnection && !connectionEvent[0] : $prevConnection && ${!connectionEvent[0]}");
        if(prevConnection && !connectionEvent[0])
        {
          context = connectionWidget();
        }
        prevConnection = connectionEvent[0];
      }
    });
  }

  BuildContext connectionWidget()
  {
    BuildContext? context = Routes.globalContext.currentContext;
    showDialog(context: context!, builder:(_) =>
      AppPopupWidget(
        title: "Warning!",
        cancelable: false,
        canClose: false,
        margin: EdgeInsets.symmetric(horizontal: DeviceSize.safeBlockHorizontal * 12),
        children: [
          Row(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: DeviceSize.safeBlockVertical * 2, left: DeviceSize.safeBlockVertical * 1),
                    child: Icon(Icons.warning_rounded, color: Colors.yellow, size: DeviceSize.safeBlockVertical * 6,),
                  )
                ],
              ),
              Flexible(
                child: Text("This Device has no connection to internet.",),
              ),
            ],
          ),
        ],
      )
    );
    return context;
  }
}