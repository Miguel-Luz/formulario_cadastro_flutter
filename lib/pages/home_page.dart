import 'package:flutter/material.dart';
import 'package:formulario_cadastro/entidades/usuario.dart';
import 'package:formulario_cadastro/pages/formulario_page.dart';
import 'package:formulario_cadastro/services/usuario_service.dart';

class HomePage extends StatefulWidget {
  static String routeName = '/';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _usuarioService = UsuarioService();
  List<Usuario> _usuarios = <Usuario>[];
  bool _cancelarDelete = false;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  void _carregarUsuarios() {
    _refresh()
        .then((value) => setState(() => _usuarios = value),
            onError: _handleError)
        .catchError(_handleError);
  }

  Future<List<Usuario>> _refresh() {
    return _usuarioService.obtemTodos();
  }

  void _handleError(dynamic error) {
    _mostrarSnackBar(error?.toString() ?? 'Erro indefinido');
  }

  void _handleRetornoFormulario(Object editou) {
    if (editou != null && editou) {
      _carregarUsuarios();
    }
  }

  void _mostrarSnackBarDesfazerDelete(Usuario usuario) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Usuário apagado',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'DESFAZER',
          textColor: Colors.white,
          onPressed: () {
            _cancelarDelete = true;
            _carregarUsuarios();
          },
        ),
      ),
    );

    Future.delayed(Duration(seconds: 5), () {
      if (!_cancelarDelete) {
        _usuarioService.apagar(usuario);
      }
      _cancelarDelete = false;
    });
  }

  void _mostrarSnackBar(String mensagem) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        key: _scaffoldKey,
        behavior: SnackBarBehavior.floating,
        content: Text(
          mensagem,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _itemTile(int index) {
    var _usuario = _usuarios.elementAt(index);
    return Dismissible(
      onDismissed: (direction) => _mostrarSnackBarDesfazerDelete(_usuario),
      background: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.warning,
                color: Theme.of(context).colorScheme.onError,
                size: 32,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'Excluindo o usuário ${_usuario.nome}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
            ],
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      key: UniqueKey(),
      child: ListTile(
        onTap: () {
          Navigator.of(context)
              .pushNamed(FormularioPage.routeName, arguments: _usuario)
              .then(_handleRetornoFormulario);
        },
        leading: Text('#${_usuario.id}'),
        title: Text(_usuario.nome),
        subtitle: Text(_usuario.toString()),
        isThreeLine: true,
      ),
      /* child: ExpansionTile(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(_usuario.toString()),
          ),
        ],
        leading: Text('#${_usuario.id}'),
        title: Text(_usuario.nome),
      ), */
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .pushNamed(FormularioPage.routeName)
              .then(_handleRetornoFormulario);
        },
        child: Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          var _value = await _refresh();
          setState(() {
            _usuarios = _value;
          });
        },
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: _usuarios.length,
          itemBuilder: (context, index) => _itemTile(index),
        ),
      ),
    );
  }
}
