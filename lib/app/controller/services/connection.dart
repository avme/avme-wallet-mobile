import 'dart:io'; //InternetAddress utility
import 'dart:async'; //For StreamController/Stream
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

class AppConnection
{
  ///Referencia do propio singleton
  static final AppConnection _connection = AppConnection._internal();
  AppConnection._internal();

  ///É aqui que recuperamos a instancia pelo app
  static AppConnection getInstance()
  {
    return _connection;
  }

  ///Armazena a situação atual da conexão
  bool hasConnection = false;

  ///Armazena o tipo de conexão
  ConnectivityResult connectivityResult = ConnectivityResult.none;

  ///Crio um canal para listar as alterações de conexão
  StreamController appConnectionChangeController = StreamController.broadcast();
  ///Crio um canal para listar alterações no tipo de conexão
  StreamController appConnectionTypeChangeController = StreamController.broadcast();

  ///Simple connection checker
  final SimpleConnectionChecker _connectionChecker = SimpleConnectionChecker();
  ///Connectivity plus
  final Connectivity _connectivity = Connectivity();

  ///Ouço o broadcast de SimpleConnectionChecker e redireciono para nosso broadcast
  void initialize ()
  {
    _connectionChecker.setLookUpAddress("google.com");
    _connectivity.onConnectivityChanged.listen(_typeConnectionChange);
    _connectionChecker.onConnectionChange.listen(_connectionChange);
  }

  Stream get connectionChange => appConnectionChangeController.stream;
  Stream get connectionType => appConnectionTypeChangeController.stream;

  void dispose()
  {
    appConnectionChangeController.close();
    appConnectionTypeChangeController.close();
  }

  ///Listeneer da conexão
  void _connectionChange(bool result)
  {
    checkConnection(result);
  }

  ///Listeneer do tipo de conexão
  void _typeConnectionChange(ConnectivityResult result)
  {
    typeOfConnection(result);
  }

  ConnectivityResult typeOfConnection(ConnectivityResult result)
  {
    ConnectivityResult previousType = connectivityResult;
    connectivityResult = result;
    print("type of connection ${result.toString()}");

    if(previousType != connectivityResult)
      appConnectionTypeChangeController.add([hasConnection,connectivityResult]);

    return connectivityResult;
  }

  Future<bool> checkConnection(bool result) async
  {
    bool previousConnection = hasConnection;
    hasConnection = result;
    print("hasConnection?$hasConnection");

    if(previousConnection != hasConnection)
      appConnectionChangeController.add([hasConnection,connectivityResult]);

    return hasConnection;
  }
}