import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'detalhes_solicitacao.dart'; // Ajuste o caminho conforme necessário

class NovaSolicitacao extends StatefulWidget {
  @override
  _NovaSolicitacaoState createState() => _NovaSolicitacaoState();
}

class _NovaSolicitacaoState extends State<NovaSolicitacao> {
  String? selectedSolicitationType;
  String? selectedLine;
  Future<List>? itinerariosFuture;
  int? usuarioId; // Armazenar o ID do usuário

  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    itinerariosFuture = _loadItinerario(); // Carrega as linhas ao iniciar
    _getUsuarioId(); // Recupera o ID do usuário
  }

  Future<void> _getUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioIdString =
        prefs.getString('user_id'); // Recupera o ID do usuário como String
    if (usuarioIdString != null) {
      setState(() {
        usuarioId = int.tryParse(usuarioIdString); // Converte o ID para int
      });
    }
  }

  Future<List> _loadItinerario() async {
    final response = await http.post(
      Uri.parse('https://mobile.amttdetra.com/api/itinerarios'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${await _getAuthToken()}', // Inclui o token no cabeçalho
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load itinerários');
    }
  }

  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ??
        ''; // Recupera o token de autenticação
  }

  List<DropdownMenuItem<String>> _menuItems(List data) {
    List<DropdownMenuItem<String>> menuItems = [];
    menuItems.add(const DropdownMenuItem(
        value: null, child: Text('-- Selecione a linha --')));
    for (var element in data) {
      menuItems.add(DropdownMenuItem(
          value: element['linha'], // Usa o nome da linha como valor
          child: Text('${element['linha']}')));
    }
    return menuItems;
  }

  Future<void> _submitRequest() async {
    if (usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Usuário não autenticado')),
      );
      return;
    }

    final String subject = _subjectController.text.trim();
    final String message = _messageController.text.trim();

    if (selectedSolicitationType == null ||
        selectedLine == null ||
        subject.isEmpty ||
        message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    try {
      // Primeiro cria o chat
      final chatPayload = {
        'usuario_id': usuarioId,
        'tipo': selectedSolicitationType,
        'assunto': subject,
        'linha': selectedLine,
        'chat_status': 'Nova solicitação',
      };
      print('Enviando dados para criar chat: $chatPayload');

      final chatResponse = await http.post(
        Uri.parse('https://mobile.amttdetra.com/api/chats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(chatPayload),
      );

      print('Status Code da criação do chat: ${chatResponse.statusCode}');
      print('Resposta da criação do chat: ${chatResponse.body}');

      if (chatResponse.statusCode == 201) {
        final chatId = json.decode(chatResponse.body)['id'];

        // Em seguida, cria a mensagem
        final messagePayload = {
          'usuario_id': usuarioId,
          'chat_id': chatId,
          'mensagem': message,
        };
        print('Enviando dados para criar mensagem: $messagePayload');

        final mensagemResponse = await http.post(
          Uri.parse('https://mobile.amttdetra.com/api/mensagens'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${await _getAuthToken()}',
          },
          body: json.encode(messagePayload),
        );

        print(
            'Status Code da criação da mensagem: ${mensagemResponse.statusCode}');
        print('Resposta da criação da mensagem: ${mensagemResponse.body}');

        if (mensagemResponse.statusCode == 201) {
          // Redireciona para a tela de detalhes da solicitação
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetalhesSolicitacao(
                solicitacaoId: chatId.toString(),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Erro ao enviar mensagem: ${mensagemResponse.statusCode}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao criar chat: ${chatResponse.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              './images/appbar_logo.png', // Coloque o caminho correto do logo aqui
              height: 30,
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                // Ação para o ícone de conta (se necessário)
              },
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Cor branca
          onPressed: () {
            Navigator.of(context).pop(); // Volta para a tela anterior
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Tipo de Solicitação',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              value: selectedSolicitationType,
              items: ['horario', 'linha', 'sugestão', 'outros']
                  .map((label) => DropdownMenuItem(
                        child: Text(label),
                        value: label,
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedSolicitationType = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            FutureBuilder<List>(
              future: itinerariosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar as linhas');
                } else if (snapshot.hasData) {
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Selecione a linha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    value: selectedLine,
                    items: _menuItems(snapshot.data!),
                    onChanged: (value) {
                      setState(() {
                        selectedLine = value;
                      });
                    },
                  );
                } else {
                  return Text('Nenhuma linha disponível');
                }
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Assunto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _messageController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Mensagem...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitRequest,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Colors.teal, // Cor do botão
              ),
              child: Text(
                'Enviar Solicitação',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
