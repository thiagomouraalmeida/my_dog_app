import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PasseiosAceitosPasseador extends StatelessWidget {
  final String passeadorId;

  const PasseiosAceitosPasseador({super.key, required this.passeadorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Passeios Aceitos')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("passeios")
            .where("passeadorId", isEqualTo: passeadorId)
            .where("status", isEqualTo: "aceito")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final dados = snapshot.data!.docs;

          if (dados.isEmpty) {
            return const Center(
              child: Text(
                "Você não aceitou nenhum passeio ainda.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: dados.length,
            itemBuilder: (context, index) {
              final doc = dados[index].data() as Map<String, dynamic>;

              final nomePet = doc['pet'] ?? 'Pet';
              final endereco = doc['endereco'] ?? 'Endereço não informado';
              final dataIso = doc['dataHora'] ?? '';
              final dataHora = DateTime.tryParse(dataIso);

              final dataFormatada = dataHora != null
                  ? "${dataHora.day.toString().padLeft(2, '0')}/"
                        "${dataHora.month.toString().padLeft(2, '0')}/"
                        "${dataHora.year} "
                        "${dataHora.hour.toString().padLeft(2, '0')}:"
                        "${dataHora.minute.toString().padLeft(2, '0')}"
                  : "Data não informada";

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomePet,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              endereco,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.schedule),
                          const SizedBox(width: 6),
                          Text(
                            dataFormatada,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection("passeios")
                                .doc(dados[index].id)
                                .update({"status": "finalizado"});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Passeio marcado como finalizado!",
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("Finalizar Passeio"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
