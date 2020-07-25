import '../entidades/endereco.dart';
import 'package:dio/dio.dart';

class CepService {
  Future<Endereco> obtemCep(String cep) async {
    try {
      var _response = await Dio().get('https://viacep.com.br/ws/$cep/json/');
      var retorno = Endereco.fromMap(_response.data);
      return retorno;
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }
}
