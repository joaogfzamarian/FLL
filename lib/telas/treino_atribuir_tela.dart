import 'package:cloud_firestore/cloud_firestore.dart';
import '../tema/cores.dart';
import 'package:flutter/material.dart';
import '../modelos/treino.dart';
import '../servicos/treino_service.dart';

class TreinoAtribuirTela extends StatelessWidget {
  const TreinoAtribuirTela({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is! Treino) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Treino inválido',
            style: TextStyle(color: AppCores.texto),
          ),
        ),
      );
    }
    final treino = arg;

    return Scaffold(
      appBar: AppBar(title: const Text('Atribuir a aluno')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('tipo', isEqualTo: 'aluno')
            .orderBy('nome')
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum aluno cadastrado',
                style: TextStyle(color: AppCores.texto),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final nome =
                  d['nome'] ?? d['displayName'] ?? d['email'] ?? 'Aluno';
              final alunoId = docs[i].id;
              final jaAtribuido = treino.alunoId == alunoId;

              return Card(
                color: AppCores.superficie,
                child: ListTile(
                  title: Text(
                    nome.toString(),
                    style: TextStyle(
                      color: jaAtribuido ? Colors.green : AppCores.texto,
                      fontWeight:
                      jaAtribuido ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    "ID: $alunoId",
                    style: const TextStyle(color: AppCores.textoSecundario),
                  ),
                  trailing: jaAtribuido
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.person_add, color: AppCores.primaria),
                  onTap: () async {
                    await TreinoService.instancia
                        .atribuirTreino(treino.id, alunoId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Treino "${treino.nome}" atribuído a $nome',
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
