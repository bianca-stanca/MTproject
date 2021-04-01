import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutterapp/data_model/sensor_model.dart';
import 'package:tflite/tflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DBProvider {
  String _username = "username";
  String _password = "password";

  DBProvider._();
  static final DBProvider db = DBProvider._();

  Database _database;
  Transaction txn;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();

    return _database;
  }

  static initDB() async {
    var databasesPath = await getApplicationDocumentsDirectory();
    String path = join(databasesPath.path, 'my_database.db');

    // await deleteDatabase(path);
    try {
//      await Sqflite.devSetDebugModeOn(true);
      final database = openDatabase(
        // Set the path to the database. Note: Using the `join` function from the
        // `path` package is best practice to ensure the path is correctly
        // constructed for each platform.
        path,
        onCreate: (db, version) async {
          await db.execute(
              "CREATE TABLE SENSORDATA(acc_x INTEGER, acc_y INTEGER, acc_z INTEGER, "
              "gyro_x INTEGER, gyro_y INTEGER, gyro_z INTEGER, packetId INTEGER, timestamp STRING)");
        },
        // Set the version. This executes the onCreate function and provides a
        // path to perform database upgrades and downgrades.
        version: 1,
      );
      return database;
    } finally {}
  }

  querySensorData() async {
    final db = await database;
    var res = await db.query("SENSORDATA");
    return res;
  }

  addSensorEvent(SensorModel model) async {
    final db = await database;
    await db.transaction((txn) async {
      var batch = txn.batch();
      batch.rawInsert(
          'INSERT INTO SENSORDATA(acc_x, acc_y, acc_z, '
          'gyro_x, gyro_y, gyro_z, timestamp, packetId) VALUES(?, ?, ?, ?, ?, ?, ?, ?)',
          [
            model.accX,
            model.accY,
            model.accZ,
            model.gyroX,
            model.gyroY,
            model.gyroZ,
            model.timestamp,
            model.packetId,
          ]);
      await batch.commit(noResult: true);
    });
  }

  addAllSensorElements(List<SensorModel> elems) {
    for (var i = 0; i < elems.length; i++) {
      addSensorEvent(elems[i]);
    }
  }

  Future<List<SensorModel>> getSensorData() async {
    // Get a reference to the database.
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('SENSORDATA');
    return List.generate(maps.length, (i) {
      return SensorModel(
        accX: maps[i]['acc_x'],
        accY: maps[i]['acc_y'],
        accZ: maps[i]['acc_z'],
        gyroX: maps[i]['gyro_x'],
        gyroY: maps[i]['gyro_y'],
        gyroZ: maps[i]['gyro_z'],
        timestamp: maps[i]['timestamp'],
        packetId: maps[i]['packetId'],
      );
    });
  }

  Future close() async {
    _database = null;
    db.close();
  }

  Future<void> _uploadData(url, path, filename) async {
    String uri = url + filename;
    print(path);

    print('SwitchDrive start $filename');
    final storage = new FlutterSecureStorage();
    final token = 'SqDlnbOL3DjuNSG';
    final password = await storage.read(key: _password);
    final credentials = '$token:$password';
    final utf8ToBase64 = utf8.fuse(base64);
    final encodedCredentials = utf8ToBase64.encode(credentials);
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
    };

    var req = http.MultipartRequest('PUT', Uri.parse(uri));
    req.headers.addAll(headers);

    req.files.add(http.MultipartFile.fromBytes(
        'txt', File(path).readAsBytesSync(),
        contentType: MediaType('txt', 'csv'), filename: filename));
    // req.files.add(http.MultipartFile.fromString(
    //     'txt', File(path).readAsStringSync(),
    //     contentType: MediaType('txt', 'csv'), filename: filename));

    try {
      var res = await req.send();
      print(res.reasonPhrase);
      print(res.statusCode);
      print('SwitchDrive end $filename');
      return res.reasonPhrase;
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  Future<void> _saveCSV(filename, data) async {
    // List<SensorModel> sensorData =
    //     await this.getSensorData(); // Take the action table
    String csv = _convertToCSV(data);

    File fileUser = File(filename);
    fileUser.writeAsStringSync(csv);
    print("File created: ${fileUser.existsSync()}");
  }

  String _convertToCSV(List<SensorModel> sensorData) {
    List<List<dynamic>> rows = [];
    rows.add(
        ["Timestamp", "Acc_X", "Acc_Y", "Acc_Z", "Gyro_X", "Gyro_Y", "Gyro_Z"]);
    for (int i = 0; i < sensorData.length; i++) {
      List<dynamic> row = [];
      row.add(sensorData[i].timestamp);
      row.add(sensorData[i].accX);
      row.add(sensorData[i].accY);
      row.add(sensorData[i].accZ);
      row.add(sensorData[i].gyroX);
      row.add(sensorData[i].gyroY);
      row.add(sensorData[i].gyroZ);
      rows.add(row);
    }
    return ListToCsvConverter().convert(rows);
  }

  void models() async {
    String res = await Tflite.loadModel(model: "assets/models/head.tflite");
  }

  Future<void> save(data) async {
    models();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Directory documentsDirectory =
        await getApplicationDocumentsDirectory(); // Get right path to save the new format
    Directory('${documentsDirectory.path}/experiment/').createSync();
    String dirPath =
        '${documentsDirectory.path}/experiment/'; // Save the directory of where to save the new format
    // Take the username from the list of all the elements
    String username = prefs.getString(_username);

    //Compute filename
    String time = DateTime.now().toString().substring(0, 16);
    final String fileName = "${username}_Sensor_Data_${time}.csv";
    final String pathUser = dirPath + fileName;

    //save csv
    await _saveCSV(pathUser, data);

    //upload to switchdrive
    var url = 'https://drive.switch.ch/public.php/webdav/';
    _uploadData(url, pathUser, fileName);
  }
}
