import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../shared/models/user_role.dart';
import '../../shared/widgets/role_dashboard_shell.dart';

class TaxiDriverShell extends StatelessWidget {
  const TaxiDriverShell({
    super.key,
    required this.session,
    required this.apiClient,
  });
  final UserSession session;
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) => RoleDashboardShell(
    title: 'Taxi driver',
    icon: Icons.local_taxi_outlined,
    session: session,
    apiClient: apiClient,
    statusText: 'Approved staging taxi driver account',
    note: 'Live dispatch and location tracking are coming next.',
    actions: const [
      (Icons.assignment_outlined, 'Assigned rides'),
      (Icons.navigation_outlined, 'Pickup and drop-off flow'),
      (Icons.sync_alt_outlined, 'Ride status'),
      (Icons.history, 'Ride history'),
    ],
  );
}
