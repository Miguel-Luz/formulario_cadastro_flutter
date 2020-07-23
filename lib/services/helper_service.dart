import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

extension HelperString on String {
  String toMD5() {
    var _value = (this ?? '').trim().toLowerCase();
    return HelperService.getMd5(_value);
  }
}

abstract class HelperService {
  static String getMd5(String value) {
    var bytes = utf8.encode(value);
    return md5.convert(bytes).toString();
  }

  static String randomMD5() {
    return Random.secure().nextInt(999999).toString().toMD5();
  }
}
