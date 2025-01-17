import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:horarios_transporte/widgets/message_bubble.dart'; // Ajuste o caminho conforme necessário

class DetalhesSolicitacao extends StatefulWidget {
  final String solicitacaoId;

  DetalhesSolicitacao({required this.solicitacaoId});

  @override
  _DetalhesSolicitacaoState createState() => _DetalhesSolicitacaoState();
}

class _DetalhesSolicitacaoState extends State<DetalhesSolicitacao> {
  late Future<List<dynamic>> futureMessages;
  final TextEditingController _messageController = TextEditingController();
  late int meuUsuarioId;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Carregue o ID do usuário antes de buscar mensagens
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('user_id');
    if (userIdString != null) {
      final userId = int.tryParse(userIdString);
      if (userId != null) {
        setState(() {
          meuUsuarioId = userId;
          futureMessages = _fetchMessages();
        });
      } else {
        _showError('ID do usuário é inválido.');
      }
    } else {
      _showError('ID do usuário não encontrado.');
    }
  }

  Future<List<dynamic>> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://mobile.amttdetra.com/api/mensagens/${widget.solicitacaoId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        // Reverter a lista para que a mensagem mais recente apareça no topo
        return data.reversed.toList();
      } else {
        throw Exception('Falha ao carregar mensagens');
      }
    } catch (e) {
      print('Erro ao recuperar mensagens: $e');
      return []; // Retorne uma lista vazia em caso de erro
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final data = {
      'chat_id': widget.solicitacaoId,
      'usuario_id': meuUsuarioId,
      'mensagem': message,
    };

    // Mostrar o conteúdo da mensagem que será enviada
    print('Enviando dados: $data');

    try {
      final response = await http.post(
        Uri.parse('https://mobile.amttdetra.com/api/salvar-mensagens'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        _messageController.clear();
        setState(() {
          futureMessages = _fetchMessages(); // Atualize a lista de mensagens
        });
      } else {
        throw Exception('Falha ao enviar mensagem');
      }
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Solicitação'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: futureMessages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar mensagens'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Nenhuma mensagem encontrada'));
                } else {
                  final mensagens = snapshot.data!;

                  return ListView.builder(
                    reverse:
                        true, // Inverte a ordem para a mensagem mais recente aparecer no final
                    itemCount: mensagens.length,
                    itemBuilder: (context, index) {
                      final msg = mensagens[index];
                      return MessageBubble(
                        message: msg['mensagem'],
                        isMe: msg['usuario_id'] == meuUsuarioId,
                        time: "",
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite uma mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
