import 'package:flutter/material.dart';

import '../features/agency/agency_shell.dart';
import '../features/dispatcher/taxi_dispatcher_shell.dart';
import '../features/driver/taxi_driver_shell.dart';
import '../features/passenger/passenger_home_shell.dart';
import '../features/super_admin/super_admin_shell.dart';
import '../shared/models/user_role.dart';

class RoleRouterScreen extends StatelessWidget {
  const RoleRouterScreen({super.key, required this.session});

  final UserSession session;

  @override
  Widget build(BuildContext context) {
    if (session.roles.length > 1) {
      return RoleSwitchScreen(session: session);
    }
    return shellFor(session.roles.firstOrNull);
  }

  static Widget shellFor(UserRole? role) {
    return switch (role) {
      UserRole.passenger => const PassengerHomeShell(),
      UserRole.agencyOwner ||
      UserRole.agencyAdmin ||
      UserRole.agencyStaff => const AgencyShell(),
      UserRole.taxiDispatcher => const TaxiDispatcherShell(),
      UserRole.taxiDriver => const TaxiDriverShell(),
      UserRole.superAdmin => const SuperAdminShell(),
      null => const UnknownRoleScreen(),
    };
  }
}

class RoleSwitchScreen extends StatelessWidget {
  const RoleSwitchScreen({super.key, required this.session});

  final UserSession session;

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
            title: Text(role.claim),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => RoleRouterScreen.shellFor(role),
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
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('No supported role was returned by the API.')),
    );
  }
}
