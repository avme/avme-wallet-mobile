class Print {
  static final Print _self = Print._internal();
  bool debug = false;
  Print._internal();
  
  factory Print({bool debug = false}) {
    _self.debug = debug;
    return _self;
  }
  
  static void ok(String text) {
    _self.checkDebug('\x1B[34m$text\x1B[0m');
  }

  static void warning(String text) {
    _self.checkDebug('\x1B[33m$text\x1B[0m');
  }

  static void error(String text) {
    _self.checkDebug('\x1B[31m$text\x1B[0m');
  }

  static void approve(String text)
  {
    _self.checkDebug('\x1B[32m$text\x1B[0m');
  }

  static void mark(String text)
  {
    _self.checkDebug('\x1B[36m$text\x1B[0m');
  }
  
  void checkDebug(String text)
  {
    if(debug) {
      print(text);
    }
  }
}

