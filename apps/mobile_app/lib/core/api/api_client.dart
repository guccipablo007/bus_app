import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../shared/models/api_models.dart';
import '../../shared/models/user_role.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({required String baseUrl, http.Client? httpClient})
    : baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), ''),
      _http = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _http;
  static const _timeout = Duration(seconds: 120);

  Future<Map<String, dynamic>> health() async =>
      _asMap(await _request('GET', '/health'));

  Future<List<RegionModel>> regions() async => _asList(
    await _request('GET', '/regions'),
  ).map(RegionModel.fromJson).toList(growable: false);

  Future<List<CityModel>> cities() async => _asList(
    await _request('GET', '/cities'),
  ).map(CityModel.fromJson).toList(growable: false);

  Future<List<TripModel>> searchTrips({
    required String originCity,
    required String destinationCity,
    DateTime? travelDate,
  }) async {
    final query = <String, String>{
      'originCity': originCity,
      'destinationCity': destinationCity,
      if (travelDate != null) 'travelDate': _dateOnly(travelDate),
    };
    return _asList(
      await _request('GET', '/trips/search', query: query),
    ).map(TripModel.fromJson).toList(growable: false);
  }

  Future<UserSession> login({
    required String identifier,
    required String password,
  }) async => UserSession.fromJson(
    _asMap(
      await _request(
        'POST',
        '/auth/login',
        body: {'identifier': identifier, 'password': password},
      ),
    ),
  );

  Future<UserSession> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async => UserSession.fromJson(
    _asMap(
      await _request(
        'POST',
        '/auth/register',
        body: {
          'fullName': fullName,
          'phone': phone,
          'email': email,
          'password': password,
        },
      ),
    ),
  );

  Future<BookingModel> createBooking({
    required String accessToken,
    required String tripId,
    required String seatNumber,
  }) async => BookingModel.fromJson(
    _asMap(
      await _request(
        'POST',
        '/bookings',
        token: accessToken,
        body: {'tripId': tripId, 'seatNumber': seatNumber},
      ),
    ),
  );

  Future<PaymentConfirmation> confirmDemoPayment({
    required String accessToken,
    required String bookingId,
  }) async {
    final json = _asMap(
      await _request(
        'POST',
        '/bookings/$bookingId/confirm-demo-payment',
        token: accessToken,
      ),
    );
    return PaymentConfirmation(
      booking: BookingModel.fromJson(_asMap(json['booking'])),
      ticket: TicketModel.fromJson(_asMap(json['ticket'])),
    );
  }

  Future<TaxiEligibilityModel> eligibleTaxiAreas({
    required String accessToken,
    required String bookingId,
  }) async => TaxiEligibilityModel.fromJson(
    _asMap(
      await _request(
        'GET',
        '/bookings/$bookingId/eligible-taxi-areas',
        token: accessToken,
      ),
    ),
  );

  Future<TaxiRideModel> createTaxiRide({
    required String accessToken,
    required String bookingId,
    required String destinationAreaId,
    required String destinationLandmark,
  }) async => TaxiRideModel.fromJson(
    _asMap(
      await _request(
        'POST',
        '/bookings/$bookingId/taxi-rides',
        token: accessToken,
        body: {
          'destinationAreaId': destinationAreaId,
          'destinationLandmark': destinationLandmark,
        },
      ),
    ),
  );

  Future<OnboardingApplicationModel> createAgencyApplication({
    required String accessToken,
    required Map<String, dynamic> application,
  }) async => OnboardingApplicationModel.fromJson(
    _asMap(
      await _request(
        'POST',
        '/onboarding/agency-applications',
        token: accessToken,
        body: application,
      ),
    ),
  );

  Future<OnboardingApplicationModel> createDriverApplication({
    required String accessToken,
    required Map<String, dynamic> application,
  }) async => OnboardingApplicationModel.fromJson(
    _asMap(
      await _request(
        'POST',
        '/onboarding/driver-applications',
        token: accessToken,
        body: application,
      ),
    ),
  );

  Future<List<OnboardingApplicationModel>> myApplications({
    required String accessToken,
  }) async => _asList(
    await _request('GET', '/onboarding/my-applications', token: accessToken),
  ).map(OnboardingApplicationModel.fromJson).toList(growable: false);

  Future<List<OnboardingApplicationModel>> adminApplications({
    required String accessToken,
  }) async => _asList(
    await _request('GET', '/admin/applications', token: accessToken),
  ).map(OnboardingApplicationModel.fromJson).toList(growable: false);

  Future<OnboardingApplicationModel> reviewApplication({
    required String accessToken,
    required String applicationId,
    required String decision,
    String? rejectionReason,
  }) async => OnboardingApplicationModel.fromJson(
    _asMap(
      await _request(
        'PATCH',
        '/admin/applications/$applicationId/review',
        token: accessToken,
        body: {
          'decision': decision,
          ...rejectionReason == null
              ? const <String, dynamic>{}
              : {'rejectionReason': rejectionReason},
        },
      ),
    ),
  );

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    late final http.Response response;
    try {
      response = switch (method) {
        'GET' => await _http.get(uri, headers: headers).timeout(_timeout),
        'POST' =>
          await _http
              .post(
                uri,
                headers: headers,
                body: body == null ? null : jsonEncode(body),
              )
              .timeout(_timeout),
        'PATCH' =>
          await _http
              .patch(
                uri,
                headers: headers,
                body: body == null ? null : jsonEncode(body),
              )
              .timeout(_timeout),
        _ => throw ArgumentError.value(method, 'method'),
      };
    } on ApiException {
      rethrow;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'API transport failure: $method $uri (${error.runtimeType})',
          name: 'cameroon_bus.api',
          error: error,
          stackTrace: stackTrace,
        );
      }
      throw const ApiException(
        'Could not reach the bus service. Please try again.',
      );
    }

    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    } on FormatException catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'API returned invalid JSON: $method $uri (${response.statusCode})',
          name: 'cameroon_bus.api',
          error: error,
          stackTrace: stackTrace,
        );
      }
      throw const ApiException(
        'The server had a problem. Please try again later.',
        statusCode: 500,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded is Map<String, dynamic>
          ? decoded
          : const <String, dynamic>{};
      final rawMessage = error['message'];
      var message = rawMessage is List
          ? rawMessage.join('\n')
          : rawMessage?.toString() ?? 'The request could not be completed.';
      if (response.statusCode >= 500) {
        message = 'The server had a problem. Please try again later.';
      }
      throw ApiException(message, statusCode: response.statusCode);
    }
    return decoded;
  }

  static Map<String, dynamic> _asMap(dynamic value) =>
      (value as Map).cast<String, dynamic>();

  static List<Map<String, dynamic>> _asList(dynamic value) => (value as List)
      .map((item) => (item as Map).cast<String, dynamic>())
      .toList(growable: false);

  static String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
