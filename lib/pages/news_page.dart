import 'package:horarios_transporte/widgets/loading_widget.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:horarios_transporte/widgets/sem_conexao.dart';
import 'package:http/http.dart' as http;
import 'package:horarios_transporte/components/main_appbar.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}
class _NewsPageState extends State<NewsPage> {
  List fullData = [];
  List<ExpansionPanel> paineis = [];
  List<bool> expansionList = List.filled(15, false);
  bool isLoading = true; // Controla o estado de loading
  bool showNoNotificationsMessage = false; // Controla a exibição da mensagem

  @override
  void initState() {
    super.initState();
    _loadNews();
    _showNoNotificationsMessageAfterDelay();
  }

  void _showNoNotificationsMessageAfterDelay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (fullData.isEmpty) {
        setState(() {
          isLoading = false;
          showNoNotificationsMessage = true;
        });
      }
    });
  }

  void _loadNews() async {
    if (await InternetConnectionChecker().connectionStatus ==
        InternetConnectionStatus.disconnected) {
      setState(() {
        fullData = ['none'];
      });
      return;
    }
    var data = await http.get(
        Uri.parse(
            "https://onesignal.com/api/v1/notifications?app_id=0748ca4f-6e75-4371-8820-7b2114c7332b&limit=10"),
        headers: {
          "Authorization":
              "Bearer OTgxYzI5NjgtOGFiMy00YzI1LThhMDAtMjc4OTMzODBkZWE2"
        });
    var aux = json.decode(data.body)['notifications'];
    setState(() {
      fullData = aux;
      isLoading = false; // O loading termina após carregar os dados
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: isLoading
            ? const LoadingWidget()
            : fullData.isEmpty
                ? Center(
                    child: showNoNotificationsMessage
                        ? const Text(
                            'Sem novas notificações',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Container(), // Exibe container vazio enquanto não chega a mensagem
                  )
                : fullData[0] == 'none'
                    ? const SemConexaoWidget()
                    : SingleChildScrollView(
                        child: ExpansionPanelList(
                          animationDuration: const Duration(milliseconds: 800),
                          expansionCallback: (panelIndex, isExpanded) {
                            setState(() {
                              expansionList[panelIndex] = !isExpanded;
                            });
                          },
                          children: [
                            for (int i = 0; i < fullData.length; i++)
                              ExpansionPanel(
                                isExpanded: expansionList[i],
                                canTapOnHeader: true,
                                headerBuilder: (context, isExpanded) =>
                                    ListTile(
                                  leading: Image(
                                      image: AssetImage(
                                          "images/${fullData[i]['small_icon']}.png")),
                                  subtitle: Text(DateFormat("dd/MM/yyyy")
                                      .format(DateTime
                                          .fromMillisecondsSinceEpoch(
                                              fullData[i]['completed_at'] *
                                                  1000))
                                      .toString()
                                      .substring(0, 10)),
                                  title: Text(
                                    fullData[i]['headings']['en'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                body: ListTile(
                                    title:
                                        Text(fullData[i]['contents']['en'])),
                              )
                          ],
                        ),
                      ),
      ),
    );
  }
}
