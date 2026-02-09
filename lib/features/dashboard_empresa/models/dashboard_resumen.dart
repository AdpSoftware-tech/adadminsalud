class DashboardResumen {
  final int empresas;
  final int paises;
  final int uniones;
  final int asociaciones;
  final int distritos;
  final int iglesias;
  final int miembros;
  final int usuarios;

  const DashboardResumen({
    required this.empresas,
    required this.paises,
    required this.uniones,
    required this.asociaciones,
    required this.distritos,
    required this.iglesias,
    required this.miembros,
    required this.usuarios,
  });

  factory DashboardResumen.fromJson(Map<String, dynamic> json) {
    int n(String k) => (json[k] ?? 0) as int;
    return DashboardResumen(
      empresas: n('empresas'),
      paises: n('paises'),
      uniones: n('uniones'),
      asociaciones: n('asociaciones'),
      distritos: n('distritos'),
      iglesias: n('iglesias'),
      miembros: n('miembros'),
      usuarios: n('usuarios'),
    );
  }
}
