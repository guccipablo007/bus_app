import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../navigation/role_router_screen.dart';
import '../services/auth_service.dart';
import '../services/session_storage.dart';
import '../shared/widgets/glass_panel.dart';
import 'register_screen.dart';

/// Demo credential configuration for QA testing.
class DemoAccount {
  const DemoAccount({
    required this.label,
    required this.icon,
    required this.color,
    required this.identifier,
    required this.password,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String identifier;
  final String password;

  static const passenger = DemoAccount(
    label: 'Passenger',
    icon: Icons.person_outline,
    color: Color(0xFF2E7D32),
    identifier: '+237670000001',
    password: 'pass123',
  );

  static const agency = DemoAccount(
    label: 'Bus company',
    icon: Icons.business_outlined,
    color: Color(0xFF1565C0),
    identifier: '+237670000010',
    password: 'pass123',
  );

  static const taxiDriver = DemoAccount(
    label: 'Taxi driver',
    icon: Icons.local_taxi_outlined,
    color: Color(0xFFE65100),
    identifier: '+237670000020',
    password: 'pass123',
  );

  static const all = [passenger, agency, taxiDriver];
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.apiClient, this.sessionStorage});

  final ApiClient apiClient;
  final SessionStorage? sessionStorage;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pre-fill from a previous failed attempt is intentionally left empty.
    // Show the role cards so the user taps one to fill credentials.
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  void _fillDemo(DemoAccount account) {
    setState(() {
      _identifier.text = account.identifier;
      _password.text = account.password;
      _error = null;
    });
  }

  Future<void> _login() async {
    if (_identifier.text.trim().isEmpty || _password.text.isEmpty) {
      setState(
        () => _error =
            'Enter your phone or email and password, or tap a demo account above.',
      );
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final session = await AuthService(
        widget.apiClient,
      ).login(_identifier.text.trim(), _password.text);
      if (!mounted) return;

      // Persist session to local storage.
      final storage = widget.sessionStorage;
      if (storage != null) {
        await storage.saveSession(session);
        // If single role, remember it for faster restore.
        if (session.roles.length == 1) {
          await storage.saveSelectedRole(session.roles.first);
        }
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => RoleRouterScreen(
            session: session,
            apiClient: widget.apiClient,
            sessionStorage: storage,
          ),
        ),
        (_) => false,
      );
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD9F3E9), Color(0xFFFFF3D6), Color(0xFFE9EEF8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  children: [
                    // ---- App header ----
                    GlassPanel(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.directions_bus_filled,
                              size: 48,
                              color: Color(0xFF1565C0),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Cameroon Bus',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'One app, different dashboards after login.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---- Role cards / demo helpers ----
                    Text(
                      'Choose your role to log in',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...DemoAccount.all.map(
                      (account) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _DemoCard(
                          account: account,
                          onTap: () => _fillDemo(account),
                        ),
                      ),
                    ),

                    // ---- Manual sign-in form ----
                    const SizedBox(height: 8),
                    GlassPanel(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Or sign in manually',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _identifier,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Phone or email',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _password,
                              obscureText: _obscurePassword,
                              onSubmitted: (_) => _submitting ? null : _login(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 18),
                            FilledButton.icon(
                              onPressed: _submitting ? null : _login,
                              icon: _submitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.login),
                              label: Text(
                                _submitting ? 'Signing in...' : 'Sign in',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    RegisterScreen(apiClient: widget.apiClient),
                              ),
                            ),
                      child: const Text('Create a new passenger account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A tappable card that displays a demo account role.
class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.account, required this.onTap});

  final DemoAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: account.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(account.icon, color: account.color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account.identifier,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.power_settings_new_rounded,
                color: account.color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
