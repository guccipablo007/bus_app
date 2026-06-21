import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../services/app_logout.dart';
import '../../services/session_storage.dart';
import '../models/user_role.dart';
import 'glass_panel.dart';

class RoleDashboardShell extends StatelessWidget {
  const RoleDashboardShell({
    super.key,
    required this.title,
    required this.icon,
    required this.session,
    required this.apiClient,
    required this.actions,
    this.statusText,
    this.note,
    this.sessionStorage,
    this.onLogout,
  });

  final String title;
  final IconData icon;
  final UserSession session;
  final ApiClient apiClient;
  final List<(IconData, String)> actions;
  final String? statusText;
  final String? note;
  final SessionStorage? sessionStorage;
  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              final callback = onLogout;
              if (callback != null) {
                await callback();
              } else {
                await AppLogout.perform(
                  context,
                  apiClient: apiClient,
                  sessionStorage: sessionStorage,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE4F5EF), Color(0xFFFFF7E5), Color(0xFFEDF1F8)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassPanel(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(icon)),
                  title: Text(session.fullName),
                  subtitle: Text(
                    session.roles.map((role) => role.label).join(' | '),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (statusText != null) ...[
                GlassPanel(
                  child: ListTile(
                    leading: const Icon(Icons.verified_user_outlined),
                    title: const Text('Account status'),
                    subtitle: Text(statusText!),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text('Workspace', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...actions.map(
                (action) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassPanel(
                    child: ListTile(
                      leading: Icon(action.$1),
                      title: Text(action.$2),
                      trailing: const Icon(Icons.lock_clock_outlined),
                      subtitle: const Text(
                        'Available in a later staging milestone',
                      ),
                    ),
                  ),
                ),
              ),
              if (note != null) ...[
                const SizedBox(height: 8),
                Text(note!, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
