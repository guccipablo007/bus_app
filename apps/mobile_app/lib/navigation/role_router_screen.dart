import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../features/agency/agency_shell.dart';
import '../features/dispatcher/taxi_dispatcher_shell.dart';
import '../features/driver/taxi_driver_shell.dart';
import '../features/passenger/passenger_home_shell.dart';
import '../features/super_admin/super_admin_shell.dart';
import '../services/session_storage.dart';
import '../services/app_logout.dart';
import '../shared/models/user_role.dart';

class RoleRouterScreen extends StatelessWidget {
  const RoleRouterScreen({
    super.key,
    required this.session,
    required this.apiClient,
    this.sessionStorage,
    this.onLogout,
  });

  final UserSession session;
  final ApiClient apiClient;
  final SessionStorage? sessionStorage;
  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context) {
    if (session.roles.length > 1) {
      return RoleSwitchScreen(
        session: session,
        apiClient: apiClient,
        sessionStorage: sessionStorage,
        onLogout: onLogout,
      );
    }
    return shellFor(
      session.roles.firstOrNull,
      session: session,
      apiClient: apiClient,
      sessionStorage: sessionStorage,
      onLogout: onLogout,
    );
  }

  static Widget shellFor(
    UserRole? role, {
    required UserSession session,
    required ApiClient apiClient,
    SessionStorage? sessionStorage,
    Future<void> Function()? onLogout,
  }) {
    return switch (role) {
      UserRole.passenger => PassengerHomeShell(
        session: session,
        apiClient: apiClient,
        sessionStorage: sessionStorage,
        onLogout: onLogout,
      ),
      UserRole.agencyOwner ||
      UserRole.agencyAdmin ||
      UserRole.agencyStaff => AgencyShell(
        session: session,
        apiClient: apiClient,
        sessionStorage: sessionStorage,
        onLogout: onLogout,
      ),
      UserRole.taxiDispatcher => TaxiDispatcherShell(
        session: session,
        apiClient: apiClient,
        sessionStorage: sessionStorage,
        onLogout: onLogout,
      ),
      UserRole.taxiDriver => TaxiDriverShell(
        session: session,
        apiClient: apiClient,
        sessionStorage: sessionStorage,
        onLogout: onLogout,
      ),
      UserRole.superAdmin => SuperAdminShell(
        session: session,
        apiClient: apiClient,
        sessionStorage: sessionStorage,
        onLogout: onLogout,
      ),
      null => const UnknownRoleScreen(),
    };
  }

  static Future<void> logout(
    BuildContext context,
    ApiClient apiClient, {
    SessionStorage? sessionStorage,
  }) => AppLogout.perform(
    context,
    apiClient: apiClient,
    sessionStorage: sessionStorage,
  );
}

class RoleSwitchScreen extends StatelessWidget {
  const RoleSwitchScreen({
    super.key,
    required this.session,
    required this.apiClient,
    this.sessionStorage,
    this.onLogout,
  });

  final UserSession session;
  final ApiClient apiClient;
  final SessionStorage? sessionStorage;
  final Future<void> Function()? onLogout;

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
                  sessionStorage: sessionStorage,
                  onLogout: onLogout,
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
