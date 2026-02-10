import 'package:flutter/material.dart';
import '../models/dashboard_suscripciones.dart';

class SuscripcionesSection extends StatelessWidget {
  final DashboardSuscripciones data;
  const SuscripcionesSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Breakpoints simples
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;
    final isDesktop = width >= 1024;

    // Columnas de KPIs según dispositivo
    final kpiColumns = isDesktop ? 4 : (isTablet ? 3 : 2);

    // Tabla solo en pantallas grandes (se ve mejor)
    final showTable = width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suscripción',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),

        // ===== KPIs (compactos) =====
        LayoutBuilder(
          builder: (context, c) {
            const spacing = 12.0;
            final totalSpacing = spacing * (kpiColumns - 1);

            // ancho por card, con límites para que no se “inflen” en desktop
            final itemW = ((c.maxWidth - totalSpacing) / kpiColumns).clamp(
              isDesktop ? 220.0 : 200.0, // min
              isDesktop ? 240.0 : double.infinity, // max
            );

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemW,
                  child: _KpiCard(
                    icon: Icons.verified_outlined,
                    title: 'Activas',
                    value: data.activaCount,
                    subtitle: 'Asociaciones',
                  ),
                ),
                SizedBox(
                  width: itemW,
                  child: _KpiCard(
                    icon: Icons.pause_circle_outline,
                    title: 'Suspendidas',
                    value: data.suspendidaCount,
                    subtitle: 'Asociaciones',
                  ),
                ),
                SizedBox(
                  width: itemW,
                  child: _KpiCard(
                    icon: Icons.timer_outlined,
                    title: 'Vence (7d)',
                    value: data.porVencer7dias,
                    subtitle: 'Activas',
                  ),
                ),
                SizedBox(
                  width: itemW,
                  child: _KpiCard(
                    icon: Icons.event_outlined,
                    title: 'Vence (30d)',
                    value: data.porVencer30dias,
                    subtitle: 'Activas',
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 18),

        // ===== Próximas renovaciones =====
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
            boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Próximas renovaciones',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              if (data.topProximas.isEmpty)
                const Text('Sin datos por ahora.')
              else if (showTable)
                _TableWide(items: data.topProximas)
              else
                _ListMobile(items: data.topProximas),

              const SizedBox(height: 6),

              if (isMobile)
                Text(
                  'Tip: en pantallas grandes verás la tabla completa.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===== KPI CARD (compacta y consistente) =====

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;
  final String subtitle;

  const _KpiCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    final iconSize = isMobile ? 18.0 : 20.0;
    final numberSize = isMobile ? 18.0 : 20.0;
    final titleSize = isMobile ? 13.0 : 14.0;
    final subtitleSize = 12.0;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 🔑 evita altura fija
          children: [
            Icon(icon, size: iconSize, color: Theme.of(context).primaryColor),
            const SizedBox(height: 6),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: numberSize,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: subtitleSize,
                color: Colors.grey.shade600,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== LIST (mobile/tablet) =====

class _ListMobile extends StatelessWidget {
  final List<ProximaRenovacion> items;
  const _ListMobile({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              e.nombre,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${e.planFase} • ${e.tipoSuscripcion} • ${_fmtDate(e.renovacionFecha)}',
            ),
            trailing: _EstadoChip(estado: e.estadoSuscripcion),
          ),
        );
      }).toList(),
    );
  }
}

// ===== TABLE (desktop) =====

class _TableWide extends StatelessWidget {
  final List<ProximaRenovacion> items;
  const _TableWide({required this.items});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.6),
        1: FlexColumnWidth(1.2),
        2: FlexColumnWidth(1.2),
        3: FlexColumnWidth(1.4),
        4: FlexColumnWidth(1.2),
      },
      children: [
        _rowHeader(['Asociación', 'Plan', 'Tipo', 'Renovación', 'Estado']),
        ...items.map((e) {
          return _row([
            e.nombre,
            e.planFase,
            e.tipoSuscripcion,
            _fmtDate(e.renovacionFecha),
            e.estadoSuscripcion,
          ]);
        }),
      ],
    );
  }

  TableRow _rowHeader(List<String> cells) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.04)),
      children: cells
          .map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Text(
                c,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _row(List<String> cells) {
    return TableRow(
      children: cells
          .map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Text(c),
            ),
          )
          .toList(),
    );
  }
}

// ===== Estado Chip =====

class _EstadoChip extends StatelessWidget {
  final String estado;
  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    final isActiva = estado.toUpperCase().contains('ACTIVA');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActiva
            ? Colors.green.withOpacity(0.12)
            : Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActiva
              ? Colors.green.withOpacity(0.35)
              : Colors.red.withOpacity(0.35),
        ),
      ),
      child: Text(
        estado,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isActiva ? Colors.green.shade800 : Colors.red.shade800,
        ),
      ),
    );
  }
}

String _fmtDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}
