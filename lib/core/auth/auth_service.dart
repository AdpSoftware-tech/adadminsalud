import '../network/api_client.dart';
import 'me_response.dart';

class AuthService {
  final ApiClient api;
  const AuthService(this.api);

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final json = await api.postJson('/auth/login', {
      'email': email,
      'password': password,
    });

    // Ajusta según tu respuesta real de /login:
    if (json['token'] != null) return json['token'].toString();

    final data = json['data'];
    if (data != null && data['token'] != null) return data['token'].toString();

    throw Exception('Login OK pero no vino token');
  }

  Future<MeResponse> me() async {
    final json = await api.getJson('/auth/me');
    return MeResponse.fromJson(json);
  }
}
