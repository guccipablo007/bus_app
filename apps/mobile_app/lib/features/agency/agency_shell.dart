import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../shared/models/user_role.dart';
import '../../shared/widgets/role_dashboard_shell.dart';

class AgencyShell extends StatelessWidget {
  const AgencyShell({
    super.key,
    required this.session,
    required this.apiClient,
  });
  final UserSession session;
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) => RoleDashboardShell(
    title: 'Agency',
    icon: Icons.business_outlined,
    session: session,
    apiClient: apiClient,
    actions: const [
      (Icons.route_outlined, 'Trips'),
      (Icons.groups_outlined, 'Passenger manifests'),
      (Icons.directions_bus_outlined, 'Fleet'),
      (Icons.local_taxi_outlined, 'Taxi operations'),
    ],
  );
}
