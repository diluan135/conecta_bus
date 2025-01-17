import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:horarios_transporte/components/listagem_horarios.dart';
import 'package:horarios_transporte/controllers/save_localstorage_controller.dart';
import 'package:horarios_transporte/widgets/loading_widget.dart';
import 'package:http/http.dart' as http;
import 'package:horarios_transporte/widgets/sem_dados.dart';
import 'package:horarios_transporte/components/main_appbar.dart';
import 'package:horarios_transporte/controllers/horarios_controller.dart';
import 'package:horarios_transporte/components/horarios_navigationbar.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class LinhaPage extends StatefulWidget {
  const LinhaPage({super.key});

  @override
  State<LinhaPage> createState() => _LinhaPageState();
}

class _LinhaPageState extends State<LinhaPage> {
  // Variaveis de controle do sistema
  HorariosController hController = Get.put(HorariosController());
  bool _sValue = false;
  int currentIndex = 0;
  DateTime horaController = DateTime.now();
  Map<String?, String> nomesRotasUnicas = {
    '32': 'Terminal Central-Terminal N. Rússia',
    '33': 'Terminal Central-Terminal Oficinas',
    '34': 'Terminal Central-Terminal Uvaranas',
    '78': 'Terminal Oficinas-Terminal N. Rússia',
    '99': 'Terminal Uvaranas-Terminal N. Rússia',
    '100': 'Terminal Uvaranas-Terminal Oficinas',
  };

  Future<dynamic> _loadHorarios(id, dia) async {
    List<List> dias = [[], [], []];
    int contagem = 0;

    if (await InternetConnectionChecker().connectionStatus ==
        InternetConnectionStatus.disconnected) {
      List data =
          await SaveOnLocalStorage("rotasLocal").getRotas(id.values.first);

      for (final item in data) {
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
      currentIndex = contagem;
      return dias[dia];
    }

    String temp = await getTemporario(id.values.first);
    try {
      final response = await http.post(
          Uri.parse('https://mobile.amttdetra.com/api/nhorarios'),
          body: {"id": id.values.first, "temp": temp});

      var dataJson = await json.decode(response.body);

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
      currentIndex = contagem;
      SaveOnLocalStorage("rotasLocal").writeDate(id.values.first, dataJson);
      return dias[dia];
    } on FormatException {
      return [];
    }
  }

  Future<String> getTemporario(id) async {
    var data = await http.post(
        Uri.parse("https://mobile.amttdetra.com/api/validar"),
        body: {"id": id});
    var res = await json.decode(data.body);
    return res[0]['utilizar'] == '1' ? 'nao' : 'sim';
  }

  String _theName(data) {
    return data.keys.first;
  }

  String _theId(data) {
    return data.values.first;
  }

  List<Text> rotaItems(terminal, bairro) {
    List<Text> items = [Text(terminal), Text(bairro != '' ? bairro : "Bairro")];
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    return GetBuilder<HorariosController>(
      builder: (_) {
        return Scaffold(
          appBar: MainAppBar(),
          body: Column(
            children: [
              const Divider(),
              Center(
                child:
                    Text(_theName(args), style: const TextStyle(fontSize: 24)),
              ),
              const Divider(),
              ToggleButtons(
                isSelected: [!_sValue, _sValue],
                onPressed: (value) => setState(() {
                  _sValue = value == 1 ? true : false;
                }),
                constraints: BoxConstraints(
                    minHeight: 60,
                    minWidth: MediaQuery.of(context).size.width / 2.5),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedColor: Colors.white,
                // fillColor: const Color.fromRGBO(15, 82, 186, 1),
                fillColor: const Color.fromRGBO(0, 0, 0, 1),
                children: [
                  Text(nomesRotasUnicas[_theId(args)]?.split("-")[0] ??
                      "Terminal"),
                  Text(nomesRotasUnicas[_theId(args)]?.split("-")[1] ??
                      "Bairro"),
                ],
              ),
              const Divider(color: Colors.transparent),
              Expanded(
                child: FutureBuilder(
                  future: _loadHorarios(args, _.reverseDia()),
                  builder: (context, snapshot) {
                    try {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data.length > 0) {
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: ListagemHorarios(
                            snapData: snapshot.data!,
                            currentIndex: currentIndex,
                            sValue: _sValue,
                          ),
                        );
                      } else if (snapshot.connectionState ==
                              ConnectionState.done &&
                          snapshot.data.length == 0) {
                        return const SemDadosWidget();
                      } else {
                        return const LoadingWidget();
                      }
                    } on RangeError {
                      return const SemDadosWidget();
                    }
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: const HorariosNavigationBar(),
        );
      },
    );
  }
}
