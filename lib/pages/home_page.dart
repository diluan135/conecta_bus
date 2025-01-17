import 'package:flutter/material.dart';
import 'package:horarios_transporte/components/main_appbar.dart';
import 'package:horarios_transporte/components/perigo_button.dart';
import 'package:horarios_transporte/widgets/footer_widget.dart';
import 'package:horarios_transporte/widgets/main_cards.dart';
import 'package:horarios_transporte/components/main_header.dart';
import 'package:horarios_transporte/widgets/main_banner.dart';
import 'package:horarios_transporte/components/main_lista_favoritos.dart';

// Caso esteja procurando, o card informando atualizações está no main_cards.dart

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: MainAppBar(),
      body: NotificationListener<ScrollEndNotification>(
        onNotification: (notification) {
          setState(() {});
          return true;
        },
        child: ListView(
          children: <Widget>[
            const MainHeader(),
            const Divider(color: Colors.transparent),
            const MainCards(), // Garante que este widget foi revisado corretamente
            const MainBanner(),
            MainListaFavoritos(),
            const FooterWidget()
          ],
        ),
      ),
      floatingActionButton: const PerigoFloatingButton(),
    );
  }
}
