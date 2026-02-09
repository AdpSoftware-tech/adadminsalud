import 'package:flutter/material.dart';
import '../../dashboard_empresa/services/dashboard_empresa_service.dart';
import '../../../core/auth/auth_state.dart';
import '../models/dashboard_resumen.dart';
import '../../../core/network/api_client.dart';

class HomeEmpresaPage extends StatefulWidget {
  final EmpresaSession session;
  const HomeEmpresaPage({super.key, required this.session});

  @override
  State<HomeEmpresaPage> createState() => _HomeEmpresaPageState();
}

class _HomeEmpresaPageState extends State<HomeEmpresaPage> {
  late DashboardEmpresaService service;
  late Future<DashboardResumen> futureResumen;

  @override
  void initState() {
    super.initState();

    // ✅ ApiClient YA trae baseUrl desde AppConfig
    final api = ApiClient(token: widget.session.token);

    service = DashboardEmpresaService(api);
    futureResumen = service.fetchResumen();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Empresa',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Resumen general del sistema',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          FutureBuilder<DashboardResumen>(
            future: futureResumen,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return _ErrorBox(
                  message: snapshot.error.toString(),
                  onRetry: () {
                    setState(() {
                      futureResumen = service.fetchResumen();
                    });
                  },
                );
              }

              final d = snapshot.data!;

              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _KpiCard('Países', d.paises, Icons.public),
                  _KpiCard('Uniones', d.uniones, Icons.hub),
                  _KpiCard(
                    'Asociaciones',
                    d.asociaciones,
                    Icons.account_balance,
                  ),
                  _KpiCard('Distritos', d.distritos, Icons.account_tree),
                  _KpiCard('Iglesias', d.iglesias, Icons.church),
                  _KpiCard('Miembros', d.miembros, Icons.people),
                  _KpiCard('Usuarios', d.usuarios, Icons.person),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ====== UI helpers ======

class _KpiCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;

  const _KpiCard(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26, color: Theme.of(context).primaryColor),
            const Spacer(),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No se pudo cargar el dashboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
