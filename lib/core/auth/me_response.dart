class MeResponse {
  final String id;
  final String email;
  final String estado;

  final String? personaId;
  final String? nombres;
  final String? apellidos;
  final String? iglesiaId;

  final List<Asignacion> asignaciones;

  MeResponse({
    required this.id,
    required this.email,
    required this.estado,
    required this.personaId,
    required this.nombres,
    required this.apellidos,
    required this.iglesiaId,
    required this.asignaciones,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final persona = data['persona'];

    final List<dynamic> asigs = (data['asignaciones'] as List?) ?? [];

    return MeResponse(
      id: (data['id'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      estado: (data['estado'] ?? '').toString(),
      personaId: persona == null ? null : persona['id']?.toString(),
      nombres: persona == null ? null : persona['nombres']?.toString(),
      apellidos: persona == null ? null : persona['apellidos']?.toString(),
      iglesiaId: persona == null ? null : persona['iglesiaId']?.toString(),
      asignaciones: asigs.map((e) => Asignacion.fromJson(e)).toList(),
    );
  }

  String get nombreCompleto {
    final n = (nombres ?? '').trim();
    final a = (apellidos ?? '').trim();
    return ('$n $a').trim().isEmpty ? email : ('$n $a').trim();
  }

  /// ✅ rol principal (ej: PRESIDENTE_ASOCIACION, SECRETARIO_IGLESIA, etc.)
  String? get rolPrincipal {
    if (asignaciones.isEmpty) return null;

    // Prioridad sugerida: ASOCIACION > DISTRITO > IGLESIA (ajusta como quieras)
    const prioridad = {
      'EMPRESA': 0,
      'PAIS': 1,
      'UNION': 2,
      'ASOCIACION': 3,
      'DISTRITO': 4,
      'IGLESIA': 5,
    };

    asignaciones.sort((a, b) {
      final pa = prioridad[a.scopeTipo] ?? 999;
      final pb = prioridad[b.scopeTipo] ?? 999;
      return pa.compareTo(pb);
    });

    return asignaciones.first.rolNombre;
  }
}

class Asignacion {
  final String scopeTipo;
  final String scopeId;
  final String rolNombre;

  Asignacion({
    required this.scopeTipo,
    required this.scopeId,
    required this.rolNombre,
  });

  factory Asignacion.fromJson(Map<String, dynamic> json) {
    final rol = json['rol'] ?? {};
    return Asignacion(
      scopeTipo: (json['scopeTipo'] ?? '').toString(),
      scopeId: (json['scopeId'] ?? '').toString(),
      rolNombre: (rol['nombre'] ?? '').toString(),
    );
  }
}
