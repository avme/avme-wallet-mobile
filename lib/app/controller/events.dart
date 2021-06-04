import 'package:flutter/foundation.dart';

class EventListeneer with ChangeNotifier
{
    int _foo;
    int _bar;

    int get foo => _foo;
    int get bar => _bar;

    set foo(int value)
    {
        _foo = value;
        notifyListeners();
    }

    set bar(int value)
    {
        _bar = value;
        notifyListeners();
    }
}