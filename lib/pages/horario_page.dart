import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:horarios_transporte/components/horarios_navigationbar.dart';
import 'package:horarios_transporte/components/listagem_horarios.dart';
import 'package:horarios_transporte/controllers/horarios_controller.dart';
import 'package:horarios_transporte/widgets/loading_widget.dart';
import 'package:horarios_transporte/widgets/sem_dados.dart';
import 'package:horarios_transporte/widgets/sem_conexao.dart';
import 'package:http/http.dart' as http;
import 'package:horarios_transporte/components/main_appbar.dart';
import 'package:horarios_transporte/controllers/save_localstorage_controller.dart';

class PageHorarios extends StatefulWidget {
  const PageHorarios({super.key});

  @override
  State<PageHorarios> createState() => _PageHorariosState();
}

class _PageHorariosState extends State<PageHorarios> {
  // Variaveis de controle para que o sistema funcione corretamente
  HorariosController hController = Get.put(HorariosController());
  late String validateSentido;
  bool favs = false;
  bool _sValue = false;
  String? _selectedItinerario = "linha";
  int currentIndex = 0;
  final DateTime horaController = DateTime.now();
  Map<String?, String> nomesRotasUnicas = {
    '32': 'Terminal Central-Terminal N. Rússia',
    '33': 'Terminal Central-Terminal Oficinas',
    '34': 'Terminal Central-Terminal Uvaranas',
    '78': 'Terminal Oficinas-Terminal N. Rússia',
    '99': 'Terminal Uvaranas-Terminal N. Rússia',
    '100': 'Terminal Uvaranas-Terminal Oficinas',
  };

  // Funcao que carrega da api os dados de todas as possiveis rotas
  Future<List> _loadItinerario() async {
    final response = await http
        .post(Uri.parse('https://mobile.amttdetra.com/api/itinerarios'));
    return json.decode(response.body);
  }

  // Funcao que retorna em items para colocar no menu de cada possivel rotas que
  // é retornada pela funcao _loadItinerario()
  List<DropdownMenuItem<String>> _menuItems(data) {
    List<DropdownMenuItem<String>> menuItems = [];
    menuItems.add(const DropdownMenuItem(
        value: 'linha', child: Text('-- Selecione a linha --')));
    for (var element in data) {
      menuItems.add(DropdownMenuItem(
          value: element['id'].toString(), child: Text('${element['linha']}')));
    }
    return menuItems;
  }

  Future<List> _loadHorario(String? id, dia, itinerario) async {
    List<List> dias = [[], [], []];
    String temp = await getTemporario(id);
    final response = await http.post(
        Uri.parse('https://mobile.amttdetra.com/api/nhorarios'),
        body: {"id": id, "temp": temp});

    var dataJson = await json.decode(response.body);
    int contagem = 0;

    for (final item in dataJson) {
      if (item['dia'] == 'util') {
        dias[0].add(item);
      } else if (item['dia'] == 'sabado') {
        dias[1].add(item);
      } else {
        dias[2].add(item);
      }
    }
    for (var item in dias[dia]) {
      if (int.parse(item['horario'].substring(0, 2)) == horaController.hour) {
        break;
      } else {
        contagem++;
      }
    }
    // fuuncuina
    late String ret = '';
    for (var rota in itinerario) {
      if (rota['id'].toString() == _selectedItinerario) {
        ret = rota['linha'].toString();
        break;
      } else {
        ret = 'not-found';
      }
    }
    if (!favs) {
      try {
        SaveOnLocalStorage("favBoxApp").deleteData("$id");
        SaveOnLocalStorage("rotasLocal").deleteData("$id");
      } on Exception {}
    } else {
      SaveOnLocalStorage("favBoxApp").writeDate("$id", {ret: "$id"});
    }
    currentIndex = contagem;
    return dias[dia];
  }

  Future<String> getTemporario(id) async {
    var data = await http.post(
        Uri.parse("https://mobile.amttdetra.com/api/validar"),
        body: {"id": id});
    var res = await json.decode(data.body);
    return res[0]['utilizar'] == '1' ? 'nao' : 'sim';
  }

  void checkFavorito(itinerario) {
    SaveOnLocalStorage("favBoxApp").getData("$itinerario").then((value) {
      if (value.isEmpty) {
        setState(() {
          favs = false;
          _selectedItinerario = itinerario;
        });
      } else {
        setState(() {
          favs = true;
          _selectedItinerario = itinerario;
        });
      }
    }).catchError((err) => null);
  }

  void _setFavorito(data) {
    setState(() {
      favs = !favs;
    });
  }

  List<Text> rotaItems(terminal, bairro) {
    List<Text> items = [Text(terminal), Text(bairro != '' ? bairro : "Bairro")];
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      bottomNavigationBar: const HorariosNavigationBar(),
      body: FutureBuilder(
        future: _loadItinerario(),
        builder: (context, snap) {
          if (snap.hasData) {
            return Column(
              children: [
                const Divider(color: Colors.transparent),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromRGBO(0, 36, 102, 0.5), width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: DropdownButton(
                      padding: const EdgeInsets.all(8),
                      value: _selectedItinerario,
                      items: _menuItems(snap.data),
                      underline: Container(),
                      icon: GestureDetector(
                        onTap: () {
                          if (_selectedItinerario != 'linha') {
                            _setFavorito(snap.data);
                          }
                        },
                        child: favs
                            ? const Icon(Icons.star,
                                color: Color.fromARGB(255, 57, 148, 204), size: 34)
                            : const Icon(Icons.star_outline,
                                color: Color.fromARGB(255, 57, 148, 204),
                                size: 34),
                      ),
                      onChanged: (value) => checkFavorito(value)),
                ),
                const Divider(color: Colors.transparent),
                ToggleButtons(
                  isSelected: [!_sValue, _sValue],
                  onPressed: (value) => setState(() {
                    _sValue = value == 1 ? true : false;
                  }),
                  constraints: BoxConstraints(
                      minHeight: 60,
                      minWidth: MediaQuery.of(context).size.width / 3),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  selectedColor: Colors.white,
                  // fillColor: const Color.fromRGBO(15, 82, 186, 1),
                  fillColor: const Color.fromRGBO(0, 0, 0, 1),
                  children: [
                    Text(nomesRotasUnicas[_selectedItinerario]?.split("-")[0] ??
                        "Terminal"),
                    Text(nomesRotasUnicas[_selectedItinerario]?.split("-")[1] ??
                        "Bairro"),
                  ],
                ),
                const Divider(color: Colors.transparent),
                if (_selectedItinerario != 'linha')
                  Expanded(child: GetBuilder<HorariosController>(builder: (_) {
                    return FutureBuilder(
                        future: _loadHorario(
                            _selectedItinerario, _.reverseDia(), snap.data),
                        builder: (context, snapshot) {
                          if (favs) {
                            SaveOnLocalStorage("rotasLocal")
                                .getRotas(_selectedItinerario)
                                .then(
                                  (value) => SaveOnLocalStorage("rotasLocal")
                                      .writeDate(_selectedItinerario.toString(),
                                          snapshot.data),
                                );
                          }
                          try {
                            // Caso a conexao termine e tenhamos dados para mostrars
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.data!.isNotEmpty) {
                              return ListagemHorarios(
                                currentIndex: currentIndex,
                                snapData: snapshot.data!,
                                sValue: _sValue,
                              );
                              // Caso a conexao termine e temos uma lista de dados vazia
                            } else if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.data!.isEmpty) {
                              return const SemDadosWidget();
                              // Caso a conexao nao termime temos o gif de carregamento
                            } else {
                              return const LoadingWidget();
                            }
                          } on RangeError {
                            return const SemDadosWidget();
                          }
                        });
                  }))
              ],
            );
          } else if (snap.connectionState == ConnectionState.done &&
              !snap.hasData) {
            return const SemConexaoWidget();
          } else {
            return const LoadingWidget();
          }
        },
      ),
    );
  }
}
