import 'package:flutter/material.dart';

class SemConexaoWidget extends StatelessWidget {
  const SemConexaoWidget({super.key});

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
          Text(
            "Sem internet",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
