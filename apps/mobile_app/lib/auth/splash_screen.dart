import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../services/session_storage.dart';
import '../shared/models/user_role.dart';
import 'auth_check.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Wait long enough for a clean splash display.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    // Attempt to restore a previously saved session.
    UserSession? restored;
    try {
      final storage = await SessionStorage.create();
      restored = storage.loadSession();
      if (restored != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => AuthCheck(
              apiClient: widget.apiClient,
              sessionStorage: storage,
              restoredSession: restored,
            ),
          ),
        );
        return;
      }
    } catch (_) {
      // If SharedPreferences fails, fall through to login.
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(apiClient: widget.apiClient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD9F3E9), Color(0xFFFFF3D6), Color(0xFFE9EEF8)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_bus_filled, size: 58),
              SizedBox(height: 16),
              Text(
                'Cameroon Bus',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
