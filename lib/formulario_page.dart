import 'package:cnpj_cpf_formatter/cnpj_cpf_formatter.dart';
import 'package:cnpj_cpf_helper/cnpj_cpf_helper.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'entidades/usuario.dart';

class FormularioPage extends StatefulWidget {
  @override
  _FormularioPageState createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  Usuario _usuario = Usuario();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final cpfController = TextEditingController();
  final cepController = TextEditingController();
  final ruaController = TextEditingController();
  final numeroController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController();
  final ufController = TextEditingController();
  final paisController = TextEditingController();

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

    var dio = Dio();

    try {
      var resposta = await dio.get('https://viacep.com.br/ws/$cep/json/');
      var endereco = resposta.data;
      ruaController.text = endereco['logradouro'];
      bairroController.text = endereco['bairro'];
      cidadeController.text = endereco['localidade'];
      ufController.text = endereco['uf'];
      paisController.text = 'Brasil';
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
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    cpfController.dispose();
    cepController.dispose();
    ruaController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    ufController.dispose();
    paisController.dispose();
    super.dispose();
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
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: nomeController,
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
                          controller: emailController,
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
                          controller: cpfController,
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
                                controller: cepController,
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
                            FlatButton(
                              onPressed: () {
                                if (cepController.text.isNotEmpty) {
                                  _buscarCEP(cepController.text);
                                }
                              },
                              child: Text('Buscar CEP'),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: ruaController,
                                decoration: InputDecoration(
                                  labelText: 'Rua',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (valor) {
                                  if (valor.length < 3)
                                    return 'Rua muito curta';

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
                                controller: numeroController,
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
                                  _usuario.endereco.numero =
                                      int.tryParse(valor);
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
                                controller: bairroController,
                                decoration: InputDecoration(
                                  labelText: 'Bairro',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (valor) {
                                  if (valor.length < 3) return 'Muito curto';

                                  return null;
                                },
                                onSaved: (valor) {
                                  _usuario.endereco.bairro = valor;
                                },
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: TextFormField(
                                controller: cidadeController,
                                decoration: InputDecoration(
                                  labelText: 'Cidade',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (valor) {
                                  if (valor.length < 3) return 'Muito curto';

                                  return null;
                                },
                                onSaved: (valor) {
                                  _usuario.endereco.cidade = valor;
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
                                controller: ufController,
                                decoration: InputDecoration(
                                  labelText: 'UF',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (valor) {
                                  if (valor.length != 2) return 'UF inválido';

                                  return null;
                                },
                                onSaved: (valor) {
                                  _usuario.endereco.uf = valor;
                                },
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: TextFormField(
                                controller: paisController,
                                decoration: InputDecoration(
                                  labelText: 'Pais',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (valor) {
                                  if (valor.toUpperCase() != 'BRASIL')
                                    return 'País inválido';

                                  return null;
                                },
                                onSaved: (valor) {
                                  _usuario.endereco.pais = valor;
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
              child: OutlineButton(
                onPressed: _clickBotao,
                child: Text('Cadastrar'),
                borderSide: BorderSide(
                  color: Colors.red,
                ),
                textColor: Colors.red,
              ),
            )
          ],
        ),
      ),
    );
  }
}
