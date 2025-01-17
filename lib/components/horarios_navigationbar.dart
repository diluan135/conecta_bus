import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horarios_transporte/controllers/horarios_controller.dart';

class HorariosNavigationBar extends StatefulWidget {
  const HorariosNavigationBar({super.key});

  @override
  State<HorariosNavigationBar> createState() => _HorariosNavigationBarState();
}

class _HorariosNavigationBarState extends State<HorariosNavigationBar> {
  HorariosController hController = Get.find();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: const Color.fromARGB(255, 57, 148, 204),
      currentIndex: hController.reverseDia(),
      onTap: (value) {
        setState(() {
          hController.setDia(value);
        });
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            label: "Dia útil", icon: Icon(Icons.work_rounded)),
        BottomNavigationBarItem(
            label: "Sábado", icon: Icon(Icons.people_alt_rounded)),
        BottomNavigationBarItem(
            label: "Domingo", icon: Icon(Icons.wb_sunny_rounded))
      ],
    );
  }
}
