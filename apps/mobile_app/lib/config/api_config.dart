abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://cameroon-bus-api-staging.onrender.com/api/v1',
  );
}
