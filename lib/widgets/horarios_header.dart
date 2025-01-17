import 'package:flutter/material.dart';
import 'package:horarios_transporte/widgets/sem_dados.dart';

class HorariosHeaderWidget extends StatelessWidget {
  final List terminalb;
  final List bairrot;
  const HorariosHeaderWidget({
    super.key,
    required this.terminalb,
    required this.bairrot,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 2.2,
            height: 40,
            decoration: const BoxDecoration(
                color: Color.fromRGBO(9, 49, 94, 1),
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Center(
                child: Text(("${terminalb[0]['t1']}"),
                    style: const TextStyle(color: Colors.white))),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2.2,
            height: 40,
            decoration: const BoxDecoration(
                color: Color.fromRGBO(9, 49, 94, 1),
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Center(
                child: Text(
                    "${bairrot[0]['t2'] != '' ? bairrot[0]['t2'] : 'BAIRRO'}",
                    style: const TextStyle(color: Colors.white))),
          )
        ],
      );
    } on RangeError {
      return const SemDadosWidget();
    }
  }
}
