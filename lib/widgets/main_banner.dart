import 'package:flutter/material.dart';

class MainBanner extends StatelessWidget {
  const MainBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width - 20,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(10),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Linhas Favoritas",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Divider(),
          ],
        ));
  }
}
