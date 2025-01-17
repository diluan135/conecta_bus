import 'package:flutter/material.dart';

class AjudaWidget extends StatelessWidget {
  const AjudaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const <Widget>[
        Text("Quem somos ? ",
            style: TextStyle(
                fontFamily: 'Custom',
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Divider(color: Colors.transparent),
        Text(
            "Somos do departamento de transporte de Ponta Grossa, e desenvolvemos o aplicativo CONECTA BUS com o objetivo de facilitar o acesso às informações referente ao transporte público, como horários, alterações em rotas e pontos de ônibus."),
        Divider(),
        Divider(color: Colors.transparent),
        Text("Sobre o aplicativo",
            style: TextStyle(
                fontFamily: 'Custom',
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Divider(color: Colors.transparent),
        Text(
            "O aplicativo visa criar uma conexão direta com o usuário do transporte coletivo, entregando ao usuário informações de horários, pontos de parada do transporte e informações quando horários ou rotas sejam alteradas."),
        Text(
            "Para a criação do aplicativo fora usado software de terceiros, e isso pode fazer com que o aplicativo apresente anúncios. A prefeitura de Ponta Grossa e o departamento de transporte não possuem conexão ou relação contratual com os anunciantes."),
        Divider(),
        Divider(color: Colors.transparent),
        Divider(color: Colors.transparent),
        Text("Dúvidas",
            style: TextStyle(
                fontFamily: 'Custom',
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Divider(color: Colors.transparent),
        Text(
            "Em caso de outras dúvidas a respeito do aplicativo o usuário pode entrar em contato com o Departamento de Transporte(DETRA) por meio do e-mail departamentotransportes@gmail.com"),
        Divider(),
        Divider(color: Colors.transparent),
        Text("Desenvolvido por Diluan Lima de Matos e Lucas Gabriel Ramão",
            style: TextStyle(
                fontFamily: 'Custom',
                fontSize: 8,
                color: Color.fromARGB(255, 151, 151, 151),
                fontWeight: FontWeight.bold)),
        Divider(),
      ],
    );
  }
}
