import 'package:flutter/material.dart';
import 'package:formulario_cadastro/formulario_page.dart';

void main() => runApp(MeuApp());

class MeuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red,
        accentColor: Colors.red,
      ),
      home: FormularioPage(),
    );
  }
}
