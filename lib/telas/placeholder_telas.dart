
import 'package:flutter/material.dart';
import '../tema/cores.dart';

class AlunosTela extends StatelessWidget {
  const AlunosTela({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBar(
        backgroundColor: AppCores.fundo,
        iconTheme: const IconThemeData(color: AppCores.primaria),
        title: const Text('Alunos', style: TextStyle(color: AppCores.texto)),
      ),
      body: const Center(
        child: Text('Tela de Alunos', style: TextStyle(color: AppCores.texto)),
      ),
    );
  }
}

class CriarTreinoTela extends StatelessWidget {
  const CriarTreinoTela({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBar(
        backgroundColor: AppCores.fundo,
        iconTheme: const IconThemeData(color: AppCores.primaria),
        title: const Text('Criar Treino', style: TextStyle(color: AppCores.texto)),
      ),
      body: const Center(
        child: Text('Tela para criação de treino', style: TextStyle(color: AppCores.texto)),
      ),
    );
  }
}

class CriarDietaTela extends StatelessWidget {
  const CriarDietaTela({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBar(
        backgroundColor: AppCores.fundo,
        iconTheme: const IconThemeData(color: AppCores.primaria),
        title: const Text('Criar Dieta', style: TextStyle(color: AppCores.texto)),
      ),
      body: const Center(
        child: Text('Tela para criação de dieta', style: TextStyle(color: AppCores.texto)),
      ),
    );
  }
}

class EvolucaoAlunoTela extends StatelessWidget {
  const EvolucaoAlunoTela({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBar(
        backgroundColor: AppCores.fundo,
        iconTheme: const IconThemeData(color: AppCores.primaria),
        title: const Text('Evolução do Aluno', style: TextStyle(color: AppCores.texto)),
      ),
      body: const Center(
        child: Text('Tela de evolução do aluno', style: TextStyle(color: AppCores.texto)),
      ),
    );
  }
}

class LembretesTela extends StatelessWidget {
  const LembretesTela({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBar(
        backgroundColor: AppCores.fundo,
        iconTheme: const IconThemeData(color: AppCores.primaria),
        title: const Text('Lembretes', style: TextStyle(color: AppCores.texto)),
      ),
      body: const Center(
        child: Text('Tela de lembretes', style: TextStyle(color: AppCores.texto)),
      ),
    );
  }
}
