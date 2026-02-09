import 'package:flutter/material.dart';
import '../auth/auth_state.dart';

enum EmpresaNavItem { home, estructura, usuarios, suscripcion, reportes }

class AppScaffold extends StatelessWidget {
  final EmpresaSession session;
  final EmpresaNavItem current;
  final Widget child;
  final ValueChanged<EmpresaNavItem> onSelect;

  const AppScaffold({
    super.key,
    required this.session,
    required this.current,
    required this.child,
    required this.onSelect,
  });

  String _title(EmpresaNavItem item) {
    switch (item) {
      case EmpresaNavItem.home:
        return 'Inicio';
      case EmpresaNavItem.estructura:
        return 'Estructura';
      case EmpresaNavItem.usuarios:
        return 'Usuarios';
      case EmpresaNavItem.suscripcion:
        return 'Suscripción';
      case EmpresaNavItem.reportes:
        return 'Reportes';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    final menuItems = <EmpresaNavItem>[
      EmpresaNavItem.home,
      EmpresaNavItem.estructura,
      EmpresaNavItem.usuarios,
      EmpresaNavItem.suscripcion,
      EmpresaNavItem.reportes,
    ];

    Widget buildDrawer() {
      return Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.business)),
                title: Text(
                  session.empresaNombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Panel Empresa'),
              ),
              const Divider(),
              ...menuItems.map((item) {
                final selected = item == current;
                return ListTile(
                  selected: selected,
                  leading: Icon(_iconFor(item)),
                  title: Text(_title(item)),
                  onTap: () {
                    Navigator.pop(context);
                    onSelect(item);
                  },
                );
              }),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () {
                  // luego conectamos logout real
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (_) => false);
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ADAdmin • ${session.empresaNombre}'),
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'account', child: Text('Mi cuenta')),
              PopupMenuItem(value: 'security', child: Text('Seguridad')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(child: Icon(Icons.person)),
            ),
          ),
        ],
      ),

      drawer: isWide ? null : buildDrawer(),

      body: Row(
        children: [
          if (isWide) SizedBox(width: 280, child: buildDrawer()),
          Expanded(child: child),
        ],
      ),

      // En móvil, bottom bar tipo “Instagram”
      bottomNavigationBar: isWide
          ? null
          : BottomNavigationBar(
              currentIndex: menuItems.indexOf(current),
              onTap: (i) => onSelect(menuItems[i]),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_tree),
                  label: 'Estructura',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'Usuarios',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.credit_card),
                  label: 'Plan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Reportes',
                ),
              ],
            ),
    );
  }

  IconData _iconFor(EmpresaNavItem item) {
    switch (item) {
      case EmpresaNavItem.home:
        return Icons.home;
      case EmpresaNavItem.estructura:
        return Icons.account_tree;
      case EmpresaNavItem.usuarios:
        return Icons.group;
      case EmpresaNavItem.suscripcion:
        return Icons.credit_card;
      case EmpresaNavItem.reportes:
        return Icons.bar_chart;
    }
  }
}
