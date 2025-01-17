import 'package:flutter/material.dart';
import 'package:horarios_transporte/components/main_appbar.dart';
import 'package:horarios_transporte/components/perigo_button.dart';
import 'package:horarios_transporte/widgets/ajuda_main.dart';

class AjudaPage extends StatelessWidget {
  const AjudaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      body: const AjudaWidget(),
      floatingActionButton: const PerigoFloatingButton(),
    );
  }
}
