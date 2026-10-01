import 'package:flutter/material.dart';
import '../tema/cores.dart';

class CarregamentoTela extends StatefulWidget {
  const CarregamentoTela({super.key});

  @override
  State<CarregamentoTela> createState() => _CarregamentoTelaState();
}

class _CarregamentoTelaState extends State<CarregamentoTela> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppCores.primaria, AppCores.primariaEscura],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Image.asset(
            'imagens/logo_branca.png',
            width: 200,
          ),
        ),
      ),
    );
  }
}
