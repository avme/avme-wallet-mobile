// @dart=2.12
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TableNFT {
  static final TableNFT instance = TableNFT._init();
  static final String table = "tableNFT";
  static Database? _database;

  TableNFT._init();

  //Checar se já existe database, se sim, retornar; se não, criar uma nova
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('$table.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    return await openDatabase(join(await getDatabasesPath(),filePath),onCreate: _createDB , version: 1);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        address VARCHAR NOT NULL,
        symbol VARCHAR NOT NULL,
        name VARCHAR NOT NULL,
        logo VARCHAR NOT NULL
      );
    ''');
  }

  Future<String> exists(String token) async
  {
    final database = await instance.database;
    List<Map> query = await database.rawQuery('''
      select
        address
      from $table where address = '$token';
    ''');
    print("query $query");
    if(query.length > 0)
      return query[0]['address'];
    return '';
  }

  Future<bool> addNFT(Map nftData) async
  {
    final database = await instance.database;
    String query = '''
      insert into $table (address, symbol, name, logo)
        values (
          '${nftData['address']}',
          '${nftData['symbol']}',
          '${nftData['name']}',
          '${nftData['logo']}'
        );
    ''';
    try
    {
      await database.execute(query);
    }
    catch (e) {
      return false;
    }
    return true;
  }

  Future<List<Map>> savedContracts() async
  {
    final database = await instance.database;
    return await database.rawQuery('''
      select * from $table;
    ''');
  }

  Future<bool> deleteAll() async
  {
    final database = await instance.database;
    database.execute('''
      delete from $table;
    ''');
    return false;
  }
}