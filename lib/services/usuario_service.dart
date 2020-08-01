import 'package:formulario_cadastro/entidades/usuario.dart';
import 'package:formulario_cadastro/utils/db_helper.dart';

class UsuarioService {
  final _dbHelper = DBHelper();

  String get _sqlBase => '''
    select
        u.*,
        ue.id as idendereco,
        ue.idusuario,
        ue.cep,
        ue.rua,
        ue.numero,
        ue.bairro,
        ue.cidade,
        ue.uf,
        ue.pais
      from 
        usuario u
      left join 
        usuario_endereco ue 
          on ue.idusuario = u.id
      where
        1=1
    ''';

  Future<bool> salvar(Usuario usuario) async {
    var _db = await _dbHelper.getDatabase();
    var _salvou = false;
    if ((usuario.id ?? 0) == 0) {
      var _id = await _db.insert('usuario', usuario.toMap());
      if (_id > 0 && usuario.endereco != null) {
        usuario.endereco.idUsuario = _id;
        await _db.insert('usuario_endereco', usuario.endereco.toMap());
      }
      _salvou = _id > 0;
    } else {
      await _db.update('usuario', usuario.toMap(),
          where: 'id = ?', whereArgs: [usuario.id]);
      if (usuario.endereco != null) {
        await _db.update('usuario_endereco', usuario.endereco.toMap(),
            where: 'id = ?', whereArgs: [usuario.endereco.id]);
      }
      _salvou = true;
    }
    return _salvou;
  }

  Future<void> apagar(Usuario usuario) async {
    var _db = await _dbHelper.getDatabase();
    await _db.delete('usuario', where: 'id = ?', whereArgs: [usuario.id]);
    await _db.delete('usuario_endereco',
        where: 'idusuario = ?', whereArgs: [usuario.id]);
  }

  Future<Usuario> obtem(int id) async {
    var _db = await _dbHelper.getDatabase();
    var _sql = '''
      $_sqlBase
      and u.id = ?
    ''';
    var _result = await _db.rawQuery(_sql, [id]);
    if (_result.isNotEmpty) {
      return Usuario.fromDatabase(_result.first);
    }
    return null;
  }

  Future<List<Usuario>> obtemTodos() async {
    var _db = await _dbHelper.getDatabase();
    var _sql = '''
      $_sqlBase
      order by 
        u.id desc
    ''';
    var _result = await _db.rawQuery(_sql);
    if (_result.isNotEmpty) {
      return _result.map((e) => Usuario.fromDatabase(e)).toList();
    }
    return <Usuario>[];
  }
}
