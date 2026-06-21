import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../shared/models/api_models.dart';
import '../../shared/models/user_role.dart';
import '../../shared/widgets/glass_panel.dart';

class SuperAdminShell extends StatefulWidget {
  const SuperAdminShell({
    super.key,
    required this.session,
    required this.apiClient,
  });
  final UserSession session;
  final ApiClient apiClient;
  @override
  State<SuperAdminShell> createState() => _SuperAdminShellState();
}

class _SuperAdminShellState extends State<SuperAdminShell> {
  bool _loading = true;
  String? _error;
  List<OnboardingApplicationModel> _applications = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await widget.apiClient.adminApplications(
        accessToken: widget.session.accessToken,
      );
      if (mounted) setState(() => _applications = items);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _review(
    OnboardingApplicationModel application,
    String decision,
  ) async {
    String? reason;
    if (decision == 'rejected') {
      final controller = TextEditingController();
      reason = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reject application'),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Rejection reason'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().length >= 3) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('Reject'),
            ),
          ],
        ),
      );
      controller.dispose();
      if (reason == null) return;
    }
    try {
      await widget.apiClient.reviewApplication(
        accessToken: widget.session.accessToken,
        applicationId: application.id,
        decision: decision,
        rejectionReason: reason,
      );
      await _load();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _applications
        .where(
          (item) => item.status == 'submitted' || item.status == 'under_review',
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application review'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE4F5EF), Color(0xFFFFF7E5), Color(0xFFEDF1F8)],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const GlassPanel(
                    child: ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Staging review'),
                      subtitle: Text(
                        'Approval changes application status only. It does not create agencies, drivers, or roles.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pending agency applications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ...pending
                      .where((item) => item.applicationType == 'agency')
                      .map(_card),
                  const SizedBox(height: 16),
                  Text(
                    'Pending driver applications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ...pending
                      .where((item) => item.applicationType == 'driver')
                      .map(_card),
                  if (pending.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No applications pending review.'),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _card(OnboardingApplicationModel application) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              application.companyName ?? application.applicantName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('${application.city} | ${application.applicationType}'),
            const SizedBox(height: 8),
            Text(
              application.documents.isEmpty
                  ? 'No document metadata submitted.'
                  : application.documents
                        .map(
                          (doc) =>
                              '${doc.documentType}: ${doc.originalFilename} (metadata only)',
                        )
                        .join('\n'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => _review(application, 'approved'),
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _review(application, 'rejected'),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
