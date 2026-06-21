import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_app/auth/auth_check.dart';
import 'package:mobile_app/auth/splash_screen.dart';
import 'package:mobile_app/core/api/api_client.dart';
import 'package:mobile_app/services/session_storage.dart';
import 'package:mobile_app/shared/models/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  ApiClient apiClient() => ApiClient(
    baseUrl: 'https://example.test/api/v1',
    httpClient: MockClient((request) async {
      if (request.url.path.endsWith('/health')) {
        return http.Response('{"status":"ok","database":"reachable"}', 200);
      }
      if (request.url.path.endsWith('/cities')) {
        return http.Response('''[
            {"id":"city-buea","regionId":"region-sw","name":"Buea"},
            {"id":"city-bamenda","regionId":"region-nw","name":"Bamenda"}
          ]''', 200);
      }
      return http.Response('[]', 200);
    }),
  );

  UserSession session(UserRole role) => UserSession(
    userId: 'user-${role.claim}',
    fullName: role.label,
    email: '${role.claim}@example.test',
    phone: null,
    roles: [role],
    accessToken: 'access-${role.claim}',
    refreshToken: 'refresh-${role.claim}',
  );

  for (final role in [
    UserRole.agencyOwner,
    UserRole.taxiDispatcher,
    UserRole.taxiDriver,
    UserRole.superAdmin,
  ]) {
    testWidgets('${role.claim} sign out clears storage and resets navigation', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final storage = await SessionStorage.create();
      final activeSession = session(role);
      await storage.saveSession(activeSession);

      await tester.pumpWidget(
        MaterialApp(
          home: AuthCheck(
            apiClient: apiClient(),
            sessionStorage: storage,
            restoredSession: activeSession,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Sign out'));
      await tester.pumpAndSettle();

      expect(storage.loadSession(), isNull);
      expect(find.text('Choose your role to log in'), findsOneWidget);
      expect(
        tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
        isFalse,
      );
    });
  }

  testWidgets('passenger app bar sign out clears storage', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await SessionStorage.create();
    final activeSession = session(UserRole.passenger);
    await storage.saveSession(activeSession);

    await tester.pumpWidget(
      MaterialApp(
        home: AuthCheck(
          apiClient: apiClient(),
          sessionStorage: storage,
          restoredSession: activeSession,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();

    expect(storage.loadSession(), isNull);
    expect(find.text('Choose your role to log in'), findsOneWidget);
  });

  testWidgets(
    'passenger profile sign out clears session and survives restart',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = await SessionStorage.create();
      final activeSession = session(UserRole.passenger);
      final client = apiClient();
      await storage.saveSession(activeSession);
      await storage.saveSelectedRole(UserRole.passenger);

      await tester.pumpWidget(
        MaterialApp(
          home: AuthCheck(
            apiClient: client,
            sessionStorage: storage,
            restoredSession: activeSession,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await tester.pump();
      await tester.ensureVisible(find.text('Sign out'));
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(storage.loadSession(), isNull);
      expect(storage.loadSelectedRole(), isNull);
      expect(find.text('Choose your role to log in'), findsOneWidget);
      expect(
        tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
        false,
      );

      await tester.pumpWidget(
        MaterialApp(home: SplashScreen(apiClient: client)),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text('Choose your role to log in'), findsOneWidget);
    },
  );
}
