import 'package:formulario_cadastro/entidades/endereco.dart';

class Usuario {
  int id;
  String nome;
  String email;
  String cpf;
  Endereco endereco;

  Usuario.empty() {
    endereco = Endereco.empty();
  }

  Usuario({
    this.id,
    this.nome,
    this.email,
    this.cpf,
    this.endereco,
  });

  Usuario.fromDatabase(Map<String, dynamic> map) {
    id = map['id'];
    nome = map['nome'];
    email = map['email'];
    cpf = map['cpf'];
    endereco = Endereco.fromDatabase(map);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'cpf': cpf,
    };
  }

  @override
  String toString() {
    return '$email, endereço: ${endereco?.toString() ?? '-'}';
  }
}
