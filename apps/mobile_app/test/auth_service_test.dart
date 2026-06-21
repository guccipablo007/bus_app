import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_app/core/api/api_client.dart';
import 'package:mobile_app/core/api/api_exception.dart';
import 'package:mobile_app/services/auth_service.dart';

void main() {
  test('invalid credentials use a friendly login message', () async {
    final service = AuthService(
      ApiClient(
        baseUrl: 'https://example.test/api/v1',
        httpClient: MockClient(
          (_) async => http.Response(
            '{"message":"Invalid email, phone, or password."}',
            401,
          ),
        ),
      ),
    );

    expect(
      () => service.login('passenger@example.test', 'wrong-password'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          'Invalid phone/email or password.',
        ),
      ),
    );
  });

  test('network failures use a connection message', () async {
    final service = AuthService(
      ApiClient(
        baseUrl: 'https://example.test/api/v1',
        httpClient: MockClient(
          (_) async => throw http.ClientException('offline'),
        ),
      ),
    );

    expect(
      () => service.login('passenger@example.test', 'Password123!'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          'Could not reach the bus service. Please try again.',
        ),
      ),
    );
  });

  test('server failures use a safe retry-later message', () async {
    final service = AuthService(
      ApiClient(
        baseUrl: 'https://example.test/api/v1',
        httpClient: MockClient(
          (_) async => http.Response('{"message":"internal detail"}', 500),
        ),
      ),
    );

    expect(
      () => service.login('passenger@example.test', 'Password123!'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          'The server had a problem. Please try again later.',
        ),
      ),
    );
  });
}
