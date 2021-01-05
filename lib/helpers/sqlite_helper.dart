// This file declares functions that manages the database that is created in the app
// when the app is installed for the first time

import "package:sqflite/sqflite.dart";
import "dart:async";
import "dart:io";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "package:kamusi/models/generic_model.dart";
import "package:kamusi/models/neno_model.dart";
import "package:kamusi/utils/constants.dart";

class SqliteHelper {
  static SqliteHelper sqliteHelper; // Singleton DatabaseHelper
  static Database appDb; // Singleton Database

  SqliteHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory SqliteHelper() {
    if (sqliteHelper == null) {
      sqliteHelper = SqliteHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return sqliteHelper;
  }

  Future<Database> get database async {
    if (appDb == null) {
      appDb = await initializeDatabase();
    }
    return appDb;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory docsDirectory = await getApplicationDocumentsDirectory();
    String path = join(docsDirectory.path, "Kamusi.db");

    // Open/create the database at a given path
    var vsbDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return vsbDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(Queries.createManenoTable);
    await db.execute(Queries.createMethaliTable);
    await db.execute(Queries.createMisemoTable);
    await db.execute(Queries.createNahauTable);
  }

  //QUERIES FOR NENO
  Future<int> insertNeno(NenoModel item) async {
    Database db = await this.database;
    item.isfav = item.views = 0;

    var result = await db.insert(LangStrings.maneno, item.toMap());
    return result;
  }

  //QUERIES FOR NENO
  Future<int> insertGeneric(String table, GenericModel generic) async {
    Database db = await this.database;
    generic.isfav = generic.views = 0;

    var result = await db.insert(table, generic.toMap());
    return result;
  }

  Future<int> favouriteNeno(NenoModel item, bool isFavorited) async {
    var db = await this.database;
    if (isFavorited) item.isfav = 1;
    else item.isfav = 0;
    var result = await db.rawUpdate('UPDATE ' + LangStrings.maneno + ' SET ' + LangStrings.isfav + '=' + item.isfav.toString() + 
      ' WHERE ' + LangStrings.id + '=' + item.id.toString());

    return result;
  }

  Future<int> deleteNeno(int itemID) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM ' + LangStrings.maneno + ' WHERE ' + LangStrings.id + '=' + itemID.toString());
    return result;
  }

  Future<int> getNenoCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from ' + LangStrings.maneno);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //GENERIC LISTS
  Future<List<Map<String, dynamic>>> getGenericMapList(String table) async {
    Database db = await this.database;
    var result = db.query(table);
    return result;
  }

  Future<List<GenericModel>> getGenericList(String table) async {
    var genericMapList = await getGenericMapList(table);
    List<GenericModel> genericList = List<GenericModel>();
    for (int i = 0; i < genericMapList.length; i++) {
      genericList.add(GenericModel.fromMapObject(genericMapList[i]));
    }
    return genericList;
  }

  //GENERIC SEARCH
  Future<List<Map<String, dynamic>>> getGenericSearchMapLists(String searchString, String table) async {
    Database db = await this.database;
    String sqlQuery = LangStrings.title + ' LIKE "$searchString%"';

    var result = db.query(table, where: sqlQuery);
    return result;
  }

  Future<List<Map<String, dynamic>>> getGenericSearchMapList(String searchString, String table, bool searchByTitle) async {
    Database db = await this.database;
    String sqlQuery = LangStrings.title + ' LIKE "$searchString%"';

    if (!searchByTitle)
      sqlQuery = sqlQuery + ' OR ' + LangStrings.maana + ' LIKE "$searchString%"';

    var result = db.query(table, where: sqlQuery);
    return result;
  }

  Future<List<GenericModel>> getGenericSearch(String searchString, String table, bool searchByTitle) async {
    var itemMapList = await getGenericSearchMapList(searchString, table, searchByTitle);

    List<GenericModel> itemList = List<GenericModel>();
    // For loop to create a "item List" from a "Map List"
    for (int i = 0; i < itemMapList.length; i++) {
      itemList.add(GenericModel.fromMapObject(itemMapList[i]));
    }
    return itemList;
  }

  //NENO LISTS
  Future<List<Map<String, dynamic>>> getNenoMapList() async {
    Database db = await this.database;
    var result = db.query(LangStrings.maneno);
    return result;
  }

  Future<List<NenoModel>> getNenoList() async {
    var itemMapList = await getNenoMapList();
    List<NenoModel> itemList = List<NenoModel>();
    for (int i = 0; i < itemMapList.length; i++) {
      itemList.add(NenoModel.fromMapObject(itemMapList[i]));
    }
    return itemList;
  }

  //NENO SEARCH
  Future<List<Map<String, dynamic>>> getNenoSearchMapList(String searchString, bool searchByTitle) async {
    Database db = await this.database;
    String sqlQuery = LangStrings.title + ' LIKE "$searchString%"';

    if (!searchByTitle)
      sqlQuery = sqlQuery + ' OR ' + LangStrings.maana + ' LIKE "$searchString%"';

    var result = db.query(LangStrings.maneno, where: sqlQuery);
    return result;
  }

  Future<List<NenoModel>> getNenoSearch(String searchString, bool searchByTitle) async {
    var itemMapList = await getNenoSearchMapList(searchString, searchByTitle);

    List<NenoModel> itemList = List<NenoModel>();
    // For loop to create a "item List" from a "Map List"
    for (int i = 0; i < itemMapList.length; i++) {
      itemList.add(NenoModel.fromMapObject(itemMapList[i]));
    }
    return itemList;
  }

  //FAVOURITES LISTS
  Future<List<Map<String, dynamic>>> getFavoritesList() async {
    Database db = await this.database;
    var result = db.query(LangStrings.maneno, where: LangStrings.isfav + '=1');
    return result;
  }

  Future<List<NenoModel>> getFavorites() async {
    var itemMapList = await getFavoritesList();

    List<NenoModel> itemList = List<NenoModel>();
    for (int i = 0; i < itemMapList.length; i++) {
      itemList.add(NenoModel.fromMapObject(itemMapList[i]));
    }

    return itemList;
  }

  //FAVORITE SEARCH
  Future<List<Map<String, dynamic>>> getFavSearchMapList(
      String searchString) async {
    Database db = await this.database;
    String extraQuery = "AND ' + LangStrings.isfav + '=1 ";
    String sqlQuery = LangStrings.title + ' LIKE "$searchString%" $extraQuery OR ' +
        LangStrings.maana + ' LIKE "$searchString%" $extraQuery"';

    var result = db.query(LangStrings.maneno, where: sqlQuery);
    return result;
  }

  Future<List<NenoModel>> getFavSearch(String searchString) async {
    var itemMapList = await getFavSearchMapList(searchString);

    List<NenoModel> itemList = List<NenoModel>();
    // For loop to create a "item List" from a "Map List"
    for (int i = 0; i < itemMapList.length; i++) {
      itemList.add(NenoModel.fromMapObject(itemMapList[i]));
    }
    return itemList;
  }
}
