import 'package:flutter/material.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/network/api_client.dart';

import '../models/dashboard_resumen.dart';
import '../models/dashboard_suscripciones.dart';
import '../services/dashboard_empresa_service.dart';
import '../widgets/suscripciones_section.dart';

class HomeEmpresaPage extends StatefulWidget {
  final EmpresaSession session;
  const HomeEmpresaPage({super.key, required this.session});

  @override
  State<HomeEmpresaPage> createState() => _HomeEmpresaPageState();
}

class _HomeEmpresaPageState extends State<HomeEmpresaPage> {
  late DashboardEmpresaService service;
  late Future<List<dynamic>>
  futureAll; // [DashboardResumen, DashboardSuscripciones]

  @override
  void initState() {
    super.initState();

    final api = ApiClient(token: widget.session.token);
    service = DashboardEmpresaService(api);

    _load();
  }

  void _load() {
    futureAll = Future.wait<dynamic>([
      service.fetchResumen(),
      service.fetchSuscripciones(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Breakpoints
    final isTablet = width >= 600 && width < 1024;
    final isDesktop = width >= 1024;

    final padding = isDesktop
        ? const EdgeInsets.all(24)
        : (isTablet ? const EdgeInsets.all(20) : const EdgeInsets.all(16));

    // Limitar ancho en PC para que no se “estire infinito”
    const maxContentWidth = 1280.0;

    // Tamaño de cards por dispositivo
    final maxCardWidth = isDesktop ? 240.0 : (isTablet ? 260.0 : 320.0);
    final aspectRatio = isDesktop ? 2.4 : (isTablet ? 2.15 : 1.9);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dashboard Empresa',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Resumen general del sistema',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        FutureBuilder<List<dynamic>>(
          future: futureAll,
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
                onRetry: () => setState(_load),
              );
            }

            final list = snapshot.data!;
            final resumen = list[0] as DashboardResumen;
            final suscripciones = list[1] as DashboardSuscripciones;

            final kpiItems = <_KpiItem>[
              _KpiItem('Países', resumen.paises, Icons.public),
              _KpiItem('Uniones', resumen.uniones, Icons.hub),
              _KpiItem(
                'Asociaciones',
                resumen.asociaciones,
                Icons.account_balance,
              ),
              _KpiItem('Distritos', resumen.distritos, Icons.account_tree),
              _KpiItem('Iglesias', resumen.iglesias, Icons.church),
              _KpiItem('Miembros', resumen.miembros, Icons.people),
              _KpiItem('Usuarios', resumen.usuarios, Icons.person),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== KPIs =====
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: isDesktop
                        ? 230
                        : (isTablet ? 260 : 320),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: kpiItems.length,
                  itemBuilder: (_, i) {
                    final it = kpiItems[i];
                    return _KpiCard(it.title, it.value, it.icon);
                  },
                ),

                // ===== Suscripción =====
                const SizedBox(height: 22),
                SuscripcionesSection(data: suscripciones),
              ],
            );
          },
        ),
      ],
    );

    return SingleChildScrollView(
      padding: padding,
      child: isDesktop
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxContentWidth),
                child: content,
              ),
            )
          : content,
    );
  }
}

// ====== Models UI helpers ======

class _KpiItem {
  final String title;
  final int value;
  final IconData icon;
  _KpiItem(this.title, this.value, this.icon);
}

class _KpiCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;

  const _KpiCard(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final iconSize = isMobile ? 18.0 : (isTablet ? 20.0 : 18.0);
    final numberSize = isMobile ? 18.0 : (isTablet ? 20.0 : 18.0);
    final labelSize = isMobile ? 12.0 : 12.0;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          10,
          12,
          8,
        ), // ✅ menos padding abajo
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:
              MainAxisSize.min, // ✅ clave para no “pedir” altura infinita
          children: [
            Icon(icon, size: iconSize, color: Theme.of(context).primaryColor),

            const SizedBox(height: 6),

            Text(
              value.toString(),
              style: TextStyle(
                fontSize: numberSize,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),

            const SizedBox(height: 2),

            // ✅ Evita overflow en labels largos
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: labelSize,
                color: Colors.grey.shade600,
                height: 1.1,
              ),
            ),

            // ✅ Este Spacer empuja el contenido arriba SOLO si hay espacio,
            // y no fuerza overflow como Expanded anidado
            const Spacer(),
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
            Text(message, style: const TextStyle(color: Colors.grey)),
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
