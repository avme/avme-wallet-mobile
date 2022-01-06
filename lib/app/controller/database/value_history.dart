// @dart=2.12
import 'dart:async';
import 'package:avme_wallet/app/controller/database/temp_days.dart';
import 'package:avme_wallet/app/model/value_history.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ValueHistoryTable {
  //TODO: deletar comentários desnecessários
  //Criar instância da interface, ao chamar a interface, use ValueHistory.instance.metodo
  static final ValueHistoryTable instance = ValueHistoryTable._init();
  static Database? _database;

  ValueHistoryTable._init();

  //Checar se já existe database, se sim, retornar; se não, criar uma nova
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('tokenValue.db');

    return _database!;
  }

  get table => ValueHistoryFields.table;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath,filePath);
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
    final valueType = 'VARCHAR(1000) NOT NULL';
    final dateType = 'INT NOT NULL';
    //arrumar isso para datetime
    String createTbQuery = '''
    CREATE TABLE ${ValueHistoryFields.table}(
    ${ValueHistoryFields.id} $idType,
    ${ValueHistoryFields.tokenName} $varcharType,
    ${ValueHistoryFields.value} $valueType,
    ${ValueHistoryFields.dateTime} $dateType
    )
    ''';
    print(createTbQuery);
    await db.execute(createTbQuery);
  }

  ///Cria/adiciona uma nova entrada na database
  ///tokenName sempre será UpperCase, e caso ter uma entrada createdTime
  ///duplicada, não será adicionado
  Future<TokenHistory> insert(TokenHistory values) async {
    final database = await instance.database;
    List<Map>? check = await database.query(
      ValueHistoryFields.table,
      where: "(${ValueHistoryFields.tokenName} = ?) and (${ValueHistoryFields.dateTime} = ?)",
      whereArgs: [values.tokenName,values.dateTime]
    );
    if (check.isNotEmpty){
      print('Já existe na tabela');
      return values.copy();
      //throw Exception('Data já existente na tabela');
    } else {
      values = values.copy(tokenName: values.tokenName.toUpperCase());
      final id = await database.insert(ValueHistoryFields.table, values.toMap());
      return values.copy(id: id);
    }
    //Returning a copy of the tokenValue, since ID wasn't set in the parameters,
    //but once added on the ValueHistoryFields.table, it will have a new unique ID; so just create
    //a new one and return it.  Could be considered waste of memory/performance
    //for having to create one new list only to compare to, could be improved
  }

  // Future<TokenHistory> selectEncorpado() async

  Future<List<int>> getMissingDays(String tokenName) async
  {
    List<int> _filterDays = [];
    TempDays tempDays = TempDays.instance;
    List<Map> queryResult = await tempDays.recoverThirty();
    queryResult.forEach((Map row) => _filterDays.add(row['dateepoch']));
    final database = await instance.database;
    List<Map> days = await database.query(
      ValueHistoryFields.table,
      columns: [ValueHistoryFields.dateTime],
      where: '${ValueHistoryFields.tokenName} = ? and (${ValueHistoryFields.dateTime} between ? and ?)',
      whereArgs: [
        tokenName,
        _filterDays.last.toString(),
        _filterDays.first.toString()
      ]
    );
    List<int> savedDays = [];
    if(days.isNotEmpty){
      days.forEach((Map row) => savedDays.add(row[ValueHistoryFields.dateTime]));
      _filterDays.removeWhere((date) => savedDays.contains(date));
    }
    else
    {
      print('[Warning -> getMissingDays] no data found for ${ValueHistoryFields.table}');
    }
    return _filterDays;
  }

  Future<TokenHistory> read(int date) async {
    //TODO:modificar baseado em o que o usuário quer ler com outras entradas fora data
    final database = await instance.database;
    final maps = await database.query(
      ValueHistoryFields.table,
      columns: ValueHistoryFields.values,
      where: '${ValueHistoryFields.dateTime} = ?',
      //where: '${TokenValueFields.id} = $id', not secure, doesn't prevent sql injection attacks
      whereArgs: [date], //se for adicionar mais args de leitura, adicione mais ? acima
    );

    if (maps.isNotEmpty) {
      return TokenHistory.fromMap(maps.first);
    } else {
      throw Exception('Date $date not found');
    }
  }

  Future<List<TokenHistory>> readLastFour(String tokenName) async {
    final database = await instance.database;
    final result = await database.query(
        ValueHistoryFields.table,
        columns: ValueHistoryFields.values,
        limit: 4,
        orderBy: '${ValueHistoryFields.id} ASC',
        where: '${ValueHistoryFields.tokenName} = ?',
        whereArgs: [tokenName]
    );
    return result.map((map) => TokenHistory.fromMap(map)).toList();
  }

  ///Retorna uma lista de TokenValues com todas as linhas da database (30)
  Future<List<TokenHistory>> readAll() async {
    final database = await instance.database;
    final result = await database.query(ValueHistoryFields.table, orderBy: '${ValueHistoryFields.dateTime} DESC');
    return result.map((map) => TokenHistory.fromMap(map)).toList();
  }

  ///Deleta na data epoch passada como argumento
  Future<int> delete(int date) async{
    final database = await instance.database;

    return await database.delete(
      ValueHistoryFields.table,
      where: '${ValueHistoryFields.dateTime} = ?',
      whereArgs: [date],
    );
  }

  ///Deletar todas as linhas da tabela
  Future<int> deleteAll() async{
    final database = await instance.database;

    return await database.delete(
      ValueHistoryFields.table,
      where: null
    );
  }

  Future close() async{
    //Acessar o database e deletar em baixo
    final database = await instance.database;

    database.close();
  }
}