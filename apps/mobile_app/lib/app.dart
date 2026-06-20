import 'package:flutter/material.dart';

import 'auth/splash_screen.dart';
import 'config/api_config.dart';
import 'core/api/api_client.dart';
import 'theme/app_theme.dart';

class CameroonBusApp extends StatelessWidget {
  const CameroonBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient(baseUrl: ApiConfig.baseUrl);
    return MaterialApp(
      title: 'Cameroon Bus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: SplashScreen(apiClient: apiClient),
    );
  }
}
