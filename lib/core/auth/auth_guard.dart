import 'package:flutter/material.dart';
import 'auth_state.dart';

class AuthGuard extends StatelessWidget {
  final EmpresaSession? session;
  final Widget child;

  const AuthGuard({super.key, required this.session, required this.child});

  @override
  Widget build(BuildContext context) {
    if (session == null || session!.token.isEmpty) {
      // Si no hay sesión, mandamos al login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return child;
  }
}
