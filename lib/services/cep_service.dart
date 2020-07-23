import '../entidades/endereco.dart';
import 'package:dio/dio.dart';

class CepService {
  Future<Endereco> obtemCep(String cep) async {
    var _dio = Dio();
    Endereco _retorno;
    try {
      var _response = await _dio.get('https://viacep.com.br/ws/$cep/json/');
      if (_response.statusCode >= 200 &&
          _response.statusCode < 300 &&
          _response.data != null) {
        _retorno = Endereco.fromMap(_response.data);
      } else {
        throw Exception(_response.statusMessage ?? 'erro indefinido');
      }
    } on DioError catch (e) {
      throw Exception(e.message);
    }
    return _retorno;
  }
}
