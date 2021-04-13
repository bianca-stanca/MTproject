import 'package:acrob/utility/timer.dart';

class Session {
  static final Session _instance = Session._internal();

  var _isRunning;
  // passes the instantiation to the _instance object
  factory Session() => _instance;
  bool get isRunning => _isRunning;

  void toggle(TimerService t) => _isRunning = t.isRunning;

  Session._internal() {
    _isRunning = false;
  }
}
