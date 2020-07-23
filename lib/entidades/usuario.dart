import 'package:formulario_cadastro/entidades/endereco.dart';

class Usuario {
  String nome;
  String email;
  String cpf;
  Endereco endereco;

  Usuario() {
    endereco = Endereco();
  }
}
