import 'package:cnpj_cpf_formatter/cnpj_cpf_formatter.dart';
import 'package:cnpj_cpf_helper/cnpj_cpf_helper.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './services/helper_service.dart';
import './services/cep_service.dart';
import './entidades/usuario.dart';
import './entidades/endereco.dart';

class FormularioPage extends StatefulWidget {
  @override
  _FormularioPageState createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  String _imageUrl;
  String _cpfErro;
  Usuario _usuario;
  final _formKey = GlobalKey<FormState>();
  final _urlBase = 'https://www.gravatar.com/avatar/';
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cepController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final _paisController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _imageUrl = '$_urlBase${HelperService.randomMD5()}?d=robohash';
  }

  void _onChangeEmail(String value) {
    if (EmailValidator.validate(value)) {
      setState(() {
        _imageUrl = '$_urlBase${value.toMD5()}';
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _cepController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    _paisController.dispose();
    super.dispose();
  }

  void _buscarCEP(String cep, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SimpleDialog(
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Buscando cep..',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
    try {
      var _endereco = await CepService().obtemCep(cep);
      _ruaController.text = _endereco?.rua;
      _bairroController.text = _endereco?.bairro;
      _cidadeController.text = _endereco?.cidade;
      _ufController.text = _endereco?.uf;
      _paisController.text = _endereco?.pais;
    } catch (e) {
      Scaffold.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Erro ao buscar o cep',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Text(
                  e.toString(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
    } finally {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Formulário de cadastro'),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 100,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(_imageUrl),
                            ),
                          ),
                        ),
                        Divider(),
                        TextFormField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                            labelText: 'Nome completo',
                            border: OutlineInputBorder(),
                          ),
                          onSaved: (newValue) => _usuario.nome = newValue,
                          validator: (value) {
                            if (value.length < 3 || value.length > 30) {
                              return 'Nome inválido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onFieldSubmitted: _onChangeEmail,
                          validator: (value) {
                            if (!EmailValidator.validate(value)) {
                              return 'E-mail inválido';
                            }
                            return null;
                          },
                          onSaved: (newValue) => _usuario.email = newValue,
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _cpfController,
                          inputFormatters: [
                            CnpjCpfFormatter(
                              eDocumentType: EDocumentType.CPF,
                            )
                          ],
                          decoration: InputDecoration(
                            labelText: 'CPF',
                            border: OutlineInputBorder(),
                            errorText: _cpfErro,
                          ),
                          validator: (valor) {
                            if (!CnpjCpfBase.isCpfValid(valor)) {
                              return 'CPF inválido';
                            }
                            return null;
                          },
                          onSaved: (newValue) => _usuario.cpf = newValue,
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                inputFormatters: [
                                  WhitelistingTextInputFormatter.digitsOnly
                                ],
                                controller: _cepController,
                                decoration: InputDecoration(
                                  labelText: 'CEP',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value.length != 8) {
                                    return 'CEP inválido';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) =>
                                    _usuario.endereco.cep = newValue,
                              ),
                            ),
                            SizedBox(width: 10),
                            Builder(
                              builder: (ctx) {
                                return RaisedButton.icon(
                                  icon: Icon(
                                    Icons.search,
                                  ),
                                  onPressed: () {
                                    if (_cepController.text.isNotEmpty) {
                                      _buscarCEP(_cepController.text, ctx);
                                    }
                                  },
                                  label: Text('Buscar CEP'),
                                );
                              },
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _ruaController,
                                decoration: InputDecoration(
                                  labelText: 'Rua',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value.length < 3 || value.length > 30) {
                                    return 'Rua inválida';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) =>
                                    _usuario.endereco.rua = newValue,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _numeroController,
                                decoration: InputDecoration(
                                  labelText: 'Número',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onSaved: (newValue) => _usuario
                                    .endereco.numero = int.parse(newValue),
                                validator: (value) {
                                  if (int.tryParse(value) == null) {
                                    return 'Número inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                controller: _bairroController,
                                decoration: InputDecoration(
                                  labelText: 'Bairro',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value.length < 3 || value.length > 30) {
                                    return 'Bairro inválido';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) =>
                                    _usuario.endereco.bairro = newValue,
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: TextFormField(
                                controller: _cidadeController,
                                decoration: InputDecoration(
                                  labelText: 'Cidade',
                                  border: OutlineInputBorder(),
                                ),
                                onSaved: (newValue) =>
                                    _usuario.endereco.cidade = newValue,
                                validator: (value) {
                                  if (value.length < 3 || value.length > 30) {
                                    return 'Cidade inválida';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                controller: _ufController,
                                decoration: InputDecoration(
                                  labelText: 'UF',
                                  border: OutlineInputBorder(),
                                ),
                                onSaved: (newValue) =>
                                    _usuario.endereco.uf = newValue,
                                validator: (value) {
                                  if (value.length != 2) {
                                    return 'UF inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: TextFormField(
                                controller: _paisController,
                                decoration: InputDecoration(
                                  labelText: 'Pais',
                                  border: OutlineInputBorder(),
                                ),
                                onSaved: (newValue) =>
                                    _usuario.endereco.pais = newValue,
                                validator: (value) {
                                  if (value.trim().toLowerCase() != 'brasil') {
                                    return 'País inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.maxFinite,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: OutlineButton(
                      onPressed: () {
                        _nomeController.clear();
                        _emailController.clear();
                        _cpfController.clear();
                        _cepController.clear();
                        _ruaController.clear();
                        _numeroController.clear();
                        _bairroController.clear();
                        _cidadeController.clear();
                        _ufController.clear();
                        _paisController.clear();
                        _formKey.currentState.reset();
                      },
                      child: Text('Limpar'),
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                      textColor: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    flex: 3,
                    child: OutlineButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _usuario = Usuario()..endereco = Endereco();
                          _formKey.currentState.save();
                          _mostrarDados();
                        }
                      },
                      child: Text('Cadastrar'),
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                      textColor: Colors.red,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _mostrarDados() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Dados: ${_usuario.nome}',
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 60,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(_imageUrl),
                  ),
                ),
              ),
            ),
            Text(
              'nome:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_usuario.nome ?? ''),
            SizedBox(
              height: 8,
            ),
            Text(
              'email:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_usuario.email ?? ''),
            SizedBox(
              height: 8,
            ),
            Text(
              'cpf:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_usuario.cpf ?? ''),
            SizedBox(
              height: 8,
            ),
            Text(
              'endereco:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              _usuario?.endereco?.toString() ?? '',
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
