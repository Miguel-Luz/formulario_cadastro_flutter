class Endereco {
  String cep;
  String rua;
  int numero;
  String bairro;
  String cidade;
  String uf;
  String pais;

  Endereco({
    this.cep,
    this.rua,
    this.numero,
    this.bairro,
    this.cidade,
    this.uf,
    this.pais,
  });

  Endereco.fromMap(Map<String, dynamic> map) {
    rua = map['logradouro'];
    bairro = map['bairro'];
    cidade = map['localidade'];
    uf = map['uf'];
    pais = 'Brasil';
  }
}
