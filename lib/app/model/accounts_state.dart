import 'package:flutter/material.dart';

class AccountsState extends ChangeNotifier
{
  int _progress = 0;
  int _total = 0;
  bool _inProgress = true;
  bool _loadedAccounts = false;
  bool _defaultAccount = false;

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

  set loadedAccounts (bool value)
  {
    _loadedAccounts = value;
    notifyListeners();
  }

  set defaultAccountLoaded (bool value)
  {
    _defaultAccount = value;
    notifyListeners();
  }

  int get progress => _progress;
  int get total => total;
  bool get accountsWasLoaded => _loadedAccounts;
  bool get defaultAccountWasLoaded => _defaultAccount;
}