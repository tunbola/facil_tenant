import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  /*static String _dbPath;
  static DatabaseFactory dbFactory = databaseFactoryIo;

  static Future<String> get _fsPath async {
    final basePath = await fs.getTemporaryDirectory();
    return basePath.path;
  }

  static Future<Database> get _db async {
    final String tmpPath = await _fsPath;
    LocalStorage._dbPath = join(tmpPath, "shed_app.db");
    Database db = await dbFactory.openDatabase(LocalStorage._dbPath);
    return db;
  }

  static Future<bool> removeItem(String key) async {
    final db = await _db;
    try {
      await db.delete(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<dynamic> getItem(String key) async {
    final db = await _db;
    final hasKey = await db.containsKey(key);
    if (hasKey) {
      try {
        final val = await db.get(key);
        return val;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  static Future<dynamic> setItem(String key, dynamic value) async {
    final db = await _db;
    try {
      final val = await db.put(value, key);
      return val;
    } catch (e) {
      return false;
    }
  }*/

  static Future<SharedPreferences> _store() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  static Future<dynamic> getItem(String key) async {
    SharedPreferences dbInstance = await _store();
    bool hasKey = dbInstance.containsKey(key);
    if (hasKey) {
      String content = dbInstance.getString(key);
      return content;
    }
    return false;
  }

  static Future<bool> setItem(String key, String data) async {
    SharedPreferences dbInstance = await _store();
    bool state = await dbInstance.setString(key, data);
    return state;
  }

  static Future<bool> removeItem(String key) async {
    SharedPreferences dbInstance = await _store();
    bool state = await dbInstance.remove(key);
    return state;
  }
}
