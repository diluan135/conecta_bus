import 'package:flutter/material.dart';
import 'package:horarios_transporte/controllers/save_localstorage_controller.dart';

class MainHeader extends StatefulWidget {
  const MainHeader({super.key});

  @override
  State<MainHeader> createState() => _MainHeaderState();
}

class _MainHeaderState extends State<MainHeader> {
  @override
  void initState() {
    setPassageiroName();
    super.initState();
  }

  String _passageiro = "Passageiro";

  void setPassageiroName() {
    SaveOnLocalStorage("favBoxApp").getData("user").then((value) {
      // ignore: unnecessary_null_comparison
      if (value != null) {
        setState(() {
          _passageiro = value[0];
        });
      } else {
        throw Exception;
      }
    }).catchError((error) {
      // print("eeeorr");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(255, 255, 255, 1),
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(20, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bem vindo Passageiro,", style:
                  const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Do que você precisa hoje ?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400))
        ],
      ),
    );
  }
}
