import 'package:flutter/material.dart';
import '../tema/cores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DietaAlunoTela extends StatelessWidget {
  const DietaAlunoTela({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBar(
        backgroundColor: AppCores.fundo,
        foregroundColor: AppCores.primaria,
        title: const Text(""),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dietas')
            .where('alunoId', isEqualTo: uid)
            .orderBy(FieldPath.documentId, descending: false)   // 🔥 FIX IMPORTANTE
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Nenhuma dieta atribuída",
                style: TextStyle(color: AppCores.texto),
              ),
            );
          }

          // ---- AGRUPAR POR PERÍODO ----
          final grupos = {
            'manha': <String>[],
            'almoco': <String>[],
            'lanche': <String>[],
            'jantar': <String>[],
          };

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final periodo = (data['periodo'] ?? '').toString().toLowerCase();
            final texto = (data['texto'] ?? '').toString();

            if (grupos.containsKey(periodo)) {
              grupos[periodo]!.add(texto);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _blocoPeriodo("☀️ Manhã", grupos['manha']!),
              _blocoPeriodo("🍽 Almoço", grupos['almoco']!),
              _blocoPeriodo("☕ Lanche", grupos['lanche']!),
              _blocoPeriodo("🌙 Jantar", grupos['jantar']!),
            ],
          );
        },
      ),
    );
  }

  Widget _blocoPeriodo(String titulo, List<String> itens) {
    if (itens.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppCores.superficie,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: AppCores.primaria,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...itens.map(
                (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "• $e",
                style: const TextStyle(color: AppCores.texto),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
