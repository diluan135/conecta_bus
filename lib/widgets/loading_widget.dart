import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Image(
      image: AssetImage("images/loading.gif"),
      height: 124,
      width: 124,
    ));
  }
}
