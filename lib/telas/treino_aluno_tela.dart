import 'package:firebase_auth/firebase_auth.dart';
import '../tema/cores.dart';
import 'package:flutter/material.dart';
import '../servicos/treino_service.dart';
import '../modelos/treino.dart';

class TreinoAlunoTela extends StatefulWidget {
  const TreinoAlunoTela({super.key});

  @override
  State<TreinoAlunoTela> createState() => _TreinoAlunoTelaState();
}

class _TreinoAlunoTelaState extends State<TreinoAlunoTela>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final dias = const [
    "segunda",
    "terca",
    "quarta",
    "quinta",
    "sexta",
    "sabado",
    "domingo",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: dias.length, vsync: this);

    final dow = DateTime.now().weekday - 1; // segunda=0
    if (dow >= 0 && dow < dias.length) {
      _tabController.index = dow;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _tabItem(String label) {
    return Tab(
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppCores.primaria,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔥 CARD GRANDE (VERSÃO ORIGINAL, SEM BOTÃO)
  // ---------------------------------------------------------
  Widget _cardTreino(BuildContext context, Treino t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppCores.superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppCores.primaria,
          width: 1.2,
        ),
      ),

      // Mantém o mesmo tamanho visual de antes
      constraints: const BoxConstraints(
        minHeight: 180,   // <-- AQUI GARANTE O CARD GRANDE
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.nome,
            style: const TextStyle(
              color: AppCores.primaria,
              fontSize: 20, // maior como antes
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          if (t.descricao.isNotEmpty)
            Text(
              t.descricao,
              style: const TextStyle(
                color: AppCores.textoSecundario,
                fontSize: 16,
              ),
            ),

          if (t.frequencia.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                "Frequência: ${t.frequencia}",
                style: const TextStyle(
                  color: AppCores.textoSuave,
                  fontSize: 14,
                ),
              ),
            ),

          const SizedBox(height: 12),

          ...t.exercicios.map(
                (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                "${e['nome'] ?? ''} - ${e['series'] ?? ''}\nObs: ${e['observacao'] ?? ''}",
                style: const TextStyle(
                  color: AppCores.textoSecundario,
                  fontSize: 15, // maior como antes
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔥 CONSTRUÇÃO PRINCIPAL
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(
        child: Text(
          'Não autenticado',
          style: TextStyle(color: AppCores.texto),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBar(
        backgroundColor: AppCores.fundo,
        title: const Text('Meus Treinos', style: TextStyle(color: AppCores.primaria)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppCores.primaria,
          tabs: dias.map((d) => _tabItem(d)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: dias.map((dia) {
          return StreamBuilder<List<Treino>>(
            stream: TreinoService.instancia.streamTreinosPorDia(uid, dia),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var lista = snap.data ?? [];

              if (lista.isEmpty) {
                return Center(
                  child: Text(
                    "Nenhum treino para ${dia.toUpperCase()}",
                    style: const TextStyle(color: AppCores.textoSecundario),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lista.length,
                itemBuilder: (context, i) {
                  return Column(
                    children: [
                      _cardTreino(context, lista[i]),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
