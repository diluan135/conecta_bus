import 'dart:async'; // Importa o pacote para usar Timer
import 'package:flutter/material.dart';
import 'package:horarios_transporte/controllers/save_localstorage_controller.dart';

class MainListaFavoritos extends StatefulWidget {
  const MainListaFavoritos({super.key});

  @override
  State<MainListaFavoritos> createState() => _MainListaFavoritosState();
}

class _MainListaFavoritosState extends State<MainListaFavoritos> {
  Timer? _timer; // Declara um Timer

  @override
  void initState() {
    super.initState();
    _startTimer(); // Inicia o Timer
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {}); // Atualiza o estado a cada segundo
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela o Timer quando o widget for descartado
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SaveOnLocalStorage("favBoxApp").getAllData(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.isNotEmpty) {
          return Column(
            children: [
              for (var linhasFavoritas in snapshot.data)
                Card(
                  child: ListTile(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/linha', arguments: linhasFavoritas),
                    trailing: GestureDetector(
                      onTap: () {
                        SaveOnLocalStorage("favBoxApp")
                            .deleteData(linhasFavoritas.values.first);
                        SaveOnLocalStorage("rotasLocal")
                            .deleteData(linhasFavoritas.values.first);
                        setState(() {});
                      },
                      child: const Icon(
                        Icons.star,
                        size: 38,
                        color: Color.fromARGB(255, 57, 148, 204),
                      ),
                    ),
                    title: Text(
                      "${linhasFavoritas.keys.first}",
                      style: const TextStyle(),
                    ),
                  ),
                ),
            ],
          );
        } else {
          // Exibe mensagem quando a lista de favoritos está vazia
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.star_border,
                  size: 80,
                  color: Color.fromARGB(255, 57, 148, 204),
                ),
                SizedBox(height: 20),
                Text(
                  "Você ainda não adicionou suas linhas favoritas!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Vá até o menu 'Horários' e clique na estrela ao lado das suas linhas preferidas para salvá-las e ter seus horários disponíveis mesmo sem internet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
