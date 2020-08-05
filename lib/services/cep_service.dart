import '../entidades/endereco.dart';
import 'package:dio/dio.dart';

class CepService {
  Future<Endereco> obtemCep(String cep, {CancelToken cancelToken}) async {
    try {
      var _response = await Dio().get(
        'https://viacep.com.br/ws/$cep/json/',
        cancelToken: cancelToken,
      );
      var retorno = Endereco.fromViaCep(_response.data);
      return retorno;
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }
}
