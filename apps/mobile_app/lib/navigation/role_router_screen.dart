import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import '../core/api/api_client.dart';
import '../features/agency/agency_shell.dart';
import '../features/dispatcher/taxi_dispatcher_shell.dart';
import '../features/driver/taxi_driver_shell.dart';
import '../features/passenger/passenger_home_shell.dart';
import '../features/super_admin/super_admin_shell.dart';
import '../shared/models/user_role.dart';

class RoleRouterScreen extends StatelessWidget {
  const RoleRouterScreen({
    super.key,
    required this.session,
    required this.apiClient,
  });

  final UserSession session;
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    if (session.roles.length > 1) {
      return RoleSwitchScreen(session: session, apiClient: apiClient);
    }
    return shellFor(
      session.roles.firstOrNull,
      session: session,
      apiClient: apiClient,
    );
  }

  static Widget shellFor(
    UserRole? role, {
    required UserSession session,
    required ApiClient apiClient,
  }) {
    return switch (role) {
      UserRole.passenger => PassengerHomeShell(
        session: session,
        apiClient: apiClient,
      ),
      UserRole.agencyOwner || UserRole.agencyAdmin || UserRole.agencyStaff =>
        AgencyShell(session: session, apiClient: apiClient),
      UserRole.taxiDispatcher => TaxiDispatcherShell(
        session: session,
        apiClient: apiClient,
      ),
      UserRole.taxiDriver => TaxiDriverShell(
        session: session,
        apiClient: apiClient,
      ),
      UserRole.superAdmin => SuperAdminShell(
        session: session,
        apiClient: apiClient,
      ),
      null => const UnknownRoleScreen(),
    };
  }

  static void logout(BuildContext context, ApiClient apiClient) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(apiClient: apiClient),
      ),
      (_) => false,
    );
  }
}

class RoleSwitchScreen extends StatelessWidget {
  const RoleSwitchScreen({
    super.key,
    required this.session,
    required this.apiClient,
  });

  final UserSession session;
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose workspace')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: session.roles.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final role = session.roles[index];
          return ListTile(
            title: Text(role.label),
            leading: const Icon(Icons.workspaces_outline),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => RoleRouterScreen.shellFor(
                  role,
                  session: session,
                  apiClient: apiClient,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UnknownRoleScreen extends StatelessWidget {
  const UnknownRoleScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('No supported role was returned by the API.')),
  );
}
