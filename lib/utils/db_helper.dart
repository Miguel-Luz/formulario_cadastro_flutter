import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const VERSAO = 1;
  Database _db;

  // singleton
  static DBHelper _instance = DBHelper._internal();
  DBHelper._internal();
  factory DBHelper() => _instance;

  Future<Database> getDatabase() async {
    if (_db == null) {
      var _path = join(await getDatabasesPath(), 'database.db');
      _db = await openDatabase(
        _path,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        version: VERSAO,
      );
    }
    return _db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      create table usuario (
        id integer primary key autoincrement,
        nome text not null,
        email text not null, 
        cpf text not null
      );
    ''');

    await db.execute('''
      create table usuario_endereco (
        id integer primary key autoincrement,
        idusuario integer not null,
        cep text not null,
        rua text not null,
        numero integer not null,
        bairro text not null,
        cidade text not null,
        uf text not null,
        pais text not null
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}
}
