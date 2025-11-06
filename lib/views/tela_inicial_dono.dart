import 'package:flutter/material.dart';
import 'package:my_dog_app/models/dono_model.dart';
import 'package:my_dog_app/views/tela_meus_pets.dart';
import 'package:my_dog_app/views/tela_painel_dono.dart';
import 'package:my_dog_app/views/tela_passeios.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_dog_app/views/tela_passeios_aceitos_dono.dart';

class TelaInicialDono extends StatefulWidget {
  final Dono dono;
  const TelaInicialDono({super.key, required this.dono});

  @override
  State<TelaInicialDono> createState() => _TelaInicialDonoState();
}

class _TelaInicialDonoState extends State<TelaInicialDono> {
  int paginaAtual = 0;
  late PageController pc;

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: paginaAtual);
  }

  @override
  void dispose() {
    pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pc,
        children: [
          PainelDono(emailLogado: widget.dono.email),
          MeusPets(),
          Passeios(donoId: widget.dono.id, enderecoDono: widget.dono.endereco),
          PasseiosDono(donoId: widget.dono.id),
        ],
        onPageChanged: (value) {
          setState(() {
            paginaAtual = value;
          });
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: paginaAtual,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Painel"),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Meus Pets"),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.dog),
            label: 'Novo Passeio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: 'Passeios',
          ),
        ],
        onTap: (pagina) {
          pc.animateToPage(
            pagina,
            duration: const Duration(milliseconds: 50),
            curve: Curves.ease,
          );
        },
      ),
    );
  }
}
