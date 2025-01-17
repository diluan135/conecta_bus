import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nova_solicitacao.dart'; // Importando a tela de Nova Solicitação
import 'minhas_solicitacoes.dart'; // Importando a tela de Minhas Solicitações
import 'enquetes_page.dart'; // Importando a tela de Enquetes (Perguntas Frequentes)

class PaginaEscuta extends StatelessWidget {
  const PaginaEscuta({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Remove o token armazenado
    Navigator.pushReplacementNamed(
        context, '/login'); // Redireciona para a página de login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Escuta'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context), // Chama a função de logout
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOptionButton(
              context,
              title: 'Nova Solicitação',
              color: Colors.teal,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NovaSolicitacao(), // Navega para Nova Solicitação
                  ),
                );
              },
            ),
            SizedBox(height: 16.0),
            _buildOptionButton(
              context,
              title: 'Minhas Solicitações',
              color: Colors.cyan,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MinhasSolicitacoes(), // Navega para Minhas Solicitações
                  ),
                );
              },
            ),
            SizedBox(height: 16.0),
            _buildOptionButton(
              context,
              title: 'Perguntas Frequentes',
              color: Colors.tealAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EnquetesPage(), // Navega para EnquetesPage (Perguntas Frequentes)
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context,
      {required String title,
      required Color color,
      required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          backgroundColor: color, // Cor do botão
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
