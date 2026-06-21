import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_app/config/api_config.dart';
import 'package:mobile_app/core/api/api_client.dart';
import 'package:mobile_app/core/api/api_exception.dart';
import 'package:mobile_app/shared/models/user_role.dart';

void main() {
  test('default API URL points to hosted staging', () {
    expect(
      ApiConfig.baseUrl,
      'https://cameroon-bus-api-staging.onrender.com/api/v1',
    );
  });

  test('login uses backend-provided roles', () async {
    final client = ApiClient(
      baseUrl: 'https://example.test/api/v1/',
      httpClient: MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/login');
        expect(request.method, 'POST');
        expect(jsonDecode(request.body), {
          'identifier': 'passenger.demo@cameroonbus.test',
          'password': 'Password123!',
        });
        return http.Response(
          '''
          {
            "accessToken": "access",
            "refreshToken": "refresh",
            "user": {
              "id": "user-1",
              "fullName": "Agency User",
              "email": "agency@example.test",
              "phone": "+237600000000",
              "roles": ["agency_admin"]
            }
          }
          ''',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final session = await client.login(
      identifier: 'passenger.demo@cameroonbus.test',
      password: 'Password123!',
    );

    expect(session.fullName, 'Agency User');
    expect(session.roles, [UserRole.agencyAdmin]);
    expect(session.accessToken, 'access');
  });

  test('API errors expose safe server messages', () async {
    final client = ApiClient(
      baseUrl: 'https://example.test/api/v1',
      httpClient: MockClient(
        (_) async => http.Response('{"message":"Invalid credentials"}', 401),
      ),
    );

    expect(
      () => client.login(identifier: 'nobody', password: 'wrong'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 401)
            .having((error) => error.message, 'message', 'Invalid credentials'),
      ),
    );
  });

  test('trip search sends city query and parses results', () async {
    final client = ApiClient(
      baseUrl: 'https://example.test/api/v1',
      httpClient: MockClient((request) async {
        expect(request.url.queryParameters['originCity'], 'Buea');
        expect(request.url.queryParameters['destinationCity'], 'Bamenda');
        return http.Response('''
          [{
            "id": "trip-1",
            "departureTime": "2026-06-22T08:00:00.000Z",
            "arrivalEstimate": "2026-06-22T14:00:00.000Z",
            "agency": {"id": "agency-1", "name": "Unity Express Demo"},
            "busClass": "standard",
            "basePriceXaf": 8000,
            "availableSeats": ["1A", "1B"],
            "originTerminal": {"id": "terminal-1", "name": "Buea Demo Terminal", "city": "Buea"},
            "destinationTerminal": {"id": "terminal-2", "name": "Bamenda Demo Terminal", "city": "Bamenda"}
          }]
          ''', 200);
      }),
    );

    final trips = await client.searchTrips(
      originCity: 'Buea',
      destinationCity: 'Bamenda',
    );

    expect(trips, hasLength(1));
    expect(trips.single.id, 'trip-1');
    expect(trips.single.availableSeats, ['1A', '1B']);
  });
}
