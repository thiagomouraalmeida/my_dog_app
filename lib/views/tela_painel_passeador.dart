import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:my_dog_app/controller/passeador_controller.dart';
import 'package:my_dog_app/models/passeador_model.dart';

class PainelPasseador extends StatefulWidget {
  final String emailLogado;

  const PainelPasseador({super.key, required this.emailLogado});

  @override
  State<PainelPasseador> createState() => _PainelPasseadorState();
}

class _PainelPasseadorState extends State<PainelPasseador> {
  bool isEditing = false;

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final passeadorCtrl = context.read<PasseadorController>();
      await passeadorCtrl.carregarPasseador(widget.emailLogado);
      final passeador = passeadorCtrl.passeadorAtual;
      if (passeador != null) _preencherCampos(passeador);
    });
  }

  void _preencherCampos(Passeador passeador) {
    _nomeController.text = passeador.nome;
    _emailController.text = passeador.email;
    _telefoneController.text = passeador.telefone;
  }

  @override
  Widget build(BuildContext context) {
    final passeadorCtrl = context.watch<PasseadorController>();
    final passeador = passeadorCtrl.passeadorAtual;

    if (passeadorCtrl.carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Passeador'),
        centerTitle: true,
        actions: [
          if (passeador != null)
            IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit),
              onPressed: () async {
                if (isEditing) {
                  if (_formKey.currentState!.validate()) {
                    final atualizado = Passeador(
                      id: passeador.id,
                      nome: _nomeController.text,
                      email: _emailController.text,
                      telefone: _telefoneController.text,
                      senha: passeador.senha,
                      funcao: passeador.funcao,
                    );

                    await passeadorCtrl.atualizarPasseador(atualizado);

                    setState(() => isEditing = false);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dados atualizados com sucesso!'),
                      ),
                    );
                  }
                } else {
                  setState(() => isEditing = true);
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              // desloga do Firebase
              await FirebaseAuth.instance.signOut();

              if (!mounted) return;

              // navega pra tela de login
              context.go('/login');
            },
          ),
        ],
      ),
      body: passeador == null
          ? const Center(child: Text("Nenhum passeador encontrado"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _textField(
                      label: "Nome",
                      controller: _nomeController,
                      validator: passeadorCtrl.validarNome,
                    ),
                    const SizedBox(height: 16),
                    _textField(
                      label: "Email",
                      controller: _emailController,
                      validator: passeadorCtrl.validarEmail,
                    ),
                    const SizedBox(height: 16),
                    _textField(
                      label: "Telefone",
                      controller: _telefoneController,
                      validator: passeadorCtrl.validarTelefone,
                    ),
                    const SizedBox(height: 24),
                    if (isEditing)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("Salvar Alterações"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final atualizado = Passeador(
                              id: passeador.id,
                              nome: _nomeController.text,
                              email: _emailController.text,
                              telefone: _telefoneController.text,
                              senha: passeador.senha,
                              funcao: passeador.funcao,
                            );

                            await passeadorCtrl.atualizarPasseador(atualizado);
                            setState(() => isEditing = false);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Dados atualizados com sucesso!'),
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      style: const TextStyle(fontSize: 18),
      validator: validator,
      enabled: isEditing,
    );
  }
}
