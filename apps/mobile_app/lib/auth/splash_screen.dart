import 'package:flutter/material.dart';

import 'auth_check.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.apiBaseUrl});

  final String apiBaseUrl;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => AuthCheck(apiBaseUrl: widget.apiBaseUrl),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_bus_filled, size: 56),
            SizedBox(height: 16),
            Text('Cameroon Bus'),
          ],
        ),
      ),
    );
  }
}
