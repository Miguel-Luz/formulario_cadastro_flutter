import 'package:cnpj_cpf_formatter/cnpj_cpf_formatter.dart';
import 'package:cnpj_cpf_helper/cnpj_cpf_helper.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/cep_service.dart';
import '../entidades/usuario.dart';

class FormularioPage extends StatefulWidget {
  @override
  _FormularioPageState createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  Usuario _usuario = Usuario();
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

  void _mostrarSnackBar(String mensagem) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
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

  void _buscarCEP(String cep) async {
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
      _mostrarSnackBar('CEP não encontrado!!');
    } finally {
      Navigator.of(context).pop();
    }
  }

  void _clickBotao() {
    if (!_formKey.currentState.validate()) {
      _mostrarSnackBar('Informações inválidas');
      return;
    }

    _formKey.currentState.save();
    _mostrarSnackBar('Dados válidos');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          labelText: 'Nome completo',
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) {
                          if (valor.length < 3) return 'Nome muito curto';
                          if (valor.length > 30) return 'Nome muito longo';
                          return null;
                        },
                        onSaved: (valor) {
                          _usuario.nome = valor;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) {
                          if (!EmailValidator.validate(valor))
                            return 'E-mail válido';

                          return null;
                        },
                        onSaved: (valor) {
                          _usuario.email = valor;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _cpfController,
                        decoration: InputDecoration(
                          labelText: 'CPF',
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) {
                          if (!CnpjCpfBase.isCpfValid(valor))
                            return 'CPF inválido';

                          return null;
                        },
                        onSaved: (valor) {
                          _usuario.cpf = valor;
                        },
                        inputFormatters: [
                          CnpjCpfFormatter(eDocumentType: EDocumentType.CPF)
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _cepController,
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                labelText: 'CEP',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (valor) {
                                if (valor.length != 8) return 'CEP Inválido';

                                return null;
                              },
                              onSaved: (valor) {
                                _usuario.endereco.cep = valor;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          FlatButton.icon(
                            icon: Icon(
                              Icons.search,
                            ),
                            onPressed: () {
                              if (_cepController.text.isNotEmpty) {
                                _buscarCEP(_cepController.text);
                              }
                            },
                            label: Text('Buscar CEP'),
                          ),
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
                              validator: (valor) {
                                if (valor.length < 3 || valor.length > 30) {
                                  return 'Rua inválida';
                                }
                                return null;
                              },
                              onSaved: (valor) {
                                _usuario.endereco.rua = valor;
                              },
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
                              validator: (valor) {
                                if (int.tryParse(valor) == null)
                                  return 'Número inválido';

                                return null;
                              },
                              onSaved: (valor) {
                                _usuario.endereco.numero = int.tryParse(valor);
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
                                onSaved: (value) {
                                  _usuario.endereco.bairro = value;
                                }),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextFormField(
                              controller: _cidadeController,
                              decoration: InputDecoration(
                                labelText: 'Cidade',
                                border: OutlineInputBorder(),
                              ),
                              onSaved: (value) {
                                _usuario.endereco.cidade = value;
                              },
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
                              validator: (valor) {
                                if (valor.length != 2) return 'UF inválido';
                                return null;
                              },
                              onSaved: (newValue) =>
                                  _usuario.endereco.uf = newValue,
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
                              validator: (valor) {
                                if (valor.toUpperCase() != 'BRASIL')
                                  return 'País inválido';
                                return null;
                              },
                              onSaved: (newValue) =>
                                  _usuario.endereco.pais = newValue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.maxFinite,
              child: OutlineButton(
                onPressed: _clickBotao,
                child: Text('Cadastrar'),
                borderSide: BorderSide(
                  color: Colors.red,
                ),
                textColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
