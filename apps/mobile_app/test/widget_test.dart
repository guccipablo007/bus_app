import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/auth/auth_check.dart';
import 'package:mobile_app/features/agency/agency_shell.dart';
import 'package:mobile_app/features/dispatcher/taxi_dispatcher_shell.dart';
import 'package:mobile_app/features/driver/taxi_driver_shell.dart';
import 'package:mobile_app/features/passenger/passenger_home_shell.dart';
import 'package:mobile_app/features/super_admin/super_admin_shell.dart';
import 'package:mobile_app/navigation/role_router_screen.dart';
import 'package:mobile_app/shared/models/user_role.dart';

void main() {
  testWidgets('unauthenticated users see login', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthCheck(apiBaseUrl: 'http://example.test/api/v1'),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('API: http://example.test/api/v1'), findsOneWidget);
  });

  test('backend roles map to the expected shells', () {
    expect(
      RoleRouterScreen.shellFor(UserRole.passenger),
      isA<PassengerHomeShell>(),
    );
    expect(RoleRouterScreen.shellFor(UserRole.agencyOwner), isA<AgencyShell>());
    expect(
      RoleRouterScreen.shellFor(UserRole.taxiDispatcher),
      isA<TaxiDispatcherShell>(),
    );
    expect(
      RoleRouterScreen.shellFor(UserRole.taxiDriver),
      isA<TaxiDriverShell>(),
    );
    expect(
      RoleRouterScreen.shellFor(UserRole.superAdmin),
      isA<SuperAdminShell>(),
    );
  });
}
