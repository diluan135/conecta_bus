// lib/pages/registro_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:email_validator/email_validator.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                children: [
                  SizedBox(height: 20.0),
                  Text(
                    'REGISTRE-SE',
                    style:
                        TextStyle(fontSize: 60.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 250.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildTextField(_nameController, 'Nome', Icons.person),
                      _buildTextField(
                          _sobrenomeController, 'Sobrenome', Icons.person),
                      _buildTextField(
                        _cpfController,
                        'CPF',
                        Icons.person,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TextInputFormatter.withFunction(
                            (oldValue, newValue) {
                              return TextEditingValue(
                                text: CPFValidator.format(newValue.text),
                                selection: TextSelection.collapsed(
                                  offset:
                                      CPFValidator.format(newValue.text).length,
                                ),
                              );
                            },
                          ),
                        ],
                        validator: (value) {
                          if (value == null || !CPFValidator.isValid(value)) {
                            return 'CPF inválido';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(_emailController, 'Email', Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                        if (value == null || !EmailValidator.validate(value)) {
                          return 'Email inválido';
                        }
                        return null;
                      }),
                      _buildTextField(_passwordController, 'Senha', Icons.lock,
                          obscureText: true),
                      _buildTextField(_confirmPasswordController,
                          'Confirmar senha', Icons.lock, obscureText: true,
                          validator: (value) {
                        if (value != _passwordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      }),
                      _buildCheckbox(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32.0, vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: Text('Registrar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text,
      List<TextInputFormatter>? inputFormatters,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: Colors.grey[300],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Informe o $label';
              }
              return null;
            },
      ),
    );
  }

  Widget _buildCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
      child: Row(
        children: [
          Checkbox(
            value: _agreeToTerms,
            onChanged: (newValue) {
              setState(() {
                _agreeToTerms = newValue!;
              });
            },
          ),
          Expanded(
            child: Text(
              'Concordo com os Termos e Condições',
              style: TextStyle(fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      final formattedCpf = CPFValidator.format(_cpfController.text);

      final data = {
        'name': _nameController.text,
        'sobrenome': _sobrenomeController.text,
        'CPF': formattedCpf,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
      };

      print('Enviando dados para o backend: ${json.encode(data)}');

      final url =
          'https://mobile.amttdetra.com/api/register'; // Substitua com a URL correta do seu backend

      try {
        Dio dio = Dio();
        final response = await dio.post(
          url,
          options: Options(headers: {'Content-Type': 'application/json'}),
          data: json.encode(data),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registro realizado com sucesso!')),
          );
          // Navegar para a tela inicial e remover todas as páginas anteriores
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: ${response.data['message']}')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro inesperado: $error')),
        );
      }
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Você deve concordar com os Termos e Condições')),
      );
    }
  }
}
