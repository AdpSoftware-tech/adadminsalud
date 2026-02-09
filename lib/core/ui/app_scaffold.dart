import 'package:flutter/material.dart';
import '../auth/auth_state.dart';

enum EmpresaNavItem { home, estructura, usuarios, suscripcion, reportes }

class AppScaffold extends StatelessWidget {
  final EmpresaSession session;
  final EmpresaNavItem current;
  final Widget child;
  final ValueChanged<EmpresaNavItem> onSelect;

  // ✅ nuevo: logout real desde main
  final VoidCallback onLogout;

  const AppScaffold({
    super.key,
    required this.session,
    required this.current,
    required this.child,
    required this.onSelect,
    required this.onLogout,
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
                  session.tenantNombre, // ✅ antes: empresaNombre
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${session.tenantLabel} • ${session.rol}'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.userNombre,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            session.userEmail,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                onTap: onLogout, // ✅ ahora es real
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ADAdmin • ${session.tenantNombre}'),
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') onLogout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'account', child: Text('Mi cuenta')),
              PopupMenuItem(value: 'security', child: Text('Seguridad')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                child: Text(
                  session.userNombre.isNotEmpty
                      ? session.userNombre[0].toUpperCase()
                      : 'U',
                ),
              ),
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
