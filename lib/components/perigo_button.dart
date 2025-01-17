import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

class PerigoFloatingButton extends StatelessWidget {
  const PerigoFloatingButton({super.key});

  Future<void> _openExternalApp() async {
    await launchUrl(Uri.parse("tel://153"));
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async => await confirm(
        context,
        content: const Text(
          "Ligar para Guarda Civil Municipal (GCM) ?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        textOK: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 44,
        ),
        textCancel: const Icon(
          Icons.cancel,
          color: Colors.red,
          size: 44,
        ),
      )
          ? _openExternalApp()
          : null,
      tooltip: 'Botão emergência',
      backgroundColor: const Color.fromRGBO(225, 24, 4, 1),
      child: const Icon(
        Icons.phone_in_talk,
        size: 38,
      ),
    );
  }
}
