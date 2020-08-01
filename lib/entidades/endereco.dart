class Endereco {
  int id;
  int idUsuario;
  String cep;
  String rua;
  int numero;
  String bairro;
  String cidade;
  String uf;
  String pais;

  Endereco.empty();

  Endereco({
    this.id,
    this.idUsuario,
    this.cep,
    this.rua,
    this.numero,
    this.bairro,
    this.cidade,
    this.uf,
    this.pais,
  });

  Endereco.fromDatabase(Map<String, dynamic> map) {
    id = map.containsKey('idendereco') ? map['idendereco'] : map['id'];
    idUsuario = map['idusuario'];
    cep = map['cep'];
    rua = map['rua'];
    numero = map['numero'];
    bairro = map['bairro'];
    cidade = map['cidade'];
    uf = map['uf'];
    pais = map['pais'];
  }

  Endereco.fromViaCep(Map<String, dynamic> map) {
    rua = map['logradouro'];
    bairro = map['bairro'];
    cidade = map['localidade'];
    uf = map['uf'];
    pais = 'Brasil';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idusuario': idUsuario,
      'cep': cep,
      'rua': rua,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'pais': pais,
    };
  }

  @override
  String toString() {
    return '$rua, $numero. Bairro $bairro, $cidade - $uf ($pais) CEP: $cep';
  }
}
