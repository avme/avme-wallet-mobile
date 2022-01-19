// @dart=2.12
import 'dart:async';

import 'package:avme_wallet/app/model/recently_sent.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class RecentlySentTable {
  //Criar instância da interface, ao chamar a interface, use ValueHistory.instance.metodo
  static final RecentlySentTable instance = RecentlySentTable._init();
  static Database? _database;

  RecentlySentTable._init();

  //Checar se já existe database, se sim, retornar; se não, criar uma nova
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('recenty_sent.db');

    return _database!;
  }

  get table => RecentlySentFields.table;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath,filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const varcharNameType = 'VARCHAR NOT NULL';
    const varcharAddressType = 'VARCHAR(42) NOT NULL';
    String createTbQuery = '''
    CREATE TABLE ${RecentlySentFields.table}(
    ${RecentlySentFields.id} $idType,
    ${RecentlySentFields.name} $varcharNameType,
    ${RecentlySentFields.contactId} $varcharAddressType
    )
    ''';
    print(createTbQuery);
    await db.execute(createTbQuery);

    String insert = '''
    INSERT INTO ${RecentlySentFields.table} (${RecentlySentFields.name}, ${RecentlySentFields.contactId}) values
      ('User One','0x4214496147525148769976fb554a8388117e25b1'),
      ('User Two','0x4214496147525148769976fb554a8388117e25b2'),
      ('User Three','0x4214496147525148769976fb554a8388117e25b3');
    ''';
    await db.execute(insert);
  }

  /// Insere Contato na database.
  /// Se já existe, deleta a mesma entrada e adiciona novamente para atualizar o id do contato
  ///
  /// Se não existe e tiver três entradas,
  /// deleta o menor id (que é o menos utilizado) e adiciona o novo contato
  ///
  /// Se não existe e tiver menos de três entradas,
  /// adiciona o novo contato
  Future<RecentlySent> insert(RecentlySent values) async {

    final database = await instance.database;
    final result = await database.query(RecentlySentFields.table, orderBy: '${RecentlySentFields.id} DESC');
    bool isInTable = false;
    result.forEach((element) {
      if(element['contactId']==values.contactId)
      {
        isInTable = true;
      }
    });

    if (isInTable){
      //Se ja for existente na tabela, deletar a entrada e adicionar a entrada novamente
      print('Já existe na tabela');

      delete(values.contactId).then((value) async {
        if(value!=0)
        {
          print('Delete address ${values.contactId} successfull');
          values = values.copy(name: values.name, contactId: values.contactId);
          final id = await database.insert(RecentlySentFields.table, values.toMap());
          values = values.copy(id: id);
        } else {
          print('Error deleting address ${values.contactId}');
          values = values.copy();
        }
      });
      return values;
    } else {
      //Se não for existente e tiver três, delete o ultimo contato qualquer e adicione o novo
      print('Não existe na tabela');
      if(result.length==3) await deleteLast();
      values = values.copy(name: values.name, contactId: values.contactId);
      print('values $values');
      final id = await database.insert(RecentlySentFields.table, values.toMap());
      return values.copy(id: id);
    }
  }

  Future<List<RecentlySent>> readAll() async {
    final database = await instance.database;
    final result = await database.query(RecentlySentFields.table, orderBy: '${RecentlySentFields.id} DESC');
    return result.map((map) => RecentlySent.fromMap(map)).toList();
  }

  ///Deleta o address
  Future<int> delete(String address) async{
    final database = await instance.database;

    final query = await database.delete(
      RecentlySentFields.table,
      where: '${RecentlySentFields.contactId} = ?',
      whereArgs: [address],
    );

    if(query==0)
    {
      print('An error occurred deleting address $address');
      return query;
    } else {
      print('Address $address successfully deleted');
      return query;
    }
  }

  ///Deletar o ultimo id
  Future<String> deleteLast() async {
    final database = await instance.database;
    final queryResult = await database.query(RecentlySentFields.table,orderBy: '${RecentlySentFields.id} ASC',limit: 1);
    if(queryResult.isNotEmpty)
    {
      final filtered = queryResult.map((map) => RecentlySent.fromMap(map)).toList()[0].contactId;
      final query =  await database.rawDelete(
          'DELETE FROM ${RecentlySentFields.table} WHERE ${RecentlySentFields.contactId} = \'$filtered\''
      );
      if(query==0)
      {
        return 'An error occurred deleting last address';
      } else {
        return 'Last address successfully deleted';
      }
    } else {
      return 'recently_sent table empty';
    }
  }

  Future close() async{
    //Acessar o database e deletar em baixo
    final database = await instance.database;

    database.close();
  }
}