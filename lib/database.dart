import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class GardenDB {
  static final _databaseName = "garden.db";
  GardenDB._privateConstructor();
  static final GardenDB instance = GardenDB._privateConstructor();
  var databaseFactory = databaseFactoryFfi;

  initialDb() async {
    sqfliteFfiInit();
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await databaseFactory.openDatabase(
         path, options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version){
            db.execute('''CREATE TABLE IF NOT EXISTS plants(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT NOT NULL, date TEXT NOT NULL)''');
          })
        );
  }

  onUpgrade(Database? db, int oldVersion, int newVersion) async {
    return;
  }

  readData(String sql) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
     String path = join(documentsDirectory.path, _databaseName);
     var db = await databaseFactory.openDatabase(path);
    List<Map<String, Object?>> response = await db.rawQuery(sql);
    return response;
  }

  insertData(String sql) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
     String path = join(documentsDirectory.path, _databaseName);
     var db = await databaseFactory.openDatabase(path);
    int response = await db.rawInsert(sql);
    return response;
  }

  updateData(String sql) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
     String path = join(documentsDirectory.path, _databaseName);
     var db = await databaseFactory.openDatabase(path);
    int response = await db.rawUpdate(sql);
    return response;
  }

  deleteData(String sql) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
     String path = join(documentsDirectory.path, _databaseName);
     var db = await databaseFactory.openDatabase(path);
    int response = await db.rawDelete(sql);
    return response;
  }

  static deleteDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
     String path = join(documentsDirectory.path, _databaseName);
    await deleteDatabase(path);
  }
}