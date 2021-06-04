import 'package:flutter/foundation.dart';

class Notifier extends ChangeNotifier
{
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
  get progress => _progress;
  get total => total;
}