import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'detalhes_solicitacao.dart';

class MinhasSolicitacoes extends StatefulWidget {
  @override
  _MinhasSolicitacoesState createState() => _MinhasSolicitacoesState();
}

class _MinhasSolicitacoesState extends State<MinhasSolicitacoes> {
  Future<List<dynamic>>? _solicitacoesFuture;

  @override
  void initState() {
    super.initState();
    _loadSolicitacoes();
  }

  Future<void> _loadSolicitacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('user_id');

    if (userIdString != null) {
      final userId = int.tryParse(userIdString);
      if (userId != null) {
        _solicitacoesFuture = _fetchSolicitacoes(userId);
        setState(() {});
      } else {
        _showError('Erro: ID do usuário é inválido.');
      }
    } else {
      _showError('Erro: ID do usuário não encontrado.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<List<dynamic>> _fetchSolicitacoes(int userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://mobile.amttdetra.com/api/minhas-solicitacoes?usuario_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final solicitacoes = json.decode(response.body) as List<dynamic>;

        // Cria uma lista de Futures para buscar a última mensagem de cada solicitação
        final futures = solicitacoes.map((solicitacao) async {
          final chatId = solicitacao['id'].toString();
          final ultimaMensagem = await _fetchUltimaMensagem(chatId);
          return {
            ...solicitacao,
            'ultima_mensagem': ultimaMensagem,
          };
        }).toList();

        // Espera todas as requisições das últimas mensagens serem concluídas
        final solicitacoesComMensagens = await Future.wait(futures);

        return solicitacoesComMensagens;
      } else {
        throw Exception('Falha ao carregar solicitações');
      }
    } catch (e) {
      _showError('Erro ao carregar solicitações');
      return [];
    }
  }

  Future<String> _fetchUltimaMensagem(String chatId) async {
    try {
      final response = await http.get(
        Uri.parse('https://mobile.amttdetra.com/api/ultimaMensagem/$chatId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ultima_mensagem'] ?? 'Nenhuma mensagem encontrada';
      } else {
        return 'Nenhuma mensagem encontrada';
      }
    } catch (e) {
      return 'Erro ao buscar mensagem';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Solicitações'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _solicitacoesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar solicitações'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma solicitação encontrada'));
          } else {
            final solicitacoes = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: solicitacoes.length,
              itemBuilder: (context, index) {
                final solicitacao = solicitacoes[index];
                final solicitacaoId = solicitacao['id'].toString();
                final ultimaMensagem = solicitacao['ultima_mensagem'] ?? '';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    title: Text(
                      solicitacao['assunto'] ?? 'Assunto não disponível',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      ultimaMensagem, // Exibe a última mensagem
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalhesSolicitacao(
                            solicitacaoId: solicitacaoId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
