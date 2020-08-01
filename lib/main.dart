import 'package:flutter/material.dart';
import 'package:formulario_cadastro/pages/formulario_page.dart';
import 'package:formulario_cadastro/pages/home_page.dart';

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
      initialRoute: HomePage.routeName,
      routes: {
        HomePage.routeName: (context) => HomePage(),
        FormularioPage.routeName: (context) => FormularioPage()
      },
    );
  }
}
