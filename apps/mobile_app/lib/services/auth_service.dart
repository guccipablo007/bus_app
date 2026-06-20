import '../core/api/api_client.dart';
import '../shared/models/user_role.dart';

class AuthService {
  const AuthService(this.apiClient);

  final ApiClient apiClient;

  Future<UserSession> login(String identifier, String password) =>
      apiClient.login(identifier: identifier, password: password);

  Future<UserSession> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) => apiClient.register(
    fullName: fullName,
    phone: phone,
    email: email,
    password: password,
  );
}
