import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class LoginPage extends StatefulWidget {
  final String? nextRoute;

  const LoginPage({Key? key, this.nextRoute}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  final dio = Dio();

  final cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final String _secretKey =
      'your_secret_key'; // Substitua pela sua chave secreta

  Future<void> _login() async {
    final String cpf =
        cpfFormatter.getUnmaskedText(); // Obtém o CPF sem máscara
    final String password = _passwordController.text.trim();

    if (cpf.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    try {
      final response = await dio.post(
        'https://mobile.amttdetra.com/api/login',
        data: {
          'CPF': cpf, // Envia o CPF sem máscara
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['message'] == 'Login bem-sucedido') {
          final token = _generateToken(cpf);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('user_id',
              data['user_id'].toString()); // Armazenar o ID do usuário

          print('Token armazenado: $token');
          print('ID do usuário armazenado: ${data['user_id']}');

          Navigator.pushReplacementNamed(
            context,
            widget.nextRoute ?? '/home', // Usa a rota fornecida ou a padrão
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Erro desconhecido')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de servidor: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    }
  }

  String _generateToken(String cpf) {
    final expirationTime =
        DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch;

    final jwt = JWT(
      {
        'cpf': cpf,
        'iat': DateTime.now().millisecondsSinceEpoch,
        'exp': expirationTime, // Expiração manual
      },
    );

    return jwt.sign(SecretKey(_secretKey));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _cpfController,
              inputFormatters: [cpfFormatter],
              decoration: const InputDecoration(
                labelText: 'CPF',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Não tem uma conta? Registre-se aqui'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
