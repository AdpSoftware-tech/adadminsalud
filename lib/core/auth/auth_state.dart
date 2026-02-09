class EmpresaSession {
  final String token;

  // ✅ Header izquierdo (tenant)
  final String tenantLabel; // Ej: "ASOCIACION"
  final String tenantNombre; // Ej: "Asociación Central"

  // ✅ Usuario logueado
  final String userNombre; // "Celso Gamboa"
  final String userEmail; // "presidente.celso@iglesia.org"
  final String rol; // "PRESIDENTE_ASOCIACION"

  // ✅ Para filtrar dashboard luego
  final String scopeTipo; // "ASOCIACION"
  final String scopeId; // "f3e98b6f-..."

  EmpresaSession({
    required this.token,
    required this.tenantLabel,
    required this.tenantNombre,
    required this.userNombre,
    required this.userEmail,
    required this.rol,
    required this.scopeTipo,
    required this.scopeId,
  });
}
