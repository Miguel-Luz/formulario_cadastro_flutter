import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:formulario_cadastro/entidades/endereco.dart';

import 'package:cnpj_cpf/cnpj_cpf.dart';

import 'entidades/usuario.dart';

class FormularioPage extends StatefulWidget {
  @override
  _FormularioPageState createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  String cpfErro;

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

    var dio = Dio();
    try {
      var resposta = await dio.get('https://viacep.com.br/ws/$cep/json/');
      var endereco = resposta.data;
      ruaController.text = endereco['logradouro'];
      bairroController.text = endereco['bairro'];
      cidadeController.text = endereco['localidade'];
      ufController.text = endereco['uf'];
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'CEP não encontrado!!',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
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
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: nomeController,
                        decoration: InputDecoration(
                          labelText: 'Nome completo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: cpfController,
                        decoration: InputDecoration(
                            labelText: 'CPF',
                            border: OutlineInputBorder(),
                            errorText: cpfErro),
                        onChanged: (valor) {
                          if (!CnpjCpf.isValid(valor)) {
                            setState(() {
                              cpfErro = 'CPF inválido';
                            });
                          } else {
                            setState(() {
                              cpfErro = null;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: cepController,
                              decoration: InputDecoration(
                                labelText: 'CEP',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 10),
                          Builder(
                            builder: (ctx) {
                              return FlatButton(
                                onPressed: () {
                                  if (cepController.text.isNotEmpty) {
                                    _buscarCEP(cepController.text, ctx);
                                  }
                                },
                                child: Text('Buscar CEP'),
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
                            child: TextField(
                              controller: ruaController,
                              decoration: InputDecoration(
                                labelText: 'Rua',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: numeroController,
                              decoration: InputDecoration(
                                labelText: 'Número',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: bairroController,
                              decoration: InputDecoration(
                                labelText: 'Bairro',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextField(
                              controller: cidadeController,
                              decoration: InputDecoration(
                                labelText: 'Cidade',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: ufController,
                              decoration: InputDecoration(
                                labelText: 'UF',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextField(
                              controller: paisController,
                              decoration: InputDecoration(
                                labelText: 'Pais',
                                border: OutlineInputBorder(),
                              ),
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
              child: Builder(
                builder: (ctx) {
                  return OutlineButton(
                    onPressed: () {
                      var usuario = Usuario()
                        ..nome = nomeController.text
                        ..email = emailController.text
                        ..cpf = cpfController.text
                        ..endereco = Endereco()
                        ..endereco.cep = cepController.text
                        ..endereco.rua = ruaController.text
                        ..endereco.bairro = bairroController.text
                        ..endereco.cidade = cidadeController.text
                        ..endereco.uf = ufController.text
                        ..endereco.pais = paisController.text;

                      Scaffold.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Usuario ${usuario?.nome ?? ''} foi criado',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                    child: Text('Cadastrar'),
                    borderSide: BorderSide(
                      color: Colors.red,
                    ),
                    textColor: Colors.red,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
