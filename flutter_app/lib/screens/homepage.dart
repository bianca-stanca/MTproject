import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterapp/data_model/sensor_model.dart';
import 'package:flutterapp/globalValue.dart';
import 'package:meta/meta.dart';
import '../utility/category.dart';
import '../utility/timer.dart';
import 'package:esense_flutter/esense.dart';
import 'dart:async';
import 'package:flutterapp/database/db.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  final Category category;

  const Homepage({
    @required this.category,
  }) : assert(category != null);

  @override
  _HomepageState createState() => _HomepageState();

  static _HomepageState of(BuildContext context) =>
      context.findAncestorStateOfType();
}

class _HomepageState extends State<Homepage> {
  String _deviceName = 'Unknown';
  double _voltage = -1;
  Session session = Session();
  List<List<dynamic>> sensorEventList = [];
  String _deviceStatus = '';
  bool sampling = false;
  String _event = '';
  static TimerService _t;

  String _button = 'not pressed';
  List<SensorModel> _sensorData = [];

  ESenseManager manager = new ESenseManager();

//  // the name of the eSense device to connect to -- change this to your own device.
//   String eSenseName = "eSense-0079";
  int _activityId;
  String eSenseName;
//
  @override
  void initState() {
    // clearPreferences();
    if (this.mounted) {
      super.initState();
    }
  }

  isRunning() {
    return _t != null && _t.isRunning;
  }

  Future<void> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<void> _connectToESense() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    eSenseName = "eSense-${prefs.getString(_esenseNameKey)}";

    bool con = false;

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    manager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');
      if (event.type == ConnectionType.connected) _listenToESenseEvents();
      if (this.mounted) {
        setState(() {
          switch (event.type) {
            case ConnectionType.connected:
              _deviceStatus = 'connected';
              break;
            case ConnectionType.unknown:
              _deviceStatus = 'unknown';
              break;
            case ConnectionType.disconnected:
              _deviceStatus = 'disconnected';
              break;
            case ConnectionType.device_found:
              _deviceStatus = 'device_found';
              break;
            case ConnectionType.device_not_found:
              _deviceStatus = 'device_not_found';
              break;
          }
        });
      }
      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) {
        _deviceStatus = "connected";
        Fluttertoast.showToast(
            msg: "Device connected",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });

    con = await manager.connect(eSenseName);
    if (this.mounted)
      setState(() {
        _deviceStatus = con ? 'connecting' : 'connection failed';
      });
  }

  void _disconnectESense() async {
    if (!_t.isRunning) await manager.disconnect();
    if (this.mounted)
      setState(() {
        _deviceStatus = "disconnected";
      });
  }

  void _listenToESenseEvents() async {
    if (_deviceStatus == "connected") {
      manager.eSenseEvents.listen((event) {
        print('ESENSE event: $event');
        if (this.mounted)
          setState(() {
            switch (event.runtimeType) {
              case DeviceNameRead:
                _deviceName = (event as DeviceNameRead).deviceName;
                print(_deviceName);
                break;
              case BatteryRead:
                _voltage = (event as BatteryRead).voltage;
                break;
              case ButtonEventChanged:
                _button = (event as ButtonEventChanged).pressed
                    ? 'pressed'
                    : 'not pressed';
                break;
            }
          });
      });
    }
  }

  StreamSubscription subscription;
  void _startListenToSensorEvents() async {
    // subscribe to sensor event from the eSense device
    manager.setSamplingRate(32);
    subscription = manager.sensorEvents.listen((event) {
      print('SENSOR event: $event');
      int _accX = event.accel[0];
      int _accY = event.accel[1];
      int _accZ = event.accel[2];
      int _gyroX = event.gyro[0];
      int _gyroY = event.gyro[1];
      int _gyroZ = event.gyro[2];
      String _timestamp = event.timestamp.toString();
      int _packetIndex = event.packetIndex;
      SensorModel sensorElem = new SensorModel(
          accX: _accX,
          accY: _accY,
          accZ: _accZ,
          gyroX: _gyroX,
          gyroY: _gyroY,
          gyroZ: _gyroZ,
          timestamp: _timestamp,
          packetId: _packetIndex);
      _sensorData.add(sensorElem);
      sensorEventList.add([
        _timestamp,
        _accX,
        _accY,
        _accZ,
        _gyroX,
        _gyroY,
        _gyroZ,
        _packetIndex
      ]);
      setState(() {
        _event = event.toString();
      });
      print(_sensorData.length);
    });
    setState(() {
      sampling = true;
    });
  }

  void _pauseListenToSensorEvents() async {
    if (subscription != null) {
      subscription.cancel();
    }
    if (this.mounted)
      setState(() {
        sampling = false;
      });
  }

  void dispose() {
    // _disconnectESense();
    super.dispose();
  }

  void onSubmit(bool result) async {
    print(result);
    if (result) {
      Fluttertoast.showToast(
        msg: "Thank you for recording! Device is now disconnected.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
//      _disconnectESense();
    }
  }

  _insertData() async {
    print("Sensor events length: ${_sensorData.length}");
    var db = DBProvider.db;
    db.upload(sensorEventList);
    db.save(_sensorData);
    _resetActivity();
  }

  void _handleActivity() async {
    if (_deviceStatus != "connected") {
      return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text('Device not found!'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Connect a device before starting the activity'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                      child: Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ]);
          });
    } else {
      if (!_t.isRunning) {
        _t.start();
        session.toggle(_t);
        if (manager.connected) {
          if (!sampling) {
            _startListenToSensorEvents();
          }
        }
      } else {
        _t.stop();
        session.toggle(_t);
        _t.reset();
        if (!manager.connected) {
          null;
        } else {
          if (sampling) {
            _pauseListenToSensorEvents();
          }
        }
        _insertData();
      }
    }
  }

  void _resetActivity() {
    _t.reset();
    if (!manager.connected) {
      null;
    } else {
      if (sampling) {
        _pauseListenToSensorEvents();
      }
    }
    _sensorData = [];
  }

  Future<void> _neverSatisfied() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Please stop recording before disconnecting'),
          actions: <Widget>[
            TextButton(
              child: Text('Go Back'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  String _username = "username";
  String _password = "password";
  String _esenseNameKey = "eSense";
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerEarbudsName = TextEditingController();

  _checkLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_username) == null) {
      print("No shared preferences saved");
      final _formKey = GlobalKey<FormState>();
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                  title: Text("Login"),
                  content: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: TextFormField(
                              controller: controllerUsername,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Username (like B01)',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Cannot be empty';
                                } else {
                                  RegExp user = RegExp(r'^B[0-9]+$');
                                  if (!user.hasMatch(value))
                                    return 'Please enter a valid username';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: TextFormField(
                              controller: controllerEarbudsName,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'ESense device number',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Cannot be empty';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: TextFormField(
                              controller: controllerPassword,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Cannot be empty';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        child: Text("Submit"),
                        onPressed: () {
                          // Validate returns true if the form is valid, otherwise false.
                          if (_formKey.currentState.validate()) {
                            final storage = new FlutterSecureStorage();
                            // If the form is valid, display a snackbar. In the real world,
                            // you'd often call a server or save the information in a database.
                            prefs.setString(_username, controllerUsername.text);
                            prefs.setString(
                                _esenseNameKey, controllerEarbudsName.text);
                            storage.write(
                                key: _password, value: controllerPassword.text);
                            print("here dialog");
                            Navigator.pop(context, true);
                          }
                        },
                      ),
                    )
                  ]),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkLoginData();
    if (_t == null) {
      _t = TimerService.of(context);
    }

    return Scaffold(
        body: Center(
            child: AnimatedBuilder(
                animation: _t,
                builder: (context, child) {
                  return SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
                            child: Container(
                                height: 150,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text("Welcome!",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30,
                                              color: Color(0xFF448AFF))),
                                      Text("Please record a session",
                                          softWrap: false,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Color(0xFF448AFF))),
                                    ])),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(
                                '0${_t.currentDuration.toString().split('.')[0]}',
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .apply(fontSizeFactor: 6.0),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Material(
                                    child: Center(
                                      child: Ink(
                                        decoration: ShapeDecoration(
                                          color: Color(0xFF448AFF),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                        ),
                                        child: IconButton(
                                          icon: !_t.isRunning
                                              ? Icon(Icons.play_arrow)
                                              : Icon(Icons.stop),
                                          iconSize: 50.0,
                                          color: Colors.white,
                                          tooltip: 'Start timer',
                                          onPressed: () => _handleActivity(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(!_t.isRunning ? 'Start' : 'End',
                                      style: TextStyle(fontSize: 25))
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                if (_deviceStatus == "connected") {
                                  if (_t.isRunning) {
                                    // _t.stop();
                                    // session.toggle(_t);
                                    // _t.reset();
                                    _neverSatisfied();
                                  } else {
                                    _disconnectESense();
                                  }
                                } else {
                                  _connectToESense();
                                }
                              },
                              label: _deviceStatus != "connected"
                                  ? Text('Connect')
                                  : Text('disconnect'),
                              icon: Icon(Icons.bluetooth_audio),
                              backgroundColor: Colors.pink,
                            ),
                          ),
                        ]),
                  );
                })));
  }
}
