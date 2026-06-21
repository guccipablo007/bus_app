import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_app/auth/auth_check.dart';
import 'package:mobile_app/auth/login_screen.dart';
import 'package:mobile_app/core/api/api_client.dart';
import 'package:mobile_app/features/agency/agency_shell.dart';
import 'package:mobile_app/features/dispatcher/taxi_dispatcher_shell.dart';
import 'package:mobile_app/features/driver/taxi_driver_shell.dart';
import 'package:mobile_app/features/passenger/passenger_home_shell.dart';
import 'package:mobile_app/features/super_admin/super_admin_shell.dart';
import 'package:mobile_app/navigation/role_router_screen.dart';
import 'package:mobile_app/services/session_storage.dart';
import 'package:mobile_app/shared/models/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final apiClient = ApiClient(
    baseUrl: 'https://example.test/api/v1',
    httpClient: MockClient((_) async => http.Response('{"status":"ok"}', 200)),
  );
  const session = UserSession(
    userId: 'user-1',
    fullName: 'Demo Passenger',
    email: 'passenger@example.test',
    phone: '+237600000000',
    roles: [UserRole.passenger],
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
  );

  testWidgets('unauthenticated users see login', (tester) async {
    await tester.pumpWidget(MaterialApp(home: AuthCheck(apiClient: apiClient)));

    expect(find.text('Cameroon Bus'), findsOneWidget);
    expect(find.text('Choose your role to log in'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create a new passenger account'), findsOneWidget);
  });

  testWidgets('passenger demo helper fills seeded credentials', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(apiClient: apiClient)),
    );

    await tester.tap(find.text('Passenger'));
    await tester.pump();

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[0].controller?.text, 'passenger.demo@cameroonbus.test');
    expect(fields[1].controller?.text, 'Password123!');
  });

  testWidgets('successful login saves the session', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await SessionStorage.create();
    final loginClient = ApiClient(
      baseUrl: 'https://example.test/api/v1',
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('/auth/login')) {
          return http.Response('''
            {
              "accessToken": "saved-access",
              "refreshToken": "saved-refresh",
              "user": {
                "id": "passenger-1",
                "fullName": "Passenger Demo",
                "email": "passenger.demo@cameroonbus.test",
                "phone": null,
                "roles": ["passenger"]
              }
            }
            ''', 200);
        }
        if (request.url.path.endsWith('/health')) {
          return http.Response('{"status":"ok","database":"reachable"}', 200);
        }
        if (request.url.path.endsWith('/regions') ||
            request.url.path.endsWith('/cities') ||
            request.url.path.endsWith('/trips/search')) {
          return http.Response('[]', 200);
        }
        return http.Response('{"message":"Not found"}', 404);
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(apiClient: loginClient, sessionStorage: storage),
      ),
    );
    await tester.tap(find.text('Passenger'));
    await tester.ensureVisible(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    final restored = storage.loadSession();
    expect(restored?.userId, 'passenger-1');
    expect(restored?.accessToken, 'saved-access');
    expect(restored?.roles, [UserRole.passenger]);
  });

  test('backend roles map to the expected shells', () {
    expect(
      RoleRouterScreen.shellFor(
        UserRole.passenger,
        session: session,
        apiClient: apiClient,
      ),
      isA<PassengerHomeShell>(),
    );
    expect(
      RoleRouterScreen.shellFor(
        UserRole.agencyOwner,
        session: session,
        apiClient: apiClient,
      ),
      isA<AgencyShell>(),
    );
    expect(
      RoleRouterScreen.shellFor(
        UserRole.taxiDispatcher,
        session: session,
        apiClient: apiClient,
      ),
      isA<TaxiDispatcherShell>(),
    );
    expect(
      RoleRouterScreen.shellFor(
        UserRole.taxiDriver,
        session: session,
        apiClient: apiClient,
      ),
      isA<TaxiDriverShell>(),
    );
    expect(
      RoleRouterScreen.shellFor(
        UserRole.superAdmin,
        session: session,
        apiClient: apiClient,
      ),
      isA<SuperAdminShell>(),
    );
  });
}
