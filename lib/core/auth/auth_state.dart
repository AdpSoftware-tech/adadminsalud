class EmpresaSession {
  final String token;
  final String empresaNombre;

  // luego agregamos:
  // final List<String> permissions;
  // final List<String> modules;

  EmpresaSession({required this.token, required this.empresaNombre});
}
