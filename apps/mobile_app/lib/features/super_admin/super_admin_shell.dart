import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../shared/models/user_role.dart';
import '../../shared/widgets/role_dashboard_shell.dart';

class SuperAdminShell extends StatelessWidget {
  const SuperAdminShell({
    super.key,
    required this.session,
    required this.apiClient,
  });
  final UserSession session;
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) => RoleDashboardShell(
    title: 'System admin',
    icon: Icons.admin_panel_settings_outlined,
    session: session,
    apiClient: apiClient,
    actions: const [
      (Icons.business_outlined, 'Agencies'),
      (Icons.location_city_outlined, 'Regions and cities'),
      (Icons.receipt_long_outlined, 'Audit logs'),
    ],
  );
}
