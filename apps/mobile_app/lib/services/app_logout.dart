import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import '../core/api/api_client.dart';
import 'session_storage.dart';

abstract final class AppLogout {
  static Future<void> perform(
    BuildContext context, {
    required ApiClient apiClient,
    SessionStorage? sessionStorage,
  }) async {
    final storage = sessionStorage ?? await SessionStorage.create();
    await storage.clearSession();
    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            LoginScreen(apiClient: apiClient, sessionStorage: storage),
      ),
      (_) => false,
    );
  }
}
