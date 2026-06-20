import 'package:flutter/material.dart';

import '../navigation/role_router_screen.dart';
import '../shared/models/user_role.dart';
import 'login_screen.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key, required this.apiBaseUrl, this.session});

  final String apiBaseUrl;
  final UserSession? session;

  @override
  Widget build(BuildContext context) {
    final currentSession = session;
    if (currentSession == null) {
      return LoginScreen(apiBaseUrl: apiBaseUrl);
    }
    return RoleRouterScreen(session: currentSession);
  }
}
