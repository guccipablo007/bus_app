import 'package:flutter/material.dart';

class PassengerHomeShell extends StatelessWidget {
  const PassengerHomeShell({super.key});

  @override
  Widget build(BuildContext context) => const _RoleShell(
    title: 'Passenger',
    icon: Icons.search,
    message: 'Trip search and bookings will live here.',
  );
}

class _RoleShell extends StatelessWidget {
  const _RoleShell({
    required this.title,
    required this.icon,
    required this.message,
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
