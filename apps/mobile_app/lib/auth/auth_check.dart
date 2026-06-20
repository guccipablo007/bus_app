import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../navigation/role_router_screen.dart';
import '../shared/models/user_role.dart';
import 'login_screen.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key, required this.apiClient, this.session});

  final ApiClient apiClient;
  final UserSession? session;

  @override
  Widget build(BuildContext context) {
    final currentSession = session;
    if (currentSession == null) {
      return LoginScreen(apiClient: apiClient);
    }
    return RoleRouterScreen(session: currentSession, apiClient: apiClient);
  }
}
