// @dart=2.12
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:avme_wallet/app/model/token_data.dart';

class DatabaseInterface {
  //Criar instância da interface, ao chamar a interface, use DatabaseInterface.instance.metodo
  static final DatabaseInterface instance = DatabaseInterface._init();

  static Database? _database;

  DatabaseInterface._init();

  //Checar se já existe database, se sim, retornar; se não, criar uma nova
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('tokenValue.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);
    //Path deve ser data/data/com.avme.avme_wallet/databases

    /*
    getDatabasesPath().then((dbPath) => {
      join(dbPath,filePath)
    });
    */

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final varcharType = 'VARCHAR NOT NULL';
    final valueType = 'FLOAT(14) NOT NULL';
    final dateType = 'INT NOT NULL';
    //arrumar isso para datetime

    await db.execute('''
    CREATE TABLE $tokenValueTable(
    ${TokenValueFields.id} $idType,
    ${TokenValueFields.tokenName} $varcharType,
    ${TokenValueFields.value} $valueType,
    ${TokenValueFields.dateTime} $dateType
    )
    ''');
  }

  ///Cria/adiciona uma nova entrada na database
  ///tokenName sempre será UpperCase, e caso ter uma entrada createdTime
  ///duplicada, não será adicionado
  Future<TokenValue> create(TokenValue values) async {
    final database = await instance.database;
    List<Map>? check = await database.query(tokenValueTable, where: '${TokenValueFields.dateTime} = ${values.dateTime}');
    if (check.isNotEmpty) {
      print('Já existe na tabela');
      return values.copy();
      //throw Exception('Data já existente na tabela');
    } else {
      values = values.copy(tokenName: values.tokenName.toUpperCase());
      final id = await database.insert(tokenValueTable, values.toMap());
      return values.copy(id: id);
    }
    //Returning a copy of the tokenValue, since ID wasn't set in the parameters,
    //but once added on the table, it will have a new unique ID; so just create
    //a new one and return it.  Could be considered waste of memory/performance
    //for having to create one new list only to compare to, could be improved
  }

  Future<TokenValue> read(int date) async {
    final database = await instance.database;
    final maps = await database.query(
      tokenValueTable,
      columns: TokenValueFields.values,
      where: '${TokenValueFields.dateTime} = ?',
      //where: '${TokenValueFields.id} = $id', not secure, doesn't prevent sql injection attacks
      whereArgs: [date], //se for adicionar mais args de leitura, adicione mais ? acima
    );

    if (maps.isNotEmpty) {
      return TokenValue.fromMap(maps.first);
    } else {
      throw Exception('Date $date not found');
    }
  }

  ///Retorna uma lista de TokenValues com todas as linhas da database (30)
  Future<List<TokenValue>> readAll() async {
    final database = await instance.database;
    final result = await database.query(tokenValueTable, orderBy: '${TokenValueFields.dateTime} DESC');
    return result.map((map) => TokenValue.fromMap(map)).toList();
  }

  ///Deleta na data epoch passada como argumento
  Future<int> delete(int date) async {
    final database = await instance.database;

    return await database.delete(
      tokenValueTable,
      where: '${TokenValueFields.dateTime} = ?',
      whereArgs: [date],
    );
  }

  ///Deletar todas as linhas da tabela
  Future<int> deleteAll() async {
    final database = await instance.database;

    return await database.delete(tokenValueTable, where: null);
  }

  Future close() async {
    //Acessar o database e deletar em baixo
    final database = await instance.database;

    database.close();
  }
}
