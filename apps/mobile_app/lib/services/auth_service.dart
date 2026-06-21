import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../shared/models/user_role.dart';

class AuthService {
  const AuthService(this.apiClient);

  final ApiClient apiClient;

  Future<UserSession> login(String identifier, String password) async {
    try {
      return await apiClient.login(identifier: identifier, password: password);
    } on ApiException catch (error) {
      final statusCode = error.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw const ApiException(
          'Invalid phone/email or password.',
          statusCode: 401,
        );
      }
      if (statusCode == 400) {
        throw ApiException(error.message, statusCode: 400);
      }
      if (statusCode != null && statusCode >= 500) {
        throw const ApiException(
          'The server had a problem. Please try again later.',
          statusCode: 500,
        );
      }
      rethrow;
    }
  }

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
