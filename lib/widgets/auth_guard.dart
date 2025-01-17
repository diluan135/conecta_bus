// lib/widgets/auth_guard.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final String redirectRoute;

  const AuthGuard({Key? key, required this.child, required this.redirectRoute})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.data == true) {
          return child;
        } else {
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, redirectRoute);
          });
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<bool> _isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null;
  }
}
