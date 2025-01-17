import 'package:flutter/material.dart';

class SemDadosWidget extends StatelessWidget {
  const SemDadosWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage("images/desconecta.png"),
            width: 96,
            height: 96,
          ),
          Text("Dia selecionado não possui",
              style: TextStyle(
                fontSize: 24,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              )),
          Text("horários",
              style: TextStyle(
                fontSize: 24,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
}
