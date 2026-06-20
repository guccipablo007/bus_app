import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../shared/models/user_role.dart';
import '../../shared/widgets/role_dashboard_shell.dart';

class TaxiDispatcherShell extends StatelessWidget {
  const TaxiDispatcherShell({
    super.key,
    required this.session,
    required this.apiClient,
  });
  final UserSession session;
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) => RoleDashboardShell(
    title: 'Taxi dispatch',
    icon: Icons.support_agent_outlined,
    session: session,
    apiClient: apiClient,
    actions: const [
      (Icons.pending_actions_outlined, 'Pending requests'),
      (Icons.person_pin_circle_outlined, 'Assign drivers'),
      (Icons.route_outlined, 'Active rides'),
    ],
  );
}
