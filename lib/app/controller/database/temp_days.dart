// @dart=2.12
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TempDays {
  //Criar instância da interface, ao chamar a interface, use ValueHistory.instance.metodo
  static final TempDays instance = TempDays._init();
  static final String table = "tempDays";
  static Database? _database;

  TempDays._init();

  //Checar se já existe database, se sim, retornar; se não, criar uma nova
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('$table.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Database _db = await openDatabase(join(await getDatabasesPath(),filePath), version: 1);
    print("DROPPING IF EXISTS");
    await _db.execute('DROP TABLE IF EXISTS $table;');
    await _createDB(_db, 2);

    return _db;
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $table(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dia VARCHAR NOT NULL,
      dateepoch INT NOT NULL
    );
    ''');
    String insert = '''
    INSERT INTO $table (dateepoch, dia) values
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
    ''';
    await db.execute(insert);
  }

  Future<List<Map>> recoverThirty()
  async {
    final database = await instance.database;
    return await database.rawQuery('SELECT dateepoch, datetime(dateepoch, \'unixepoch\') as converted FROM $table;');
  }

}