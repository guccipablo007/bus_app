import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../navigation/role_router_screen.dart';
import '../services/session_storage.dart';
import '../shared/models/user_role.dart';
import 'login_screen.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({
    super.key,
    required this.apiClient,
    this.sessionStorage,
    this.restoredSession,
  });

  final ApiClient apiClient;
  final SessionStorage? sessionStorage;
  final UserSession? restoredSession;

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  UserSession? _session;

  @override
  void initState() {
    super.initState();
    _session = widget.restoredSession;
  }

  void _onLogout() async {
    try {
      await widget.sessionStorage?.clearSession();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(
          apiClient: widget.apiClient,
          sessionStorage: widget.sessionStorage,
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session == null) {
      return LoginScreen(
        apiClient: widget.apiClient,
        sessionStorage: widget.sessionStorage,
      );
    }
    return RoleRouterScreen(
      session: session,
      apiClient: widget.apiClient,
      sessionStorage: widget.sessionStorage,
      onLogout: _onLogout,
    );
  }
}
