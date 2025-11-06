import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_dog_app/views/tela_cadastro_pet.dart';
import '../controller/pet_controller.dart';

class MeusPets extends StatefulWidget {
  const MeusPets({super.key});

  @override
  State<MeusPets> createState() => _MeusPetsState();
}

class _MeusPetsState extends State<MeusPets> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final petCtrl = context.read<PetController>();
      await petCtrl.carregarPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final petCtrl = context.watch<PetController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Pets')),
      body: petCtrl.carregando
          ? const Center(child: CircularProgressIndicator())
          : petCtrl.pets.isEmpty
          ? const Center(child: Text('Nenhum pet cadastrado'))
          : ListView.builder(
              itemCount: petCtrl.pets.length,
              itemBuilder: (context, index) {
                final pet = petCtrl.pets[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(pet.nome, style: const TextStyle(fontSize: 18)),
                    subtitle: Text(pet.raca),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await petCtrl.excluirPet(pet);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaCadastroPet()),
          );

          if (resultado == true) {
            await petCtrl.carregarPets();
          }
        },
      ),
    );
  }
}
