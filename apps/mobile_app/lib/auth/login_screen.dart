import 'package:flutter/material.dart';

import '../shared/widgets/glass_panel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.apiBaseUrl});

  final String apiBaseUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDDF4EC), Color(0xFFF9F4DE)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: GlassPanel(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.directions_bus_filled, size: 44),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome back',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to continue to your role-specific workspace.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        const TextField(
                          decoration: InputDecoration(
                            labelText: 'Phone or email',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const FilledButton(
                          onPressed: null,
                          child: Text('Sign in'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'API: $apiBaseUrl',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
