import 'package:cnpj_cpf_formatter/cnpj_cpf_formatter.dart';
import 'package:cnpj_cpf_helper/cnpj_cpf_helper.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formulario_cadastro/entidades/endereco.dart';
import 'package:formulario_cadastro/services/usuario_service.dart';
import '../services/cep_service.dart';
import '../entidades/usuario.dart';

class FormularioPage extends StatefulWidget {
  static String routeName = '/formulario';
  @override
  _FormularioPageState createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _usuarioService = UsuarioService();

  Usuario _usuario = Usuario.empty();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    var _args = ModalRoute.of(context).settings.arguments;
    if (_args != null && _args is Usuario) {
      _usuario = _args;
      _nomeController.text = _usuario.nome;
      _emailController.text = _usuario.email;
      _cpfController.text = _usuario.cpf;
      _cepController.text = _usuario.endereco?.cep;
      _ruaController.text = _usuario.endereco?.rua;
      _numeroController.text = _usuario.endereco?.numero?.toString();
      _bairroController.text = _usuario.endereco?.bairro;
      _cidadeController.text = _usuario.endereco?.cidade;
      _ufController.text = _usuario.endereco?.uf;
      _paisController.text = _usuario.endereco?.pais;
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

    _usuarioService.salvar(_usuario).then((value) {
      if (value) Navigator.of(context).pop(true);
      _mostrarSnackBar('Ops! algo deu errado...');
    }, onError: _handleError).catchError(_handleError);
  }

  void _handleError(dynamic error) {
    _mostrarSnackBar(error?.toString() ?? 'Erro indefinido');
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
                      buildTextFormField(
                        label: 'Nome completo',
                        controller: _nomeController,
                        onSaved: (valor) => _usuario.nome = valor,
                        validator: (valor) {
                          if (valor.length < 3) return 'Nome muito curto';
                          if (valor.length > 30) return 'Nome muito longo';
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      buildTextFormField(
                        controller: _emailController,
                        label: 'Email',
                        validator: (valor) {
                          if (!EmailValidator.validate(valor)) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                        onSaved: (valor) => _usuario.email = valor,
                      ),
                      SizedBox(height: 15),
                      buildTextFormField(
                        controller: _cpfController,
                        label: 'CPF',
                        validator: (valor) {
                          if (!CnpjCpfBase.isCpfValid(valor))
                            return 'CPF inválido';
                          return null;
                        },
                        onSaved: (valor) => _usuario.cpf = valor,
                        formatters: [
                          CnpjCpfFormatter(eDocumentType: EDocumentType.CPF)
                        ],
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: buildTextFormField(
                              controller: _cepController,
                              label: 'CEP',
                              onSaved: (valor) => _usuario.endereco.cep = valor,
                              validator: (valor) {
                                if (valor.length != 8) return 'CEP Inválido';
                                return null;
                              },
                              formatters: [
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              keyboardType: TextInputType.number,
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
                            child: buildTextFormField(
                              controller: _ruaController,
                              label: 'Rua',
                              validator: (valor) {
                                if (valor.length < 3 || valor.length > 30) {
                                  return 'Rua inválida';
                                }
                                return null;
                              },
                              onSaved: (valor) => _usuario.endereco.rua = valor,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: buildTextFormField(
                              label: 'Número',
                              controller: _numeroController,
                              validator: (valor) {
                                if (int.tryParse(valor) == null)
                                  return 'Número inválido';
                                return null;
                              },
                              onSaved: (valor) {
                                _usuario.endereco.numero = int.tryParse(valor);
                              },
                              formatters: [
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: buildTextFormField(
                              controller: _bairroController,
                              label: 'Bairro',
                              validator: (value) {
                                if (value.length < 3 || value.length > 30) {
                                  return 'Bairro inválido';
                                }
                                return null;
                              },
                              onSaved: (value) =>
                                  _usuario.endereco.bairro = value,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: buildTextFormField(
                              controller: _cidadeController,
                              label: 'Cidade',
                              onSaved: (value) =>
                                  _usuario.endereco.cidade = value,
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
                            child: buildTextFormField(
                              controller: _ufController,
                              label: 'UF',
                              validator: (valor) {
                                if (valor.length != 2) return 'UF inválido';
                                return null;
                              },
                              onSaved: (value) => _usuario.endereco.uf = value,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: buildTextFormField(
                              controller: _paisController,
                              label: 'Pais',
                              validator: (valor) {
                                if (valor.toUpperCase() != 'BRASIL')
                                  return 'País inválido';
                                return null;
                              },
                              onSaved: (valor) =>
                                  _usuario.endereco.pais = valor,
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

  TextFormField buildTextFormField({
    String label,
    TextEditingController controller,
    String Function(String) validator,
    void Function(String) onSaved,
    List<TextInputFormatter> formatters,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: validator,
      onSaved: onSaved,
      inputFormatters: formatters,
      keyboardType: keyboardType,
    );
  }
}
