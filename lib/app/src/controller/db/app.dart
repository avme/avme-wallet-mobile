import 'dart:async';

import 'package:avme_wallet/app/src/model/db/market_data.dart';
import 'package:decimal/decimal.dart';
import 'package:path/path.dart';
// import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite/sqflite.dart';

import '../../helper/print.dart';

class WalletDB {
  static final WalletDB _self = WalletDB._init();
  static Database? _database;

  WalletDB._init();
  
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _init('database.db');
    return _database!;
  }

  factory WalletDB() => _self;

  String get valueHistory => MarketDataFields.table;
  String get temp => "tbTemp";

  Future<Database> _init(String filePath) async {
    String path = join(await databaseFactory.getDatabasesPath(),filePath);
    OpenDatabaseOptions options = OpenDatabaseOptions(onCreate: onCreate, version: 2);
    Database database = await databaseFactory.openDatabase(path, options: options);

    ///Clearing the temp days
    await resetTempData(database);
    return database;
  }

  Future onCreate(Database db, int version) async {
    String marketData = '''
      CREATE TABLE ${MarketDataFields.table}(
        ${MarketDataFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${MarketDataFields.tokenName} VARCHAR NOT NULL,
        ${MarketDataFields.value} VARCHAR(1000) NOT NULL,
        ${MarketDataFields.dateTime} INT NOT NULL
      );
    ''';

    await db.execute(marketData);

    await db.execute('''
    CREATE TABLE tbTemp(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dia VARCHAR NOT NULL,
      dateepoch INT NOT NULL
    );
    ''');
  }

  Future resetTempData(Database db) async {
    await db.execute('DELETE from $temp;');
    await db.execute('''
      INSERT INTO $temp (dateepoch, dia) values
      (cast(strftime('%s', date('now')) as int) + 3600, date('now')),
      (cast(strftime('%s', date('now', '-1 days')) as int), date('now', '-1 days')),
      (cast(strftime('%s', date('now', '-2 days')) as int), date('now', '-2 days')),
      (cast(strftime('%s', date('now', '-3 days')) as int), date('now', '-3 days')),
      (cast(strftime('%s', date('now', '-4 days')) as int), date('now', '-4 days')),
      (cast(strftime('%s', date('now', '-5 days')) as int), date('now', '-5 days')),
      (cast(strftime('%s', date('now', '-6 days')) as int), date('now', '-6 days')),
      (cast(strftime('%s', date('now', '-7 days')) as int), date('now', '-7 days')),
      (cast(strftime('%s', date('now', '-8 days')) as int), date('now', '-8 days')),
      (cast(strftime('%s', date('now', '-9 days')) as int), date('now', '-9 days')),
      (cast(strftime('%s', date('now', '-10 days')) as int), date('now', '-10 days')),
      (cast(strftime('%s', date('now', '-11 days')) as int), date('now', '-11 days')),
      (cast(strftime('%s', date('now', '-12 days')) as int), date('now', '-12 days')),
      (cast(strftime('%s', date('now', '-13 days')) as int), date('now', '-13 days')),
      (cast(strftime('%s', date('now', '-14 days')) as int), date('now', '-14 days')),
      (cast(strftime('%s', date('now', '-15 days')) as int), date('now', '-15 days')),
      (cast(strftime('%s', date('now', '-16 days')) as int), date('now', '-16 days')),
      (cast(strftime('%s', date('now', '-17 days')) as int), date('now', '-17 days')),
      (cast(strftime('%s', date('now', '-18 days')) as int), date('now', '-18 days')),
      (cast(strftime('%s', date('now', '-19 days')) as int), date('now', '-19 days')),
      (cast(strftime('%s', date('now', '-20 days')) as int), date('now', '-20 days')),
      (cast(strftime('%s', date('now', '-21 days')) as int), date('now', '-21 days')),
      (cast(strftime('%s', date('now', '-22 days')) as int), date('now', '-22 days')),
      (cast(strftime('%s', date('now', '-23 days')) as int), date('now', '-23 days')),
      (cast(strftime('%s', date('now', '-24 days')) as int), date('now', '-24 days')),
      (cast(strftime('%s', date('now', '-25 days')) as int), date('now', '-25 days')),
      (cast(strftime('%s', date('now', '-26 days')) as int), date('now', '-26 days')),
      (cast(strftime('%s', date('now', '-27 days')) as int), date('now', '-27 days')),
      (cast(strftime('%s', date('now', '-28 days')) as int), date('now', '-28 days')),
      (cast(strftime('%s', date('now', '-29 days')) as int), date('now', '-29 days')),
      (cast(strftime('%s', date('now', '-30 days')) as int), date('now', '-30 days'));
    ''');
  }

  static Future<MarketData> insert(MarketData values) async {
    final database = await _self.database;
    List<Map>? check = await database.query(
        MarketDataFields.table,
        where: "(${MarketDataFields.tokenName} = ?) and (${MarketDataFields.dateTime} = ?)",
        whereArgs: [values.tokenName,values.dateTime]
    );
    if (check.isNotEmpty){
      return values.copy();
    } else {
      values = values.copy(tokenName: values.tokenName.toUpperCase());
      final id = await database.insert(MarketDataFields.table, values.toMap());
      return values.copy(id: id);
    }
  }

  static Future<List<int>> getMissingDays(String tokenName) async
  {
    List<int> _filterDays = [];
    List<Map> queryResult = await selectAllTemp();
    queryResult.forEach((Map row) => _filterDays.add(row['dateepoch']));
    final database = await _self.database;
    List<Map> days = await database.query(
      MarketDataFields.table,
      columns: [MarketDataFields.dateTime],
      where: '${MarketDataFields.tokenName} = ? and (${MarketDataFields.dateTime} between ? and ?)',
      whereArgs: [
        tokenName.toUpperCase(),
        _filterDays.last.toString(),
        _filterDays.first.toString()
      ]
    );
    List<int> savedDays = [];
    if(days.isNotEmpty){
      days.forEach((Map row) => savedDays.add(row[MarketDataFields.dateTime]));
      _filterDays.removeWhere((date) => savedDays.contains(date));
    }
    else
    {
      print('Error at getMissingDates ->  No data found querying $tokenName in table \"${MarketDataFields.table}\"');
    }
    Print.warning("[Missing days for $tokenName] $_filterDays");
    // return _filterDays;
    return [];
  }
  
  Future<MarketData> read(int date) async {
    final database = await _self.database;
    final maps = await database.query(
      MarketDataFields.table,
      columns: MarketDataFields.values,
      where: '${MarketDataFields.dateTime} = ?',
      //where: '${TokenValueFields.id} = $id', not secure, doesn't prevent sql injection attacks
      whereArgs: [date], //se for adicionar mais args de leitura, adicione mais ? acima
    );

    if (maps.isNotEmpty) {
      return MarketData.fromMap(maps.first);
    } else {
      throw Exception('Date $date not found');
    }
  }
  
  Future<List<MarketData>> readAmount(String tokenName, int limit) async {
    final database = await _self.database;
    final result = await database.query(
      MarketDataFields.table,
      columns: MarketDataFields.values,
      limit: limit,
      orderBy: '${MarketDataFields.dateTime} DESC',
      where: '${MarketDataFields.tokenName} = ?',
      whereArgs: [tokenName]
    );
    return result.map((map) => MarketData.fromMap(map)).toList();
  }

  Future close() async{
    final database = await _self.database;
    database.close();
  }

  static Future<List<int>> getMissingHours(String tokenName) async
  {
    List<int> todayUnixHours = [];
    Map queryResult = await selectLatestTemp();

    int startUnix = queryResult["dateepoch"];
    DateTime _now = DateTime.now();
    DateTime dateTimeNow = DateTime(_now.year, _now.month, _now.day, _now.hour);
    int nowUnix = int.parse(dateTimeNow.millisecondsSinceEpoch.toString().substring(0, 10));

    for(int i = startUnix; i < nowUnix; i += 3600)
    { todayUnixHours.add(i); }

    final database = await _self.database;
    List<Map> rows = await database.query(
        MarketDataFields.table,
        columns: [MarketDataFields.dateTime],
        where: '${MarketDataFields.tokenName} = ? and (${MarketDataFields.dateTime} between ? and ?)',
        whereArgs: [
          tokenName.toUpperCase(),
          startUnix.toString(),
          todayUnixHours.last.toString()
        ]
    );

    for(Map row in rows)
    {
      todayUnixHours.remove(row.values.first);
    }

    // Print.error("$todayUnixHours");
    return todayUnixHours;
  }

  static Future<List<Map>> selectAllTemp() async
  {
    final database = await _self.database;
    return await database.rawQuery('SELECT dateepoch, datetime(dateepoch, \'unixepoch\') as converted FROM ${_self.temp};');
  }

  static Future<Map> selectLatestTemp() async
  {
    final database = await _self.database;
    List<Map> result = await database.rawQuery('''
      SELECT 
        dateepoch,
        datetime(dateepoch, \'unixepoch\') as converted
        FROM ${_self.temp} order by dateepoch desc limit 1;
      ''');
    return result.first;
  }

  static Future<List<MarketData>> viewMarketDataMonth(String token, {int limit = 30, int offset = 0}) async
  {
    List<MarketData> ret = [];
    final database = await _self.database;
    List<Map> result = await database.rawQuery(
      '''
        SELECT
          md.*,
          (SELECT td.dateepoch FROM ${_self.temp} td WHERE date(md.dateTime, 'unixepoch') = date(td.dateepoch, 'unixepoch')) AS 'approximate'
          FROM ${_self.valueHistory} md
        WHERE (SELECT td.dateepoch FROM ${_self.temp} td WHERE date(md.dateTime, 'unixepoch') = date(td.dateepoch, 'unixepoch'))
          AND md.tokenName = '$token'
        GROUP BY approximate
        ORDER BY md.dateTime desc
        LIMIT $limit
        OFFSET $offset;
      '''
    );

    for(Map row in result)
    {
      ret.add(
        MarketData(
          id: row["id"],
          tokenName: row["tokenName"],
          value: Decimal.parse(row["value"]),
          dateTime: row["dateTime"],
        )
      );
    }

    return ret;
  }
}