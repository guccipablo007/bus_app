import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../shared/models/user_role.dart';
import '../../services/session_storage.dart';
import '../../shared/widgets/role_dashboard_shell.dart';

class AgencyShell extends StatelessWidget {
  const AgencyShell({
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
  Widget build(BuildContext context) => RoleDashboardShell(
    title: 'Agency',
    icon: Icons.business_outlined,
    session: session,
    apiClient: apiClient,
    sessionStorage: sessionStorage,
    onLogout: onLogout,
    statusText: 'Approved staging agency account',
    note: 'Full agency operations are coming next.',
    actions: const [
      (Icons.route_outlined, 'Routes and trips'),
      (Icons.directions_bus_outlined, 'Buses'),
      (Icons.groups_outlined, 'Bookings and passenger manifests'),
    ],
  );
}
