import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../shared/models/api_models.dart';
import '../../shared/models/user_role.dart';
import '../../shared/widgets/glass_panel.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({
    super.key,
    required this.session,
    required this.apiClient,
  });
  final UserSession session;
  final ApiClient apiClient;

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  late Future<List<OnboardingApplicationModel>> _future;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = widget.apiClient.myApplications(
    accessToken: widget.session.accessToken,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My applications')),
    body: FutureBuilder<List<OnboardingApplicationModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _Retry(
            message: _message(snapshot.error),
            onRetry: () => setState(_reload),
          );
        }
        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return const Center(child: Text('No applications submitted yet.'));
        }
        return RefreshIndicator(
          onRefresh: () async => setState(_reload),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _ApplicationCard(application: items[index]),
          ),
        );
      },
    ),
  );
}

class AgencyApplicationScreen extends StatefulWidget {
  const AgencyApplicationScreen({
    super.key,
    required this.session,
    required this.apiClient,
  });
  final UserSession session;
  final ApiClient apiClient;
  @override
  State<AgencyApplicationScreen> createState() =>
      _AgencyApplicationScreenState();
}

class _AgencyApplicationScreenState extends State<AgencyApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _company = TextEditingController();
  final _owner = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  final _registration = TextEditingController();
  final _description = TextEditingController();
  final _documentName = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _owner.text = widget.session.fullName;
    _phone.text = widget.session.phone ?? '';
    _email.text = widget.session.email;
  }

  @override
  void dispose() {
    for (final controller in [
      _company,
      _owner,
      _phone,
      _email,
      _city,
      _registration,
      _description,
      _documentName,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final application = await widget.apiClient.createAgencyApplication(
        accessToken: widget.session.accessToken,
        application: {
          'companyName': _company.text.trim(),
          'ownerManagerName': _owner.text.trim(),
          'phone': _phone.text.trim(),
          'email': _email.text.trim(),
          'city': _city.text.trim(),
          if (_registration.text.trim().isNotEmpty)
            'businessRegistrationNumber': _registration.text.trim(),
          'description': _description.text.trim(),
          if (_documentName.text.trim().isNotEmpty)
            'documents': [
              {
                'documentType': 'business_registration',
                'originalFilename': _documentName.text.trim(),
              },
            ],
        },
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => PendingApprovalScreen(application: application),
        ),
      );
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _ApplicationFormScaffold(
    title: 'Apply as bus company',
    formKey: _formKey,
    busy: _busy,
    error: _error,
    onSubmit: _submit,
    children: [
      _field(_company, 'Company name'),
      _field(_owner, 'Owner / manager name'),
      _field(_phone, 'Phone'),
      _field(_email, 'Email', email: true),
      _field(_city, 'City'),
      _field(
        _registration,
        'Business registration number (optional)',
        required: false,
      ),
      _field(_description, 'Short description', min: 10, lines: 3),
      _metadataNote(),
      _field(_documentName, 'Document filename (optional)', required: false),
    ],
  );
}

class DriverApplicationScreen extends StatefulWidget {
  const DriverApplicationScreen({
    super.key,
    required this.session,
    required this.apiClient,
  });
  final UserSession session;
  final ApiClient apiClient;
  @override
  State<DriverApplicationScreen> createState() =>
      _DriverApplicationScreenState();
}

class _DriverApplicationScreenState extends State<DriverApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _plate = TextEditingController();
  final _documentName = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name.text = widget.session.fullName;
    _phone.text = widget.session.phone ?? '';
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _city, _plate, _documentName]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final application = await widget.apiClient.createDriverApplication(
        accessToken: widget.session.accessToken,
        application: {
          'driverName': _name.text.trim(),
          'phone': _phone.text.trim(),
          'city': _city.text.trim(),
          if (_plate.text.trim().isNotEmpty) 'vehiclePlate': _plate.text.trim(),
          if (_documentName.text.trim().isNotEmpty)
            'documents': [
              {
                'documentType': 'driver_license',
                'originalFilename': _documentName.text.trim(),
              },
            ],
        },
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => PendingApprovalScreen(application: application),
        ),
      );
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _ApplicationFormScaffold(
    title: 'Apply as taxi driver',
    formKey: _formKey,
    busy: _busy,
    error: _error,
    onSubmit: _submit,
    children: [
      _field(_name, 'Driver name'),
      _field(_phone, 'Phone'),
      _field(_city, 'City'),
      _field(_plate, 'Vehicle plate (optional)', required: false),
      _metadataNote(),
      _field(_documentName, 'License filename (optional)', required: false),
    ],
  );
}

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key, required this.application});
  final OnboardingApplicationModel application;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Application submitted')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassPanel(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule_send_outlined, size: 52),
                const SizedBox(height: 16),
                Text(
                  'Pending admin review',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your application has been submitted and is pending admin review.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Reference: ${application.id}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ApplicationFormScaffold extends StatelessWidget {
  const _ApplicationFormScaffold({
    required this.title,
    required this.formKey,
    required this.children,
    required this.busy,
    required this.onSubmit,
    this.error,
  });
  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final bool busy;
  final VoidCallback onSubmit;
  final String? error;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassPanel(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final child in children) ...[
                    child,
                    const SizedBox(height: 12),
                  ],
                  if (error != null)
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: busy ? null : onSubmit,
                    icon: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(busy ? 'Submitting...' : 'Submit application'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _field(
  TextEditingController controller,
  String label, {
  bool required = true,
  int min = 2,
  int lines = 1,
  bool email = false,
}) => TextFormField(
  controller: controller,
  maxLines: lines,
  keyboardType: email ? TextInputType.emailAddress : null,
  decoration: InputDecoration(labelText: label),
  validator: (value) {
    final text = value?.trim() ?? '';
    if (!required && text.isEmpty) return null;
    if (text.length < min) return '$label is required.';
    if (email && !text.contains('@')) return 'Enter a valid email.';
    return null;
  },
);

Widget _metadataNote() => const ListTile(
  contentPadding: EdgeInsets.zero,
  leading: Icon(Icons.description_outlined),
  title: Text('Document details / placeholder for staging'),
  subtitle: Text(
    'Only filename and document type metadata are saved. No file is uploaded.',
  ),
);

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application});
  final OnboardingApplicationModel application;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: GlassPanel(
      child: ListTile(
        leading: Icon(
          application.applicationType == 'agency'
              ? Icons.business_outlined
              : Icons.local_taxi_outlined,
        ),
        title: Text(application.companyName ?? application.applicantName),
        subtitle: Text(
          '${application.city} | ${application.status.replaceAll('_', ' ')}'
          '${application.rejectionReason == null ? '' : '\n${application.rejectionReason}'}'
          '${application.documents.isEmpty ? '' : '\n${application.documents.length} metadata document(s)'}',
        ),
        isThreeLine:
            application.rejectionReason != null ||
            application.documents.isNotEmpty,
      ),
    ),
  );
}

class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

String _message(Object? error) =>
    error is ApiException ? error.message : 'Could not load applications.';
