import 'package:flutter/material.dart';

import 'core/auth/auth_guard.dart';
import 'core/auth/auth_state.dart';
import 'core/auth/me_response.dart';
import 'core/auth/session_storage.dart';
import 'core/auth/tenant_resolver.dart';
import 'core/network/api_client.dart';
import 'core/auth/auth_service.dart';
import 'core/ui/app_scaffold.dart';

import 'features/auth/pages/login_page.dart';
import 'features/dashboard_empresa/pages/home_empresa_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = SessionStorage();

  bool booting = true;
  EmpresaSession? session;
  MeResponse? me;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => booting = true);

    final token = await storage.getToken();
    if (token == null) {
      setState(() {
        session = null;
        me = null;
        booting = false;
      });
      return;
    }

    try {
      final api = ApiClient(token: token);
      final auth = AuthService(api);

      final meRes = await auth.me();
      final tenant = resolveTenant(meRes);

      setState(() {
        me = meRes;
        session = EmpresaSession(
          token: token,
          tenantLabel: tenant.tenantLabel,
          tenantNombre: tenant.tenantNombre, // placeholder por ahora
          userNombre: meRes.nombreCompleto,
          userEmail: meRes.email,
          rol: tenant.rol,
          scopeTipo: tenant.scopeTipo,
          scopeId: tenant.scopeId,
        );
        booting = false;
      });
    } catch (_) {
      await storage.clear();
      setState(() {
        session = null;
        me = null;
        booting = false;
      });
    }
  }

  Future<void> _onLoggedIn(String token, MeResponse meRes) async {
    await storage.saveToken(token);

    final tenant = resolveTenant(meRes);

    setState(() {
      me = meRes;
      session = EmpresaSession(
        token: token,
        tenantLabel: tenant.tenantLabel,
        tenantNombre: tenant.tenantNombre, // placeholder por ahora
        userNombre: meRes.nombreCompleto,
        userEmail: meRes.email,
        rol: tenant.rol,
        scopeTipo: tenant.scopeTipo,
        scopeId: tenant.scopeId,
      );
    });
  }

  Future<void> _logout() async {
    await storage.clear();
    setState(() {
      session = null;
      me = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADAdmin',
      debugShowCheckedModeBanner: false,
      home: booting
          ? const _Splash()
          : (session == null
                ? LoginPage(onLoggedIn: _onLoggedIn)
                : AuthGuard(
                    session: session,
                    child: AppScaffold(
                      session: session!,
                      current: EmpresaNavItem.home,
                      onSelect: (_) {},
                      onLogout: _logout, // ✅ ahora centralizado
                      child: HomeEmpresaPage(session: session!),
                    ),
                  )),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
