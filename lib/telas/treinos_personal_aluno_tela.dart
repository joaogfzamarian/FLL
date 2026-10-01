import 'package:flutter/material.dart';
import '../tema/cores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TreinosPersonalAlunoTela extends StatefulWidget {
  final String nomeAluno;
  final String alunoId;

  const TreinosPersonalAlunoTela({
    super.key,
    required this.nomeAluno,
    required this.alunoId,
  });

  @override
  State<TreinosPersonalAlunoTela> createState() =>
      _TreinosPersonalAlunoTelaState();
}

class _TreinosPersonalAlunoTelaState extends State<TreinosPersonalAlunoTela>
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------
  // 🔥 Criar treino
  // ---------------------------------------------------------
  void _cadastrarTreino(String diaSemana) {
    final nomeController = TextEditingController();
    final descController = TextEditingController();
    List<Map<String, TextEditingController>> exercicios = [];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateSB) => AlertDialog(
          backgroundColor: AppCores.superficieAlta,
          title: Text(
            "Novo Treino (${diaSemana.toUpperCase()})",
            style: const TextStyle(color: AppCores.texto),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nomeController,
                  style: const TextStyle(color: AppCores.texto),
                  decoration: const InputDecoration(
                    labelText: "Nome do treino",
                    labelStyle: TextStyle(color: AppCores.textoSecundario),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppCores.primaria),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppCores.textoSecundario),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  style: const TextStyle(color: AppCores.texto),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Descrição",
                    labelStyle: TextStyle(color: AppCores.textoSecundario),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppCores.primaria),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppCores.textoSecundario),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Exercícios",
                  style: TextStyle(color: AppCores.primaria, fontSize: 16),
                ),
                const SizedBox(height: 8),

                // Lista de exercícios
                Column(
                  children: exercicios.asMap().entries.map((entry) {
                    final i = entry.key;
                    final ex = entry.value;

                    return Card(
                      color: AppCores.superficieAlta,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            TextField(
                              controller: ex["nome"],
                              style: const TextStyle(color: AppCores.texto),
                              decoration: const InputDecoration(
                                labelText: "Nome",
                                labelStyle: TextStyle(color: AppCores.textoSecundario),
                              ),
                            ),
                            TextField(
                              controller: ex["series"],
                              style: const TextStyle(color: AppCores.texto),
                              decoration: const InputDecoration(
                                labelText: "Séries",
                                labelStyle: TextStyle(color: AppCores.textoSecundario),
                              ),
                            ),
                            TextField(
                              controller: ex["obs"],
                              style: const TextStyle(color: AppCores.texto),
                              decoration: const InputDecoration(
                                labelText: "Observação",
                                labelStyle: TextStyle(color: AppCores.textoSecundario),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon:
                                const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setStateSB(() {
                                    exercicios.removeAt(i);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                OutlinedButton.icon(
                  onPressed: () {
                    setStateSB(() {
                      exercicios.add({
                        "nome": TextEditingController(),
                        "series": TextEditingController(),
                        "obs": TextEditingController(),
                      });
                    });
                  },
                  icon: const Icon(Icons.add, color: AppCores.primaria),
                  label: const Text("Adicionar exercício",
                      style: TextStyle(color: AppCores.primaria)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: AppCores.primaria)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.trim().isEmpty) return;

                final uid = FirebaseAuth.instance.currentUser!.uid;

                final listaEx = exercicios.map((ex) {
                  return {
                    "nome": ex["nome"]!.text.trim(),
                    "series": ex["series"]!.text.trim(),
                    "observacao": ex["obs"]!.text.trim(),
                  };
                }).where((e) => e["nome"]!.isNotEmpty).toList();

                await FirebaseFirestore.instance.collection('treinos').add({
                  'nome': nomeController.text.trim(),
                  'descricao': descController.text.trim(),
                  'exercicios': listaEx,
                  'alunoId': widget.alunoId,
                  'personalId': uid,
                  'diaSemana': diaSemana,
                  'concluido': false,
                  'concluidoEm': null,
                  'validadeSemana': Timestamp.now(),
                  'dataCriacao': Timestamp.now(),
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppCores.primaria,
                foregroundColor: AppCores.sobrePrimaria,
              ),
              child: const Text("Salvar"),
            )
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔥 Interface principal com abas
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBar(
        title: Text("Treinos de ${widget.nomeAluno}",
            style: const TextStyle(color: AppCores.primaria)),
        backgroundColor: AppCores.fundo,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppCores.primaria,
          tabs: dias
              .map((d) => Tab(
            child: Text(
              d.toUpperCase(),
              style: const TextStyle(
                color: AppCores.primaria,
                fontWeight: FontWeight.bold,
              ),
            ),
          ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: dias.map((dia) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('treinos')
                .where('alunoId', isEqualTo: widget.alunoId)
                .where('personalId', isEqualTo: uid)
                .where('diaSemana', isEqualTo: dia)
                .orderBy('dataCriacao', descending: true)
                .snapshots(includeMetadataChanges: true),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snap.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    "Nenhum treino para ${dia.toUpperCase()}",
                    style: const TextStyle(color: AppCores.texto),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final exercicios =
                  List<Map<String, dynamic>>.from(data['exercicios'] ?? []);

                  return Card(
                    color: AppCores.superficie,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      title: Text(
                        (data['nome'] ?? "-").toString(),
                        style: const TextStyle(
                            color: AppCores.texto, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        (data['descricao'] ?? "-").toString(),
                        style: const TextStyle(color: AppCores.textoSecundario),
                      ),
                      children: [
                        ...exercicios.map((ex) => ListTile(
                          title: Text(
                            (ex['nome'] ?? "-").toString(),
                            style: const TextStyle(color: AppCores.primaria),
                          ),
                          subtitle: Text(
                            "Séries: ${ex['series'] ?? '-'}\nObs: ${ex['observacao'] ?? '-'}",
                            style: const TextStyle(color: AppCores.textoSecundario),
                          ),
                        )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _confirmarExclusaoTreino(doc.id),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppCores.primaria,
        child: const Icon(Icons.add, color: AppCores.sobrePrimaria),
        onPressed: () {
          final dia = dias[_tabController.index];
          _cadastrarTreino(dia);
        },
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔥 Confirmação de exclusão
  // ---------------------------------------------------------
  Future<void> _confirmarExclusaoTreino(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppCores.superficie,
        title: const Text("Excluir treino?",
            style: TextStyle(color: AppCores.primaria)),
        content: const Text("Esta ação não pode ser desfeita.",
            style: TextStyle(color: AppCores.textoSecundario)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
            const Text("Cancelar", style: TextStyle(color: AppCores.primaria)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await FirebaseFirestore.instance.collection('treinos').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Treino excluído")));
      }
    }
  }
}
