import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Passeios extends StatefulWidget {
  final String donoId;
  final String enderecoDono;

  const Passeios({super.key, required this.donoId, required this.enderecoDono});

  @override
  State<Passeios> createState() => _PasseiosState();
}

class _PasseiosState extends State<Passeios> {
  String? petSelecionado;
  DateTime? dataHoraSelecionada;

  final TextEditingController dataHoraController = TextEditingController();

  Future<void> selecionarDataHora() async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2099),
    );

    if (dataEscolhida == null) return;

    final TimeOfDay? horaEscolhida = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (horaEscolhida == null) return;

    final DateTime completa = DateTime(
      dataEscolhida.year,
      dataEscolhida.month,
      dataEscolhida.day,
      horaEscolhida.hour,
      horaEscolhida.minute,
    );

    setState(() {
      dataHoraSelecionada = completa;
      dataHoraController.text =
          "${completa.day.toString().padLeft(2, '0')}/"
          "${completa.month.toString().padLeft(2, '0')}/"
          "${completa.year} "
          "${horaEscolhida.hour.toString().padLeft(2, '0')}:"
          "${horaEscolhida.minute.toString().padLeft(2, '0')}";
    });
  }

  Future<void> cadastrarPasseio() async {
    if (petSelecionado == null || dataHoraSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione um pet e o horário do passeio."),
        ),
      );
      return;
    }

    final passeio = {
      "donoId": widget.donoId,
      "passeadorId": null,
      "pet": petSelecionado,
      "endereco": widget.enderecoDono,
      "dataHora": dataHoraSelecionada!.toIso8601String(),
      "status": "pendente",
      "criadoEm": DateTime.now(),
    };

    await FirebaseFirestore.instance.collection("passeios").add(passeio);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passeio cadastrado com sucesso!")),
    );

    setState(() {
      petSelecionado = null;
      dataHoraSelecionada = null;
      dataHoraController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Passeio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selecione um Pet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("pets")
                  .where("donoId", isEqualTo: widget.donoId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Nenhum pet cadastrado."),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          GoRouter.of(context).go('/tela-cadastro-pet');
                        },
                        child: const Text("Cadastrar Pet"),
                      ),
                    ],
                  );
                }

                final pets = docs.map((d) => d['nome'].toString()).toList();

                return DropdownButtonFormField<String>(
                  value: petSelecionado,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: pets.map((nome) {
                    return DropdownMenuItem(value: nome, child: Text(nome));
                  }).toList(),
                  onChanged: (valor) {
                    setState(() => petSelecionado = valor);
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: dataHoraController,
              readOnly: true,
              onTap: selecionarDataHora,
              decoration: const InputDecoration(
                labelText: "Data e Hora",
                hintText: "Selecione no calendário",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            //adicionar edicao de endereco
            TextFormField(
              initialValue: widget.enderecoDono,
              enabled: false,
              decoration: InputDecoration(
                labelText: "Endereço",
                border: const OutlineInputBorder(),
                hintText: widget.enderecoDono,
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: cadastrarPasseio,
                child: const Text("Cadastrar Passeio"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
