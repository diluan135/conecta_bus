import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Enquete {
  final int id;
  final String titulo;
  final String descricao;

  Enquete({required this.id, required this.titulo, required this.descricao});

  factory Enquete.fromJson(Map<String, dynamic> json) {
    return Enquete(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'] ?? '',
    );
  }
}

class OpcaoVoto {
  final int id;
  final String opcao;
  final String? cor;

  OpcaoVoto({required this.id, required this.opcao, this.cor});

  factory OpcaoVoto.fromJson(Map<String, dynamic> json) {
    return OpcaoVoto(
      id: json['id'],
      opcao: json['opcao'],
      cor: json['cor'],
    );
  }
}

class EnquetesPage extends StatefulWidget {
  @override
  _EnquetesPageState createState() => _EnquetesPageState();
}

class _EnquetesPageState extends State<EnquetesPage> {
  late Future<List<Enquete>> enquetes;
  Map<int, int?> votosUsuario = {};
  Map<int, bool> mostrarOpcoes = {};
  Set<int> enquetesVotadas = {};
  Map<int, List<OpcaoVoto>> opcoesCache = {};

  @override
  void initState() {
    super.initState();
    enquetes = fetchEnquetes();
    _carregarVotos();
  }

  Future<List<Enquete>> fetchEnquetes() async {
    final response =
        await http.get(Uri.parse('https://mobile.amttdetra.com/api/enquetes'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Enquete.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar as enquetes');
    }
  }

  Future<void> _carregarVotos() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getString('user_id');

    if (usuarioId == null) return;

    final response = await http.get(
      Uri.parse(
          'https://mobile.amttdetra.com/api/votos-enquete?usuario_id=$usuarioId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      Map<int, int?> votosMap = {};
      Set<int> enquetesVotadasSet = {};

      for (var voto in body) {
        votosMap[voto['enquetes_id']] = voto['opcao_id'];
        enquetesVotadasSet.add(voto['enquetes_id']);
      }

      setState(() {
        votosUsuario = votosMap;
        enquetesVotadas = enquetesVotadasSet;

        mostrarOpcoes = {for (var e in votosMap.keys) e: false};
      });
    } else {
      throw Exception('Falha ao carregar os votos');
    }
  }

  Future<List<OpcaoVoto>> fetchOpcoesVoto(int enqueteId) async {
    if (opcoesCache.containsKey(enqueteId)) {
      return opcoesCache[enqueteId]!;
    }

    final response = await http.get(Uri.parse(
        'https://mobile.amttdetra.com/api/opcoes-enquete/$enqueteId'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<OpcaoVoto> opcoes =
          body.map((dynamic item) => OpcaoVoto.fromJson(item)).toList();
      opcoesCache[enqueteId] = opcoes;
      return opcoes;
    } else {
      throw Exception('Falha ao carregar as opções de voto');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enquetes'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Enquete>>(
          future: enquetes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Nenhuma enquete disponível'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Enquete enquete = snapshot.data![index];
                  mostrarOpcoes.putIfAbsent(enquete.id, () => false);

                  return _buildEnqueteCard(context, enquete: enquete);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildEnqueteCard(BuildContext context, {required Enquete enquete}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              enquete.titulo,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            Text(
              enquete.descricao,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            FutureBuilder<List<OpcaoVoto>>(
              future: fetchOpcoesVoto(enquete.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Erro ao carregar as opções de voto'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'Não há opções de voto',
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                  );
                } else {
                  List<OpcaoVoto> opcoes = snapshot.data!;
                  bool enqueteVotada = enquetesVotadas.contains(enquete.id);
                  bool mostrarOpcoesAgora = mostrarOpcoes[enquete.id] ?? false;

                  return Column(
                    children: [
                      if (enqueteVotada && !mostrarOpcoesAgora)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              mostrarOpcoes[enquete.id] =
                                  true; // Exibe opções de voto
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.blue[700], // Cor azul escura
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                          ),
                          child: Text(
                            'Enquete já votada. Mudar voto ?',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (mostrarOpcoesAgora || !enqueteVotada)
                        _buildOpcoesVoto(
                          context,
                          enquete.id,
                          opcoes,
                        ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcoesVoto(
      BuildContext context, int enqueteId, List<OpcaoVoto> opcoes) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: opcoes.map((OpcaoVoto opcao) {
        Color corBotao = _parseColor(opcao.cor) ?? Colors.blue;

        return ElevatedButton(
          onPressed: () => _votar(context, enqueteId, opcao.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: corBotao,
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
          child: Text(
            opcao.opcao,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;

    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return null;
    }
  }

  Future<void> _votar(BuildContext context, int enqueteId, int opcaoId) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getString('user_id');

    if (usuarioId == null) return;

    final response = await http.post(
      Uri.parse('https://mobile.amttdetra.com/api/votar'),
      body: json.encode({
        'usuario_id': usuarioId,
        'enquetes_id': enqueteId,
        'opcao_id': opcaoId,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        votosUsuario[enqueteId] = opcaoId; // Atualiza voto localmente
        enquetesVotadas.add(enqueteId); // Marca a enquete como votada
        mostrarOpcoes[enqueteId] = false; // Oculta opções após votar
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voto registrado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar o voto.')),
      );
    }
  }
}
