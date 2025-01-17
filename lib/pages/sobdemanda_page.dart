import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SobDemanda extends StatelessWidget {
  const SobDemanda({Key? key}) : super(key: key);

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
        title: const Text('Página SobDemanda'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context), // Chama a função de logout
          ),
        ],
      ),
      body: Center(
        child: Text('Conteúdo da Página SobDemanda'),
      ),
    );
  }
}
