import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_app/core/api/api_client.dart';
import 'package:mobile_app/features/onboarding/onboarding_screens.dart';
import 'package:mobile_app/features/passenger/passenger_home_shell.dart';
import 'package:mobile_app/features/super_admin/super_admin_shell.dart';
import 'package:mobile_app/shared/models/user_role.dart';

void main() {
  const passenger = UserSession(
    userId: 'passenger-1',
    fullName: 'Passenger Demo',
    email: 'passenger@example.test',
    phone: '+237670000001',
    roles: [UserRole.passenger],
    accessToken: 'access',
    refreshToken: 'refresh',
  );
  const admin = UserSession(
    userId: 'admin-1',
    fullName: 'Super Admin',
    email: 'admin@example.test',
    phone: null,
    roles: [UserRole.superAdmin],
    accessToken: 'admin-access',
    refreshToken: 'refresh',
  );

  ApiClient client(http.Response Function(http.Request) handler) => ApiClient(
    baseUrl: 'https://example.test/api/v1',
    httpClient: MockClient((request) async => handler(request)),
  );

  testWidgets('passenger profile exposes application entry points', (
    tester,
  ) async {
    final api = client((request) {
      if (request.url.path.endsWith('/health')) {
        return http.Response('{"status":"ok","database":"reachable"}', 200);
      }
      return http.Response('[]', 200);
    });
    await tester.pumpWidget(
      MaterialApp(
        home: PassengerHomeShell(session: passenger, apiClient: api),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(find.text('Apply as bus company'), findsOneWidget);
    expect(find.text('Apply as taxi driver'), findsOneWidget);
    expect(find.text('My applications'), findsOneWidget);
  });

  testWidgets('agency application validates required fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AgencyApplicationScreen(
          session: passenger,
          apiClient: client((_) => http.Response('{}', 201)),
        ),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit application'));
    await tester.pump();
    expect(find.text('Company name is required.'), findsOneWidget);
    expect(find.text('City is required.'), findsOneWidget);
  });

  testWidgets('driver application validates required fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DriverApplicationScreen(
          session: passenger,
          apiClient: client((_) => http.Response('{}', 201)),
        ),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit application'));
    await tester.pump();
    expect(find.text('City is required.'), findsOneWidget);
  });

  testWidgets('agency submission shows pending approval state', (tester) async {
    final api = client(
      (request) => http.Response('''{
      "id":"application-1","applicationType":"agency","applicantName":"Passenger Demo",
      "companyName":"Mountain Express","city":"Buea","status":"submitted","documents":[]
    }''', 201),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: AgencyApplicationScreen(session: passenger, apiClient: api),
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Company name'),
      'Mountain Express',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'City'), 'Buea');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Short description'),
      'Reliable staging transport company.',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit application'));
    await tester.pumpAndSettle();
    expect(find.text('Pending admin review'), findsOneWidget);
    expect(
      find.text(
        'Your application has been submitted and is pending admin review.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('super admin dashboard exposes review queue', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SuperAdminShell(
          session: admin,
          apiClient: client((_) => http.Response('[]', 200)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Application review'), findsOneWidget);
    expect(find.text('Pending agency applications'), findsOneWidget);
    expect(find.text('Pending driver applications'), findsOneWidget);
  });
}
