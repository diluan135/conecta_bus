import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart'; // Pacote para obter informações do app

class MainCards extends StatefulWidget {
  const MainCards({super.key});

  @override
  _MainCardsState createState() => _MainCardsState();
}

class _MainCardsState extends State<MainCards> {
  bool sobDemandaEnabled = false;
  bool escutaEnabled = false;
  String sobDemandaIcon = 'images/icone_go.png';
  String? mensagem; // Variável para armazenar a mensagem
  String? mensagemVersao; // Variável para armazenar a mensagem de versão
  String? linkVersao; // Variável para armazenar o link de redirecionamento
  String versaoAtual = '2.1.0'; // Versão atual do app
  String? tituloVersao; // Variável para o título da versão

  @override
  void initState() {
    super.initState();
    _getAppVersion(); // Obtém a versão do aplicativo
    _fetchApiData(); // Busca dados da API
  }

  // Função para obter a versão atual do aplicativo
  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      versaoAtual = packageInfo.version; // Versão do app obtida do build.gradle
    });
  }

  Future<void> _fetchApiData() async {
    final apiUrl = 'https://mobile.amttdetra.com/api/conectaBus';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          sobDemandaEnabled = data['sobdemanda'] == 1;
          escutaEnabled = data['Escuta'] == 1;
          sobDemandaIcon = data['Joia'] == 1 ? 'images/joia.png' : 'images/icone_go.png';
          mensagem = data['mensagem']; // Captura a mensagem

          // Verifica a versão do app
          String versaoApi = data['versao_app'];
          mensagemVersao = data['MensagemVersão'];
          linkVersao = data['link'];
          tituloVersao = data['TituloVersao']; // Captura o título da versão

          if (_isVersaoMaisRecente(versaoApi, versaoAtual)) {
            // Se a versão da API for mais recente, exibe a mensagem de atualização
            _mostrarMensagemAtualizacao(tituloVersao!, mensagemVersao!, linkVersao!);
          }
        });
      } else {
        throw Exception('Erro ao carregar dados da API');
      }
    } catch (e) {
      print('Erro ao acessar a API: $e');
    }
  }

  // Função para comparar a versão atual com a da API
  bool _isVersaoMaisRecente(String versaoApi, String versaoAtual) {
    List<String> vApi = versaoApi.split('.');
    List<String> vAtual = versaoAtual.split('.');

    for (int i = 0; i < vApi.length; i++) {
      int vApiPart = int.parse(vApi[i]);
      int vAtualPart = int.parse(vAtual[i]);
      if (vApiPart > vAtualPart) {
        return true;
      } else if (vApiPart < vAtualPart) {
        return false;
      }
    }
    return false;
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir a URL: $url';
    }
  }

  void _mostrarMensagemAtualizacao(String titulo, String mensagem, String link) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo), // Exibe o título vindo da API
          content: GestureDetector(
            onTap: () {
              _launchURL(link);
            },
            child: Text(
              mensagem,
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Row rowItems(el0, el1, context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (el0['rota'].startsWith('http')) {
              _launchURL(el0['rota']);
            } else {
              Navigator.pushNamed(context, el0['rota']);
            }
          },
          child: Column(
            children: [
              el0['icon'],
              Text(el0['nome']),
            ],
          ),
        ),
        const SizedBox(width: 25),
        GestureDetector(
          onTap: () {
            if (el1['rota'].startsWith('http')) {
              _launchURL(el1['rota']);
            } else {
              Navigator.pushNamed(context, el1['rota']);
            }
          },
          child: Column(
            children: [
              el1['icon'],
              Text(el1['nome']),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> itemCards = [
      {
        "nome": "Horários",
        "rota": "/horarios",
        "icon": Image.asset('images/01_square.png', width: 124, height: 124),
      },
      {
        "nome": "Mapa",
        "rota": "/map",
        "icon": Image.asset('images/02_square.png', width: 124, height: 124),
      },
      {
        "nome": "Informativos",
        "rota": "/news",
        "icon": Image.asset('images/03_square.png', width: 124, height: 124),
      },
      {
        "nome": "Sobre nós",
        "rota": "/ajuda",
        "icon": Image.asset('images/04_square.png', width: 124, height: 124),
      },
    ];

    if (sobDemandaEnabled) {
      itemCards.add({
        "nome": "Sob Demanda",
        "rota": "https://go.amttdetra.com",
        "icon": Image.asset(sobDemandaIcon, width: 124, height: 124),
      });
    }

    if (escutaEnabled) {
      itemCards.add({
        "nome": "Escuta",
        "rota": "/paginaEscuta",
        "icon": Image.asset('images/escuta.png', width: 124, height: 124),
      });
    }

    return Column(
      children: [
        rowItems(itemCards[0], itemCards[1], context),
        const Divider(color: Colors.transparent),
        rowItems(itemCards[2], itemCards[3], context),
        const Divider(color: Colors.transparent),
        if (sobDemandaEnabled && escutaEnabled)
          rowItems(itemCards[itemCards.length - 2],
              itemCards[itemCards.length - 1], context),
        if (sobDemandaEnabled && !escutaEnabled)
          Center(
            child: GestureDetector(
              onTap: () {
                _launchURL(itemCards[itemCards.length - 1]['rota']);
              },
              child: Column(
                children: [
                  itemCards[itemCards.length - 1]['icon'],
                  Text(itemCards[itemCards.length - 1]['nome']),
                ],
              ),
            ),
          ),
        if (!sobDemandaEnabled && escutaEnabled)
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                    context, itemCards[itemCards.length - 1]['rota']);
              },
              child: Column(
                children: [
                  itemCards[itemCards.length - 1]['icon'],
                  Text(itemCards[itemCards.length - 1]['nome']),
                ],
              ),
            ),
          ),
        if (mensagem != null) // Exibe a mensagem se não for null
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              mensagem!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
