import 'me_response.dart';

class TenantInfo {
  final String scopeTipo;
  final String scopeId;
  final String rol;
  final String tenantLabel;
  final String tenantNombre; // por ahora placeholder

  TenantInfo({
    required this.scopeTipo,
    required this.scopeId,
    required this.rol,
    required this.tenantLabel,
    required this.tenantNombre,
  });
}

TenantInfo resolveTenant(MeResponse me) {
  if (me.asignaciones.isEmpty) {
    return TenantInfo(
      scopeTipo: 'EMPRESA',
      scopeId: '',
      rol: 'SIN_ROL',
      tenantLabel: 'Panel',
      tenantNombre: 'ADAdmin',
    );
  }

  const prioridad = <String, int>{
    'EMPRESA': 0,
    'PAIS': 1,
    'UNION': 2,
    'ASOCIACION': 3,
    'DISTRITO': 4,
    'IGLESIA': 5,
  };

  final sorted = [...me.asignaciones];
  sorted.sort((a, b) {
    final pa = prioridad[a.scopeTipo] ?? 999;
    final pb = prioridad[b.scopeTipo] ?? 999;
    return pa.compareTo(pb);
  });

  final main = sorted.first;

  return TenantInfo(
    scopeTipo: main.scopeTipo,
    scopeId: main.scopeId,
    rol: main.rolNombre,
    tenantLabel: main.scopeTipo,
    tenantNombre: main.scopeTipo, // placeholder hasta traer el nombre real
  );
}
