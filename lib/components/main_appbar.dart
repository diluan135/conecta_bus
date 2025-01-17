import 'package:flutter/material.dart';

class MainAppBar extends AppBar {
  MainAppBar({super.key});

  @override
  State<MainAppBar> createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      title: GestureDetector(
        onTap: () => ModalRoute.of(context)?.settings.name == "/home"
            ? null
            : Navigator.pop(context),
        child: Image(
          image: const AssetImage("images/appbar_logo.png"),
          width: MediaQuery.of(context).size.width / 1.9,
        ),
      ),
      foregroundColor: Colors.white,
    );
  }
}
