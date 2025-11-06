import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_dog_app/controller/pet_controller.dart';
import 'package:my_dog_app/service/dono_service.dart';
import 'package:my_dog_app/service/passeador_service.dart';
import 'package:provider/provider.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final _auth = FirebaseAuth.instance;
  final _donoService = DonoService();
  final _passeadorService = PasseadorService();

  @override
  void initState() {
    super.initState();
    _decidirParaOndeIr();
  }

  Future<void> _decidirParaOndeIr() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = _auth.currentUser;

    if (!mounted) return;

    if (user == null) {
      GoRouter.of(context).go('/login');
      return;
    }

    final email = user.email;

    if (email == null) {
      await _auth.signOut();
      if (!mounted) return;
      GoRouter.of(context).go('/login');
      return;
    }

    final dono = await _donoService.buscarDonoPorEmail(email);
    if (!mounted) return;

    if (dono != null) {
      context.read<PetController>().configurarDono(dono.id);
      GoRouter.of(context).go('/tela-inicial-dono', extra: dono);
      return;
    }

    final passeador = await _passeadorService.buscarPasseadorPorEmail(email);
    if (!mounted) return;

    if (passeador != null) {
      GoRouter.of(context).go('/tela-inicial-passeador', extra: passeador);
      return;
    }

    await _auth.signOut();
    if (!mounted) return;
    GoRouter.of(context).go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset('images/imagem_tela_inicial.png', fit: BoxFit.fill),
      ),
    );
  }
}
