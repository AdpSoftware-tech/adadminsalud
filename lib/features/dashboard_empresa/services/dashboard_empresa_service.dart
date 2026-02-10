import '../../../core/network/api_client.dart';
import '../models/dashboard_resumen.dart';

import '../models/dashboard_suscripciones.dart';

class DashboardEmpresaService {
  final ApiClient api;
  const DashboardEmpresaService(this.api);

  Future<DashboardResumen> fetchResumen() async {
    final json = await api.getJson('/estructura/dashboard/resumen');
    return DashboardResumen.fromJson(json);
  }

  Future<DashboardSuscripciones> fetchSuscripciones() async {
    final json = await api.getJson('/estructura/dashboard/suscripciones');
    return DashboardSuscripciones.fromJson(json);
  }
}
