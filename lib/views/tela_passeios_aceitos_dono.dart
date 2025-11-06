import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PasseiosDono extends StatelessWidget {
  final String donoId;

  const PasseiosDono({super.key, required this.donoId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meus Passeios'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Pendentes"),
              Tab(text: "Aceitos"),
              Tab(text: "Finalizados"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLista(context, "pendente"),
            _buildLista(context, "aceito"),
            _buildLista(context, "finalizado"),
          ],
        ),
      ),
    );
  }

  Widget _buildLista(BuildContext context, String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("passeios")
          .where("donoId", isEqualTo: donoId)
          .where("status", isEqualTo: status)
          .orderBy("dataHora", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("Erro ao carregar dados."));
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Text(
              status == "pendente"
                  ? "Nenhum passeio pendente."
                  : status == "aceito"
                  ? "Nenhum passeio aceito."
                  : "Nenhum passeio finalizado.",
              style: const TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final nomePet = data['pet'] ?? "Pet";
            final endereco = data['endereco'] ?? "Endereço";

            dynamic bruto = data['dataHora']; //aceita string ou date
            DateTime? date;

            if (bruto is Timestamp) {
              date = bruto.toDate();
            } else if (bruto is String) {
              try {
                date = DateTime.parse(bruto);
              } catch (_) {
                date = null;
              }
            }

            final dataFormatada = date != null
                ? "${date.day.toString().padLeft(2, '0')}/"
                      "${date.month.toString().padLeft(2, '0')}/"
                      "${date.year} às "
                      "${date.hour.toString().padLeft(2, '0')}:"
                      "${date.minute.toString().padLeft(2, '0')}"
                : "Data não informada";

            final passeadorId = data['passeadorId'];

            Future<String> obterNomePasseador() async {
              if (passeadorId == null) return "Aguardando passeador";

              final snap = await FirebaseFirestore.instance
                  .collection("passeadores")
                  .doc(passeadorId)
                  .get();

              if (!snap.exists) return "Passeador";

              return (snap.data()?['nome'] ?? "Passeador") as String;
            }

            return FutureBuilder<String>(
              future: obterNomePasseador(),
              builder: (context, nomeSnapshot) {
                final nomePasseador =
                    nomeSnapshot.data ?? "Aguardando passeador";

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
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

                        const SizedBox(height: 10),

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

                        const SizedBox(height: 8),

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

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.person),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                nomePasseador,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (status == "pendente" || status == "aceito")
                          Align(
                            alignment: Alignment.bottomRight,
                            child: OutlinedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection("passeios")
                                    .doc(docs[index].id)
                                    .delete();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Passeio cancelado!"),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text("Cancelar Passeio"),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
