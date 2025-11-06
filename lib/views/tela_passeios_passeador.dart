import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PasseiosPasseador extends StatelessWidget {
  final String passeadorId;

  const PasseiosPasseador({super.key, required this.passeadorId});

  Future<void> aceitarPasseio(String passeioId) async {
    await FirebaseFirestore.instance
        .collection("passeios")
        .doc(passeioId)
        .update({"passeadorId": passeadorId, "status": "aceito"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Passeios Pendentes")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("passeios")
            .where("status", isEqualTo: "pendente")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Nenhum passeio pendente."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text("Pet: ${data['pet']}"),
                subtitle: Text("${data['endereco']} - ${data['data']}"),
                trailing: ElevatedButton(
                  onPressed: () => aceitarPasseio(doc.id),
                  child: const Text("Aceitar"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
