class DashboardSuscripciones {
  final int activaCount;
  final int suspendidaCount;
  final int porVencer7dias;
  final int porVencer30dias;
  final List<ProximaRenovacion> topProximas;

  const DashboardSuscripciones({
    required this.activaCount,
    required this.suspendidaCount,
    required this.porVencer7dias,
    required this.porVencer30dias,
    required this.topProximas,
  });

  factory DashboardSuscripciones.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? json) as Map<String, dynamic>;

    final list = (data['topProximas'] as List? ?? [])
        .map((e) => ProximaRenovacion.fromMap(e as Map<String, dynamic>))
        .toList();

    return DashboardSuscripciones(
      activaCount: (data['activaCount'] ?? 0) as int,
      suspendidaCount: (data['suspendidaCount'] ?? 0) as int,
      porVencer7dias: (data['porVencer7dias'] ?? 0) as int,
      porVencer30dias: (data['porVencer30dias'] ?? 0) as int,
      topProximas: list,
    );
  }
}

class ProximaRenovacion {
  final String id;
  final String nombre;
  final String planFase;
  final String tipoSuscripcion;
  final String estadoSuscripcion;
  final DateTime renovacionFecha;

  // opcional: union / pais si lo estás enviando
  final String? unionNombre;
  final String? paisNombre;

  const ProximaRenovacion({
    required this.id,
    required this.nombre,
    required this.planFase,
    required this.tipoSuscripcion,
    required this.estadoSuscripcion,
    required this.renovacionFecha,
    this.unionNombre,
    this.paisNombre,
  });

  factory ProximaRenovacion.fromMap(Map<String, dynamic> m) {
    final union = m['union'] as Map<String, dynamic>?;
    final pais = union?['pais'] as Map<String, dynamic>?;

    return ProximaRenovacion(
      id: (m['id'] ?? '') as String,
      nombre: (m['nombre'] ?? '') as String,
      planFase: (m['planFase'] ?? '') as String,
      tipoSuscripcion: (m['tipoSuscripcion'] ?? '') as String,
      estadoSuscripcion: (m['estadoSuscripcion'] ?? '') as String,
      renovacionFecha: DateTime.parse(m['renovacionFecha'] as String),
      unionNombre: union?['nombre'] as String?,
      paisNombre: pais?['nombre'] as String?,
    );
  }
}
