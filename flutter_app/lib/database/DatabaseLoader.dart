import 'dart:async';
import 'package:flutterapp/database/db.dart';

class DatabaseLoader {
  Future _doneFuture;
  final String typeOfData;

  DatabaseLoader({
    this.typeOfData,
  }) {
    _doneFuture = _download(typeOfData);
  }
//  static final DatabaseLoader dl = DatabaseLoader()._();

  _download(data) async {
    var res = await getData(data);
    return res;
  }

  static getData(data) async {
    try {
      var db = DBProvider.db;
      print(db.database);
      var typeOfData;
      typeOfData = await db.querySensorData();
      return typeOfData;
    } catch (e) {
      print("Error $e");
    }
  }

  Future get initializationDone => _doneFuture;
}
