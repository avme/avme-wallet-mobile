import 'package:flutter/foundation.dart';

class AppLoadingState extends ChangeNotifier{
  int _progress = 0;
  int _total = 0;
  bool _inProgress = true;

  set progress (int value)
  {
    _progress = value;
    notifyListeners();
  }

  set total (int value)
  {
    _total = value;
    notifyListeners();
  }

  set inProgress (bool value)
  {
    _inProgress = value;
    notifyListeners();
  }
  int get progress => _progress;
  int get total => total;
}

class AvmeWallet extends ChangeNotifier
{
  // AppLoadingState _appLoadingState;
  //
  // set newAppLoadingState(AppLoadingState value) => _appLoadingState = value;
  // AppLoadingState get appLoadingState => _appLoadingState;
  //
  // void init()
  // {
  //   this._appLoadingState = AppLoadingState();
  // }
}