import 'package:flutter/material.dart ';
import 'package:provider/provider.dart';
import 'package:my_dog_app/service/auth_service.dart';
import 'package:my_dog_app/views/tela_login.dart';
import 'package:my_dog_app/views/tela_painel_dono.dart';
import 'package:my_dog_app/views/tela_painel_passeador.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of<AuthService>(context);

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (auth.usuario == null) {
      return const telaLogin();
    }

    if (auth.funcaoUsuario == null) {
      auth.carregarFuncaoUsuario();
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (auth.funcaoUsuario == 'dono') {
      return PainelDono(emailLogado: auth.usuario!.email!);
    } else if (auth.funcaoUsuario == 'passeador') {
      return PainelPasseador(emailLogado: auth.usuario!.email!);
    } else {
      return const telaLogin();
    }
  }
}
